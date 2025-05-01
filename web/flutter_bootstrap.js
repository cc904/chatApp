// Flutter Web引导脚本
// 用于在Web平台上加载web_main.dart而不是main.dart

// 检测浏览器环境以及是否支持WebAssembly
const isWebAssemblySupported = (() => {
  try {
    if (typeof WebAssembly === 'object' &&
        typeof WebAssembly.instantiate === 'function') {
      const module = new WebAssembly.Module(
          Uint8Array.of(0x0, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00));
      if (module instanceof WebAssembly.Module)
        return new WebAssembly.Instance(module) instanceof WebAssembly.Instance;
    }
  } catch (e) {}
  return false;
})();

// 加载Flutter引擎
window.addEventListener('load', function() {
  // 添加Flutter引擎脚本
  const scriptLoaderEl = document.createElement('script');
  scriptLoaderEl.src = 'flutter.js';
  scriptLoaderEl.async = true;
  scriptLoaderEl.defer = true;
  document.body.appendChild(scriptLoaderEl);
  
  // Flutter引擎加载完成后初始化应用
  window._flutter_loaded = function() {
    console.log("Web平台启动: 使用 web_main.dart 作为入口");
    
    _flutter.loader
      .loadEntrypoint({
        entrypointUrl: "web_main.dart.js",
        onEntrypointLoaded: async function(engineInitializer) {
          let appRunner = await engineInitializer.initializeEngine({
            // 可以在这里设置特定的渲染引擎和资源配置
          });
          await appRunner.runApp();
        }
      });
  };
  
  // 等待Flutter引擎加载
  if (window.flutter_web_optimizer) {
    // 使用Flutter网页优化器
    window.flutter_web_optimizer.loadEntrypoint({
      entrypointUrl: 'web_main.dart.js',
    });
  } else {
    window.addEventListener('flutter-first-frame', function() {
      console.log('Flutter应用已加载');
    });
  }
}); 