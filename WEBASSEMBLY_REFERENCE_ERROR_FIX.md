# WebAssembly ReferenceError 修复报告

## 🚨 问题描述

在 Safari 浏览器中，Flutter Web 应用出现 `ReferenceError: Can't find variable: WebAssembly` 错误，导致应用无法正常启动。

### 错误信息
```
[Error] ReferenceError: Can't find variable: WebAssembly 
     P (flutter.js:1:250) 
     （匿名函数） (flutter.js:1:348) 
     全局代码 (flutter.js:31:1579)

[Error] TypeError: undefined is not a constructor (evaluating 'new WebAssembly.RuntimeError')
     main.dart.js:8293
```

## 🔍 错误分析

### 根本原因
1. **过度禁用策略**：之前的修复完全删除了 `window.WebAssembly` 对象
2. **Flutter 脚本依赖**：Flutter 的 `flutter.js` 脚本需要检查 WebAssembly 的存在性
3. **引用错误**：当脚本尝试访问不存在的 WebAssembly 变量时，抛出 ReferenceError
4. **构造函数缺失**：Flutter/Dart 代码尝试创建 `WebAssembly.RuntimeError` 等错误对象
5. **不完整的假对象**：初始的假对象缺少必要的错误构造函数

### 技术细节
- Flutter 引擎在初始化时会检查 WebAssembly 支持
- 完全删除 WebAssembly 对象导致脚本中的引用失败
- 需要提供一个"假的"对象来满足存在性检查，但禁用实际功能

## 🛠️ 修复方案

### 策略调整：从"完全禁用"到"选择性 WebAssembly 策略"

#### 修复前（有问题的方法）
```javascript
// 🚫 完全禁用 WebAssembly 以避免 buffer 错误
if (window.WebAssembly) {
  delete window.WebAssembly;  // ❌ 导致 ReferenceError
}
```

#### 修复后（选择性策略）
```javascript
// 🎯 Safari专用：选择性 WebAssembly 策略 - 允许 SQLite，阻止 CanvasKit
if (window.WebAssembly) {
  console.log('🎯 Safari模式：实施选择性WebAssembly策略（SQLite ✅, CanvasKit ❌）');
  
  // 保存原始WebAssembly引用
  window._originalWebAssembly = window.WebAssembly;
  
  // 创建选择性 WebAssembly 代理
  const originalInstantiate = window.WebAssembly.instantiate;
  const originalCompile = window.WebAssembly.compile;
  
  // 重写 instantiate 方法
  window.WebAssembly.instantiate = function(source, importObject) {
    // 检查是否是 sqlite3.wasm 相关的调用
    if (importObject && (
      importObject.env || 
      importObject.wasi_snapshot_preview1 ||
      (typeof source === 'object' && source.constructor === Uint8Array)
    )) {
      console.log('✅ Safari：允许 SQLite WebAssembly 实例化');
      return originalInstantiate.call(this, source, importObject);
    }
    
    // 阻止其他 WebAssembly 使用（主要是 CanvasKit）
    console.log('🚫 Safari：阻止非 SQLite WebAssembly 实例化');
    return Promise.reject(new Error('WebAssembly disabled for CanvasKit compatibility'));
  };
  
  // 重写 compile 方法
  window.WebAssembly.compile = function(source) {
    // 简单的启发式检查：SQLite WASM 通常较大
    if (source && source.byteLength && source.byteLength > 100000) {
      console.log('✅ Safari：允许大型 WebAssembly 模块编译（可能是 SQLite）');
      return originalCompile.call(this, source);
    }
    
    console.log('🚫 Safari：阻止小型 WebAssembly 模块编译');
    return Promise.reject(new Error('WebAssembly compile disabled for compatibility'));
  };
  
  console.log('✅ Safari模式：选择性 WebAssembly 策略已启用');
}
```

#### 策略原理

由于应用使用 Drift 数据库，需要 `sqlite3.wasm` 来在 Web 上运行 SQLite，因此不能完全禁用 WebAssembly。选择性策略：

1. **保留原始 WebAssembly 功能**：不完全替换 WebAssembly 对象
2. **智能识别 SQLite 调用**：通过 `importObject` 的特征识别 SQLite WebAssembly
3. **阻止 CanvasKit WebAssembly**：拒绝非 SQLite 的 WebAssembly 实例化
4. **大小启发式检查**：SQLite WASM 通常较大（>100KB），小模块可能是 CanvasKit
5. **保持数据库功能**：Drift 数据库可以正常使用 `sqlite3.wasm`

## 🎯 预期效果

### 成功日志序列
```
🍎 检测到Safari浏览器，启用Safari兼容模式
🚫 Safari模式：静默拦截CanvasKit资源: [URL]
🎯 Safari模式：实施选择性WebAssembly策略（SQLite ✅, CanvasKit ❌）
✅ Safari模式：选择性 WebAssembly 策略已启用
✅ Safari：允许 SQLite WebAssembly 实例化
🚫 Safari：阻止非 SQLite WebAssembly 实例化
🍎 Safari：页面开始加载
🍎 Safari：渲染器设置为 html
🍎 Safari：本地存储 true
```

