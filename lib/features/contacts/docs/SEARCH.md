# 联系人搜索功能规范

## 1. 概述

联系人搜索功能允许用户快速查找特定联系人，支持中文拼音输入，并提供良好的用户体验。本文档详细描述了搜索功能的实现逻辑、中文输入法支持和用户体验优化。

## 2. 搜索框设计

### 2.1 布局结构

搜索框位于联系人列表的顶部，使用水平布局包含输入框和搜索按钮：

```dart
Container(
  color: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    children: [
      Expanded(
        child: TextField(...),
      ),
      if (isSearching)
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ElevatedButton(...),
        ),
    ],
  ),
)
```

### 2.2 输入框样式

输入框采用圆角设计，带有搜索图标和清除按钮：

```dart
TextField(
  controller: searchController,
  focusNode: searchFocusNode,
  decoration: InputDecoration(
    hintText: '搜索',
    hintStyle: const TextStyle(color: Colors.grey),
    prefixIcon: const Icon(Icons.search, color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    isDense: true,
    filled: true,
    fillColor: Colors.grey[200],
    suffixIcon: isSearching
        ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onClear,
          )
        : null,
  ),
  onChanged: onChanged,
  textInputAction: TextInputAction.search,
  onSubmitted: onSubmitted,
)
```

### 2.3 搜索按钮

搜索按钮仅在输入框有内容时显示，采用绿色背景和圆角设计：

```dart
ElevatedButton(
  onPressed: onSearch,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    minimumSize: const Size(0, 36),
  ),
  child: const Text(
    '搜索',
    style: TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
  ),
)
```

## 3. 搜索逻辑

### 3.1 "确认后搜索"模式

为了优化用户体验，特别是支持中文输入法，采用"确认后搜索"模式：

1. 输入文字时只更新搜索状态，不执行搜索
2. 只有在用户提交输入（按回车键）或点击搜索按钮时才执行搜索

```dart
// 输入变化时只更新状态
onChanged: (value) {
  setState(() {
    _isSearching = value.isNotEmpty;
    if (!_isSearching) {
      _isFiltering = false;
    }
  });
},

// 提交时执行搜索
onSubmitted: (value) {
  if (value.isNotEmpty) {
    _searchContacts(value);
  }
  // 提交后重新聚焦到搜索框
  _searchFocusNode.requestFocus();
},

// 搜索按钮点击时执行搜索
ElevatedButton(
  onPressed: () {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _searchContacts(query);
    }
    // 点击搜索后收起键盘但保持焦点
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  },
  // 按钮样式...
)
```

### 3.2 搜索过滤逻辑

搜索功能会过滤联系人列表，匹配联系人的名称和状态：

```dart
void _searchContacts(String query) {
  if (query.isEmpty) {
    setState(() {
      _isFiltering = false;
    });
    return;
  }

  final homeCubit = context.read<HomeCubit>();
  final allContacts = homeCubit.state.contacts;

  setState(() {
    _isFiltering = true;
    _filteredContacts = allContacts
        .where((contact) =>
            contact.name.toLowerCase().contains(query.toLowerCase()) ||
            (contact.status?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();
  });
}
```

## 4. 中文输入法支持

### 4.1 输入法兼容性问题

在开发过程中发现，使用中文输入法（如拼音输入）时，如果搜索功能在输入过程中触发，会导致以下问题：

1. 拼音输入未完成就触发搜索，导致搜索结果不准确
2. 输入法候选框可能会被搜索结果遮挡
3. 用户无法完成汉字的选择过程

### 4.2 解决方案

为解决上述问题，实现了以下优化：

1. **确认后搜索模式**：输入过程中不触发搜索，只有在用户确认（提交或点击搜索按钮）后才执行搜索
2. **键盘管理优化**：搜索后先收起键盘，再重新聚焦到搜索框，避免输入法状态混乱
3. **焦点保持**：清除输入后保持焦点在搜索框上，提高操作连贯性

### 4.3 与防抖方案的比较

早期版本尝试使用防抖（debounce）方案来延迟搜索触发，但发现对中文输入法支持不佳：

