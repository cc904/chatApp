# Flutter Loader 调试增强报告

## 问题描述
Safari浏览器中出现 `Flutter loader加载超时或load方法不可用` 错误，需要增强调试信息来定位具体问题。

## 调试增强措施

### 1. 脚本加载调试增强
```javascript
function loadFlutterScript() {
  return new Promise((resolve, reject) => {
    console.log('🔄 开始加载Flutter脚本...');
    
    const script = document.createElement('script');
    script.src = './flutter.js';
    script.type = 'application/javascript';
    
    script.onload = () => {
      console.log('✅ Flutter脚本加载成功');
      console.log('🔍 检查window._flutter:', !!window._flutter);
      
      // 给脚本一些时间来初始化
      setTimeout(() => {
        console.log('🔍 延迟检查window._flutter:', !!window._flutter);
        console.log('🔍 延迟检查window._flutter.loader:', !!(window._flutter && window._flutter.loader));
        resolve();
      }, 100);
    };
    
    script.onerror = (error) => {
      console.error('❌ Flutter脚本加载失败:', error);
      console.error('❌ 脚本URL:', script.src);
      reject(new Error(`Flutter脚本加载失败: ${error.message || 'Unknown error'}`));
    };
    
    console.log('📝 添加脚本到页面头部...');
    document.head.appendChild(script);
  });
}
```

### 2. Loader等待逻辑增强
```javascript
// 等待loader就绪
let attempts = 0;
const maxAttempts = 100; // 增加等待时间

console.log('⏳ 开始等待Flutter loader初始化...');

while (attempts < maxAttempts) {
  const hasFlutter = !!window._flutter;
  const hasLoader = !!(window._flutter && window._flutter.loader);
  const hasLoadMethod = !!(window._flutter && window._flutter.loader && window._flutter.loader.load);
  
  console.log(`⏳ 等待Flutter loader加载... 尝试 ${attempts + 1}/${maxAttempts}`);
  console.log(`  - window._flutter: ${hasFlutter}`);
  console.log(`  - window._flutter.loader: ${hasLoader}`);
  console.log(`  - window._flutter.loader.load: ${hasLoadMethod}`);
  
  if (hasFlutter && hasLoader && hasLoadMethod) {
    console.log('✅ Flutter loader完全就绪！');
    break;
  }
  
  await new Promise(resolve => setTimeout(resolve, 200)); // 增加等待间隔
  attempts++;
}
```

### 3. 详细错误报告
```javascript
if (!window._flutter || !window._flutter.loader || !window._flutter.loader.load) {
  console.error('❌ Flutter loader最终状态:');
  console.error('  - window._flutter:', !!window._flutter);
  console.error('  - window._flutter.loader:', !!(window._flutter && window._flutter.loader));
  console.error('  - window._flutter.loader.load:', typeof (window._flutter && window._flutter.loader && window._flutter.loader.load));
  
  if (window._flutter && window._flutter.loader) {
    console.error('  - loader对象内容:', Object.keys(window._flutter.loader));
  }
  
  throw new Error(`Flutter loader加载超时或load方法不可用 (尝试了${attempts}次)`);
}
```

## 调试信息解读

### 正常加载序列
1. `🔄 开始加载Flutter脚本...`
2. `📝 添加脚本到页面头部...`
3. `✅ Flutter脚本加载成功`
4. `🔍 检查window._flutter: true`
5. `🔍 延迟检查window._flutter: true`
6. `🔍 延迟检查window._flutter.loader: true`
7. `⏳ 开始等待Flutter loader初始化...`
8. `⏳ 等待Flutter loader加载... 尝试 1/100`
9. `✅ Flutter loader完全就绪！`

### 可能的问题场景

#### 场景1：脚本加载失败
```
🔄 开始加载Flutter脚本...
📝 添加脚本到页面头部...
❌ Flutter脚本加载失败: [错误信息]
❌ 脚本URL: ./flutter.js
```

#### 场景2：脚本加载成功但对象未初始化
```
✅ Flutter脚本加载成功
🔍 检查window._flutter: false
🔍 延迟检查window._flutter: false
```

#### 场景3：Flutter对象存在但loader未初始化
```
🔍 延迟检查window._flutter: true
🔍 延迟检查window._flutter.loader: false
⏳ 等待Flutter loader加载... 尝试 1/100
  - window._flutter: true
  - window._flutter.loader: false
```

#### 场景4：Loader存在但load方法缺失
```
  - window._flutter: true
  - window._flutter.loader: true
  - window._flutter.loader.load: false
❌ Flutter loader最终状态:
  - loader对象内容: ['loadEntrypoint', 'didCreateEngineInitializer']
```

## 故障排除步骤

### 1. 检查网络连接
- 确认 `./flutter.js` 文件可以正常访问
- 检查浏览器网络面板是否有404错误

### 2. 检查浏览器兼容性
- 确认Safari版本支持ES6模块
- 检查是否有JavaScript错误阻止脚本执行

### 3. 检查Content Security Policy
- 确认CSP允许加载本地脚本
- 检查是否有安全策略阻止脚本执行

### 4. 检查脚本完整性
- 确认flutter.js文件没有损坏
- 检查文件大小是否正常

## 测试验证

### 测试步骤
1. 在Safari浏览器中访问 `http://localhost:80`
2. 打开开发者工具查看控制台
3. 观察详细的加载和初始化日志
4. 根据日志信息定位具体问题

### 成功标志
- ✅ 脚本加载成功
- ✅ Flutter对象正确初始化
- ✅ Loader对象包含load方法
- ✅ 应用正常启动

### 失败诊断
根据控制台日志确定失败的具体阶段，然后采取相应的修复措施。