### 不应再出现的错误
- ❌ `ReferenceError: Can't find variable: WebAssembly`
- ❌ `TypeError: undefined is not an object (evaluating 'za.buffer')`
- ❌ `TypeError: undefined is not a constructor (evaluating 'new WebAssembly.RuntimeError')`
- ❌ `TypeError: undefined is not a constructor (evaluating 'new WebAssembly.CompileError')`
- ❌ CanvasKit WebAssembly 相关错误

### 应该正常工作的功能
- ✅ Drift 数据库（使用 `sqlite3.wasm`）
- ✅ Flutter 应用渲染（HTML 渲染器）
- ✅ 应用基本功能

## 🔄 最新改进（MIME 类型问题修复）

### 问题描述
在实施选择性 WebAssembly 策略后，出现了新的错误：
```
Unhandled Promise Rejection: TypeError: Unexpected response MIME type. Expected 'application/wasm'
```

### 改进方案
1. **增强 SQLite 识别逻辑**：
   - 提高文件大小阈值到 500KB（SQLite WASM 通常较大）
   - 增加更多 `importObject` 特征检查
   - 添加对 `wasi` 和 `env.memory` 的检查

2. **支持流式 WebAssembly 方法**：
   - 重写 `WebAssembly.instantiateStreaming`
   - 重写 `WebAssembly.compileStreaming`
   - 基于 URL 检查 `sqlite3.wasm` 文件

3. **改进的识别函数**：
```javascript
function isSqliteRelated(source, importObject) {
  // 检查 importObject 特征
  if (importObject && (
    importObject.env || 
    importObject.wasi_snapshot_preview1 ||
    importObject.wasi ||
    (importObject.env && importObject.env.memory)
  )) {
    return true;
  }
  
  // 检查源码大小（SQLite WASM 通常较大）
  if (source && source.byteLength && source.byteLength > 500000) {
    return true;
  }
  
  return false;
}
```

4. **静默阻止 CanvasKit 策略**：
```javascript
// 检查是否是 CanvasKit 相关的 URL - 静默拒绝，不记录错误
if (source && source.url && (
  source.url.includes('canvaskit') || 
  source.url.includes('skwasm') ||
  source.url.includes('gstatic.com')
)) {
  console.log('🔇 Safari：静默阻止 CanvasKit WebAssembly 流式编译');
  // 返回一个永远不会 resolve 的 Promise，让 Flutter 超时并回退
  return new Promise(() => {});
}
```

### 关键改进
- **完全静默阻止**：所有 WebAssembly 方法都不抛出错误
- **统一策略**：`instantiate`、`compile`、`instantiateStreaming`、`compileStreaming` 全部使用静默阻止
- **让 Flutter 超时**：Flutter 引擎会自动超时并回退到 HTML 渲染器
- **零错误日志**：完全避免 Promise rejection 错误

### 修复的方法
1. `WebAssembly.instantiate` - 静默阻止非 SQLite
2. `WebAssembly.compile` - 静默阻止非 SQLite  
3. `WebAssembly.instantiateStreaming` - 静默阻止非 SQLite
4. `WebAssembly.compileStreaming` - 静默阻止非 SQLite

所有方法都返回 `new Promise(() => {})` 而不是 `Promise.reject()`

## 🔧 技术细节

### 假对象设计原则
1. **存在性检查通过**：对象存在，避免 ReferenceError
2. **功能性检查失败**：所有方法返回失败，强制回退
3. **兼容性保证**：提供所有必要的属性和方法
4. **调试友好**：保存原始对象引用，便于调试

### Safari 兼容性策略
- 让 Flutter 引擎认为 WebAssembly "存在但不可用"
- 自动触发 JavaScript 回退机制
- 避免 buffer 相关的底层错误
- 保持应用功能完整性

## 🧪 测试验证

### 测试步骤
1. 在 Safari 浏览器中访问 `http://localhost:80`
2. 打开开发者工具的控制台
3. 观察启动日志和错误信息

### 成功标志
- ✅ 无 ReferenceError 错误
- ✅ WebAssembly 替换日志正常
- ✅ Flutter loader 成功初始化
- ✅ 应用界面正常渲染

### 失败标志
- ❌ 仍有 WebAssembly 相关错误
- ❌ Flutter loader 初始化失败
- ❌ 应用白屏或加载超时

## 📚 相关文档

- [WEBASSEMBLY_BUFFER_FIX.md](./WEBASSEMBLY_BUFFER_FIX.md) - 原始 buffer 错误修复
- [FLUTTER_LOADER_API_FIX.md](./FLUTTER_LOADER_API_FIX.md) - Loader API 修复
- [FLUTTER_LOADER_DEBUG_ENHANCEMENT.md](./FLUTTER_LOADER_DEBUG_ENHANCEMENT.md) - 调试增强

---
**修复时间**: 2024年12月
**修复版本**: WebAssembly 假对象策略 v2.0
**测试环境**: Safari 浏览器, macOS