```dart
// 已废弃的防抖搜索方法
void _debouncedSearch(String query) {
  // 取消之前的计时器
  _debounceTimer?.cancel();
  
  // 创建新的计时器
  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
    _searchContacts(query);
  });
}
```

防抖方案的问题：
1. 无法准确判断中文输入法的输入完成时机
2. 延迟时间难以设置：太短会中断输入法，太长会让搜索感觉滞后
3. 用户体验不一致，难以预测搜索何时触发

## 5. 搜索状态管理

### 5.1 状态变量

搜索功能使用以下状态变量管理不同状态：

```dart
bool _isSearching = false;      // 是否有搜索内容
bool _isFiltering = false;      // 是否正在显示搜索结果
List<User> _filteredContacts = []; // 搜索结果列表
```

### 5.2 状态转换逻辑

1. **初始状态**：`_isSearching = false`, `_isFiltering = false`
2. **输入内容**：`_isSearching = true`, `_isFiltering = false`
3. **执行搜索**：`_isSearching = true`, `_isFiltering = true`
4. **清除搜索**：`_isSearching = false`, `_isFiltering = false`

## 6. 用户界面适配

### 6.1 搜索结果显示

搜索结果使用单独的列表视图显示，保持搜索框在顶部：

```dart
Column(
  children: [
    // 保留搜索框在顶部
    _buildSearchBox(),

    Expanded(
      child: _filteredContacts.isEmpty
          ? const Center(child: Text('没有找到匹配的联系人'))
          : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return _buildContactItem(_filteredContacts[index]);
              },
            ),
    ),
  ],
)
```

### 6.2 无搜索结果提示

当搜索无结果时，显示友好的提示信息：

```dart
_filteredContacts.isEmpty
    ? const Center(child: Text('没有找到匹配的联系人'))
    : ListView.builder(...)
```

### 6.3 字母索引栏适配

搜索状态下隐藏右侧字母索引栏，提供更清晰的搜索结果视图：

```dart
// 右侧字母索引栏 - 只在非搜索状态下显示
if (!_isFiltering)
  Positioned.fill(
    child: Align(
      alignment: Alignment.centerRight,
      child: _buildLetterIndex(),
    ),
  ),
```

## 7. 键盘和焦点管理

### 7.1 焦点保持

为提供良好的用户体验，实现了以下焦点管理逻辑：

1. **清除输入后保持焦点**：
   ```dart
   // 清除后重新聚焦到搜索框
   _searchFocusNode.requestFocus();
   ```

2. **搜索后保持焦点**：
   ```dart
   // 点击搜索后收起键盘但保持焦点
   FocusScope.of(context).unfocus();
   Future.delayed(const Duration(milliseconds: 100), () {
     if (mounted) {
       _searchFocusNode.requestFocus();
     }
   });
   ```

### 7.2 键盘行为

配置输入框的键盘行为，使回车键执行搜索：

```dart
textInputAction: TextInputAction.search,
onSubmitted: (value) {
  // 提交时执行搜索
  if (value.isNotEmpty) {
    _searchContacts(value);
  }
  // 提交后重新聚焦到搜索框
  _searchFocusNode.requestFocus();
},
```

## 8. 性能优化

### 8.1 过滤算法优化

搜索过滤使用高效的 `where` 方法，避免不必要的循环：

```dart
_filteredContacts = allContacts
    .where((contact) =>
        contact.name.toLowerCase().contains(query.toLowerCase()) ||
        (contact.status?.toLowerCase().contains(query.toLowerCase()) ??
            false))
    .toList();
```

### 8.2 资源管理

确保正确管理资源，避免内存泄漏：

```dart
@override
void dispose() {
  _searchController.dispose();
  _searchFocusNode.dispose();
  super.dispose();
}
```

## 9. 未来优化方向

1. **搜索历史记录**：记录用户的搜索历史，提供快速重复搜索功能
2. **智能搜索建议**：根据输入内容提供搜索建议
3. **拼音模糊匹配**：支持拼音首字母搜索（如输入"zjl"可匹配"张家龙"）
4. **多字段搜索**：扩展搜索范围，包括电话号码、邮箱等字段
5. **搜索结果高亮**：在搜索结果中高亮匹配的文本 