# 联系人页面 (ContactsPage) UI 规范文档

## 1. 页面整体布局

联系人页面采用垂直布局，从上到下包含以下组件：
- 应用栏 (AppBar)
- 同步状态指示器 (可选，仅在同步时或出错时显示)
- 搜索框
- 联系人分组列表
- 右侧字母索引栏
- 悬浮添加按钮

## 2. 组件详细规范

### 2.1 应用栏 (AppBar)

- **标题**: "联系人"，居中显示，字体粗细为 FontWeight.w600
- **背景色**: 绿色 (Colors.green)
- **前景色**: 白色 (Colors.white)
- **左侧按钮**: 筛选按钮，使用 filter_list 图标
- **右侧按钮**: 刷新按钮，使用 refresh 图标
- **阴影**: 无阴影 (elevation: 0)
- **中心对齐**: centerTitle: true

### 2.2 同步状态指示器

- **成功同步时**: 不显示
- **同步中**: 显示绿色进度条，白色背景
  ```dart
  LinearProgressIndicator(
    backgroundColor: Colors.white,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
  )
  ```
- **同步错误**: 显示红色背景的错误提示，包含错误信息和刷新按钮
  ```dart
  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    color: Colors.red.shade100,
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.red, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onRefresh,
        ),
      ],
    ),
  )
  ```

### 2.3 搜索框

- **位置**: 列表顶部第一项
- **布局**: 水平布局，包含输入框和搜索按钮
- **容器样式**:
  ```dart
  Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(...),
  )
  ```
- **输入框样式**:
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
- **搜索按钮**:
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
- **交互逻辑**:
  - 输入文字时不自动搜索，仅更新状态
  - 点击搜索按钮或按下回车键时执行搜索
  - 清除输入后重置搜索状态并保持焦点

### 2.4 联系人分组列表

- **分组方式**: 按拼音首字母分组
- **分组内排序**: 按拼音或名称字符串排序
- **列表容器**:
  ```dart
  ListView.builder(
    controller: scrollController,
    itemCount: sortedKeys.length + 1, // +1 for search box
    physics: const BouncingScrollPhysics(),
    itemBuilder: (context, index) {...},
  )
  ```
- **分组标题**:
  ```dart
  Container(
    key: GlobalKey(debugLabel: 'group_$key'),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Colors.grey[200],
    child: Text(
      key,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  )
  ```
- **联系人列表项**:
  ```dart
  ListTile(
    leading: CircleAvatar(
      backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
      child: contact.avatar == null ? Text(contact.name[0]) : null,
    ),
    title: Text(contact.name),
    subtitle: Text(contact.status ?? ''),
    onTap: onTap,
  )
  ```
- **动画效果**:
  ```dart
  AnimatedList(
    key: ValueKey('group_$key'),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    initialItemCount: contacts.length,
    itemBuilder: (context, itemIndex, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: _buildContactItem(contacts[itemIndex]),
        ),
      );
    },
  )
  ```
- **滚动行为**:
  - 使用 BouncingScrollPhysics 提供反弹效果
  - 使用 ScrollConfiguration 隐藏滚动条

### 2.5 右侧字母索引栏

- **位置**: 屏幕右侧，垂直居中
- **样式**:
  ```dart
  Container(
    width: 24,
    height: totalLettersHeight,
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8),
    margin: const EdgeInsets.only(right: 8),
    child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(...),
    ),
  )
  ```
- **内容**:
  ```dart
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: allIndexes.length,
    itemBuilder: (context, index) {
      final letter = allIndexes[index];
      return GestureDetector(
        onTap: () => onLetterTap(letter),
        child: Container(
          height: 20,
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: currentLetter == letter ? Colors.green : Colors.black54,
            ),
          ),
        ),
      );
    },
  )
  ```
- **交互逻辑**:
  - 点击字母时滚动到对应分组
  - 点击搜索图标时滚动到顶部并聚焦搜索框
  - 点击时在屏幕中央显示当前选中字母的提示
  - 搜索结果显示时隐藏索引栏

### 2.6 悬浮添加按钮 (FloatingActionButton)

- **位置**: 右下角
- **样式**:
  ```dart
  FloatingActionButton(
    backgroundColor: Colors.green,
    child: const Icon(Icons.person_add),
    onPressed: onPressed,
  )
  ```
- **功能**: 点击时导航到添加联系人页面

## 3. 交互状态

### 3.1 正常浏览状态

- 显示所有联系人分组
- 显示右侧字母索引栏
- 搜索框在顶部

### 3.2 搜索状态

- 搜索框保持在顶部
- 下方显示搜索结果
- 隐藏右侧字母索引栏
- 无搜索结果时显示"没有找到匹配的联系人"提示

### 3.3 加载状态

- 显示居中的进度指示器
  ```dart
  const Center(child: CircularProgressIndicator())
  ```
- 加载完成后显示联系人列表

### 3.4 错误状态

- 显示错误信息
  ```dart
  Center(child: Text('错误: ${state.errorMessage}'))
  ```
- 提供重试选项

## 4. 响应式设计

- 联系人列表宽度自适应屏幕
- 分组标题宽度铺满
- 右侧索引栏高度根据字母数量自适应
- 搜索框水平方向自适应屏幕宽度

## 5. 无障碍支持

- 搜索框有明确的标签和提示
- 联系人项目使用语义化组件
- 点击区域足够大，便于触摸操作
- 提供清晰的视觉反馈

## 6. 性能优化

- 使用 AutomaticKeepAliveClientMixin 保持页面状态
  ```dart
  class _ContactsPageState extends State<ContactsPage>
      with AutomaticKeepAliveClientMixin {
    @override
    bool get wantKeepAlive => true;
  }
  ```
- 使用 ListView.builder 实现列表项懒加载
- 使用 ValueKey 确保列表项正确重建
- 搜索结果使用高效的过滤算法

## 7. 中文输入法支持

- 搜索功能支持中文拼音输入
- 使用"确认后搜索"模式，避免输入过程中触发搜索
- 搜索按钮仅在有输入内容时显示
- 优化键盘和焦点管理，确保搜索后键盘不会意外消失

## 8. 分组和排序逻辑

### 8.1 分组规则

- 英文字母：使用首字母大写形式作为分组键
- 数字：归类到 '#' 分组
- 中文和其他字符：获取拼音首字母作为分组键
  - 如果拼音首字母不是英文字母，则归类到 '#' 分组

### 8.2 排序规则

- 分组间排序：按字母表顺序排序分组键
- 分组内排序：
  - 优先按拼音排序（如果有）
  - 否则按名称字符串排序 