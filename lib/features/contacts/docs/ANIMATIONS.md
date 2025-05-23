# 联系人页面动画效果规范

## 1. 概述

联系人页面使用多种动画效果来增强用户体验，使界面更加生动和现代化。本文档详细描述了这些动画效果的实现方式和视觉表现。

## 2. 联系人列表项动画

### 2.1 实现方式

联系人列表项的动画效果通过 `AnimatedList` 组件实现，为每个分组中的联系人项目添加动画效果。每个联系人分组都有自己的 `AnimatedList`，确保动画效果独立且流畅。

```dart
AnimatedList(
  key: ValueKey('group_$key'),
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  initialItemCount: contacts.length,
  itemBuilder: (context, itemIndex, animation) {
    // 动画实现
  },
)
```

### 2.2 动画类型

联系人列表项使用两种组合动画效果：

#### 2.2.1 大小过渡动画 (SizeTransition)

- **效果描述**：联系人项目从小到大展开，创造一种"生长"的视觉效果
- **实现代码**：
  ```dart
  SizeTransition(
    sizeFactor: animation,
    child: // 其他动画或内容
  )
  ```
- **动画参数**：
  - `sizeFactor`: 直接使用提供的 `animation` 对象控制大小变化
  - 动画曲线：使用默认的 ease-in-out 曲线

#### 2.2.2 滑动过渡动画 (SlideTransition)

- **效果描述**：联系人项目从屏幕右侧滑入到最终位置
- **实现代码**：
  ```dart
  SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0), // 从右侧开始
      end: Offset.zero, // 滑动到原位置
    ).animate(animation),
    child: _buildContactItem(contacts[itemIndex]),
  )
  ```
- **动画参数**：
  - 起始位置：`Offset(1, 0)`（水平方向偏移屏幕宽度，垂直方向无偏移）
  - 结束位置：`Offset.zero`（回到原始位置）
  - 动画曲线：使用默认的 ease-in-out 曲线

### 2.3 组合效果

两种动画组合使用，创造出联系人项目同时"生长"并"滑入"的效果，使列表加载过程更加生动有趣。完整实现如下：

```dart
SizeTransition(
  sizeFactor: animation,
  child: SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: _buildContactItem(contacts[itemIndex]),
  ),
)
```

## 3. 字母索引交互动画

### 3.1 字母选择提示动画

当用户点击右侧字母索引时，会在屏幕中央显示当前选中的字母，并在短暂延迟后隐藏。

#### 3.1.1 实现方式

```dart
// 显示当前字母
setState(() {
  _currentLetter = letter;
});

// 短暂显示后隐藏
Future.delayed(const Duration(milliseconds: 500), () {
  if (mounted) {
    setState(() {
      _currentLetter = null;
    });
  }
});
```

#### 3.1.2 视觉效果

```dart
if (_currentLetter != null)
  Positioned.fill(
    child: Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _currentLetter!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  ),
```

### 3.2 滚动动画

点击字母索引时，列表会平滑滚动到对应的分组位置。

#### 3.2.1 实现方式

```dart
_scrollController.animateTo(
  offset,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);
```

#### 3.2.2 动画参数

- **持续时间**：300毫秒
- **动画曲线**：`Curves.easeInOut`，提供平滑的加速和减速效果

## 4. 搜索框交互动画

### 4.1 清除按钮显示/隐藏

搜索框的清除按钮会根据输入内容的有无动态显示或隐藏。

```dart
suffixIcon: _isSearching
    ? IconButton(
        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          setState(() {
            _searchController.clear();
            _isSearching = false;
            _isFiltering = false;
          });
          // 清除后重新聚焦到搜索框
          _searchFocusNode.requestFocus();
        },
      )
    : null,
```

### 4.2 搜索按钮显示/隐藏

搜索按钮仅在输入框有内容时显示，使用条件渲染实现：

```dart
if (_isSearching)
  Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: ElevatedButton(
      // 按钮配置
    ),
  ),
```

## 5. 下拉刷新动画

联系人列表支持下拉刷新功能，使用 `RefreshIndicator` 实现标准的下拉刷新动画效果。

```dart
RefreshIndicator(
  onRefresh: _syncContacts,
  child: // 列表内容
)
```

## 6. 性能优化

为确保动画流畅运行，采取以下优化措施：

1. **分组使用独立的 AnimatedList**：每个字母分组使用独立的 AnimatedList，减少整体列表的重建范围
2. **使用 ValueKey**：为每个 AnimatedList 提供唯一的 ValueKey，确保在重建时能够正确识别
3. **使用 const 构造器**：对于静态组件使用 const 构造器，减少不必要的重建
4. **限制动画复杂度**：只对必要的元素应用动画，避免过度使用动画导致性能问题

## 7. 动画调整指南

如需调整动画效果，可以修改以下参数：

### 7.1 联系人列表项动画

- **动画持续时间**：调整 AnimatedList 的默认动画持续时间
- **动画曲线**：修改 `animation` 的曲线参数，如改为 `CurvedAnimation(parent: animation, curve: Curves.elasticOut)`
- **起始位置**：修改 SlideTransition 的 `begin` 值，如 `Offset(0, 1)` 可实现从底部滑入

### 7.2 字母选择提示动画

- **显示持续时间**：修改 `Future.delayed` 的延迟时间
- **提示框大小**：调整容器的 width 和 height
- **提示框样式**：修改 BoxDecoration 参数，如颜色、透明度、圆角等

### 7.3 滚动动画

- **滚动持续时间**：修改 `animateTo` 的 duration 参数
- **滚动曲线**：修改 `animateTo` 的 curve 参数，如改为 `Curves.easeOutQuart` 可实现更快的开始和更慢的结束 