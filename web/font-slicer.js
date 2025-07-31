/**
 * 动态字体切片器 - 按需加载中文字体
 * 用于 Flutter Web 应用的字体优化系统
 */

(function() {
  'use strict';

  // 配置参数
  const CONFIG = {
    FONT_SERVER_URL: getFontServerUrl(),
    CACHE_DURATION: 24 * 60 * 60 * 1000, // 24小时
    BATCH_SIZE: 100, // 每次请求的字符数
    RETRY_COUNT: 3,
    RETRY_DELAY: 1000
  };

  console.log('🎨 字体切片器已启动，服务器地址:', CONFIG.FONT_SERVER_URL);

  // 获取字体服务器URL
  function getFontServerUrl() {
    // 从环境变量或页面参数获取
    if (window.FONT_SERVER_URL) {
      return window.FONT_SERVER_URL;
    }
    
    // 根据当前端口智能推断字体服务器地址
    const currentPort = window.location.port;
    if (currentPort === '7002') {
      return 'http://localhost:7000';
    }
    
    // 默认字体服务器地址
    return 'http://localhost:3001';
  }

  // 字体缓存管理
  const FontCache = {
    cache: new Map(),
    
    getKey(text, fontFamily = 'NotoSansCJK') {
      return `${fontFamily}:${text}`;
    },
    
    set(text, fontUrl, fontFamily = 'NotoSansCJK') {
      const key = this.getKey(text, fontFamily);
      this.cache.set(key, {
        url: fontUrl,
        timestamp: Date.now()
      });
      
      // 持久化到localStorage
      try {
        const cacheData = {
          url: fontUrl,
          timestamp: Date.now()
        };
        localStorage.setItem(`font_cache_${key}`, JSON.stringify(cacheData));
      } catch (e) {
        console.warn('无法保存字体缓存到localStorage:', e);
      }
    },
    
    get(text, fontFamily = 'NotoSansCJK') {
      const key = this.getKey(text, fontFamily);
      
      // 先检查内存缓存
      if (this.cache.has(key)) {
        const cached = this.cache.get(key);
        if (Date.now() - cached.timestamp < CONFIG.CACHE_DURATION) {
          return cached.url;
        }
        this.cache.delete(key);
      }
      
      // 检查localStorage缓存
      try {
        const cachedData = localStorage.getItem(`font_cache_${key}`);
        if (cachedData) {
          const parsed = JSON.parse(cachedData);
          if (Date.now() - parsed.timestamp < CONFIG.CACHE_DURATION) {
            this.cache.set(key, parsed);
            return parsed.url;
          }
          localStorage.removeItem(`font_cache_${key}`);
        }
      } catch (e) {
        console.warn('读取localStorage字体缓存失败:', e);
      }
      
      return null;
    }
  };

  // 字体加载队列
  const FontQueue = {
    queue: new Set(),
    processing: false,
    
    add(text) {
      if (text && text.trim()) {
        this.queue.add(text.trim());
        this.process();
      }
    },
    
    async process() {
      if (this.processing || this.queue.size === 0) {
        return;
      }
      
      this.processing = true;
      
      try {
        const texts = Array.from(this.queue).slice(0, CONFIG.BATCH_SIZE);
        const combinedText = [...new Set(texts.join(''))].join('');
        
        // 清理已处理的文本
        texts.forEach(text => this.queue.delete(text));
        
        if (combinedText) {
          await this.loadFont(combinedText);
        }
      } catch (error) {
        console.error('字体处理错误:', error);
      } finally {
        this.processing = false;
        
        // 继续处理剩余队列
        if (this.queue.size > 0) {
          setTimeout(() => this.process(), 100);
        }
      }
    },
    
    async loadFont(text, retryCount = 0) {
      try {
        // 检查缓存
        const cachedUrl = FontCache.get(text);
        if (cachedUrl) {
          await this.applyFont(cachedUrl);
          return;
        }
        
        // 请求字体子集
        const response = await fetch(`${CONFIG.FONT_SERVER_URL}/subset`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            text: text,
            fontFamily: 'NotoSansCJK'
          })
        });
        
        if (!response.ok) {
          throw new Error(`字体服务器响应错误: ${response.status}`);
        }
        
        const fontBlob = await response.blob();
        const fontUrl = URL.createObjectURL(fontBlob);
        
        // 缓存字体
        FontCache.set(text, fontUrl);
        
        // 应用字体
        await this.applyFont(fontUrl);
        
        console.log(`✅ 字体加载成功: ${text.substring(0, 20)}...`);
        
      } catch (error) {
        console.error('字体加载失败:', error);
        
        if (retryCount < CONFIG.RETRY_COUNT) {
          console.log(`🔄 重试字体加载 (${retryCount + 1}/${CONFIG.RETRY_COUNT})`);
          setTimeout(() => {
            this.loadFont(text, retryCount + 1);
          }, CONFIG.RETRY_DELAY * (retryCount + 1));
        }
      }
    },
    
    async applyFont(fontUrl) {
      return new Promise((resolve, reject) => {
        const fontFace = new FontFace('DynamicCJK', `url(${fontUrl})`);
        
        fontFace.load().then((loadedFontFace) => {
          document.fonts.add(loadedFontFace);
          resolve();
        }).catch(reject);
      });
    }
  };

  // 文本提取器
  const TextExtractor = {
    extractFromElement(element) {
      const texts = new Set();
      
      if (element.nodeType === Node.TEXT_NODE) {
        const text = element.textContent?.trim();
        if (text) {
          texts.add(text);
        }
      } else if (element.nodeType === Node.ELEMENT_NODE) {
        // 递归提取子元素的文本
        for (const child of element.childNodes) {
          const childTexts = this.extractFromElement(child);
          childTexts.forEach(text => texts.add(text));
        }
      }
      
      return texts;
    },
    
    extractFromDocument() {
      const texts = new Set();
      const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        null,
        false
      );
      
      let node;
      while (node = walker.nextNode()) {
        const text = node.textContent?.trim();
        if (text && /[\u4e00-\u9fff]/.test(text)) {
          texts.add(text);
        }
      }
      
      return texts;
    }
  };

  // 观察器管理
  const Observer = {
    observer: null,
    
    init() {
      // 观察DOM变化
      this.observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList') {
            mutation.addedNodes.forEach((node) => {
              if (node.nodeType === Node.ELEMENT_NODE || node.nodeType === Node.TEXT_NODE) {
                const texts = TextExtractor.extractFromElement(node);
                texts.forEach(text => FontQueue.add(text));
              }
            });
          }
        });
      });
      
      this.observer.observe(document.body, {
        childList: true,
        subtree: true,
        characterData: true
      });
    },
    
    destroy() {
      if (this.observer) {
        this.observer.disconnect();
        this.observer = null;
      }
    }
  };

  // 公共API
  window.FontSlicer = {
    loadText(text) {
      FontQueue.add(text);
    },
    
    preloadCommonChars() {
      // 预加载常用汉字
      const commonChars = '的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三四五六七八九零';
      FontQueue.add(commonChars);
    },
    
    extractAndLoad() {
      const texts = TextExtractor.extractFromDocument();
      texts.forEach(text => FontQueue.add(text));
    }
  };

  // 初始化
  function init() {
    console.log('🚀 初始化字体切片器...');
    
    // 启动观察器
    Observer.init();
    
    // 预加载常用字符
    window.FontSlicer.preloadCommonChars();
    
    // 提取现有文本
    setTimeout(() => {
      window.FontSlicer.extractAndLoad();
    }, 500);
    
    console.log('✅ 字体切片器初始化完成');
  }

  // 页面加载完成后初始化
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // 页面卸载时清理
  window.addEventListener('beforeunload', () => {
    Observer.destroy();
  });

})();