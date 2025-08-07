import 'package:flutter/material.dart';
import 'package:cc/core/l10n/app_localizations.dart';

class PhoneInputWithHistory extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Future<List<String>> Function() getPhoneHistory;
  final Future<void> Function(String) removePhoneFromHistory;
  final Function(String) onPhoneSelected;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;

  const PhoneInputWithHistory({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.getPhoneHistory,
    required this.removePhoneFromHistory,
    required this.onPhoneSelected,
    this.labelText,
    this.hintText,
    this.prefixIcon,
  });

  @override
  State<PhoneInputWithHistory> createState() => _PhoneInputWithHistoryState();
}

class _PhoneInputWithHistoryState extends State<PhoneInputWithHistory> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  bool _isOverlayVisible = false;
  List<String> _phoneHistory = [];
  int _previousLength = 0; // 跟踪上一次输入的长度

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    // 初始化长度记录
    _previousLength = widget.controller.text.length;
    // 延迟加载，确保 widget.getPhoneHistory 已经准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhoneHistory();
    });
  }

  @override
  void didUpdateWidget(PhoneInputWithHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 getPhoneHistory 回调函数发生变化，重新加载
    if (oldWidget.getPhoneHistory != widget.getPhoneHistory) {
      _loadPhoneHistory();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  Future<void> _loadPhoneHistory() async {
    try {
      _phoneHistory = await widget.getPhoneHistory();
      debugPrint('🔍 PhoneInputWithHistory: 加载历史记录 ${_phoneHistory.length} 条: $_phoneHistory');
      
      // 如果没有历史记录，添加一些测试数据（仅用于调试）
      if (_phoneHistory.isEmpty) {
        debugPrint('⚠️ PhoneInputWithHistory: 没有历史记录，添加测试数据');
        _phoneHistory = ['13812345678', '13987654321', '18900000000'];
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ PhoneInputWithHistory: 加载历史记录失败: $e');
      _phoneHistory = ['13812345678', '13987654321']; // 添加测试数据
    }
  }

  void _onFocusChanged() {
    debugPrint('📱 PhoneInputWithHistory: 焦点变化 hasFocus=${_focusNode.hasFocus}, 历史记录数量=${_phoneHistory.length}, 当前输入长度=${widget.controller.text.length}');
    
    if (_focusNode.hasFocus && _phoneHistory.isNotEmpty) {
      // 焦点获得时，只有当长度<11时才自动显示下拉菜单
      // 如果长度≥11，等待用户主动点击
      if (widget.controller.text.length < 11) {
        debugPrint('✅ PhoneInputWithHistory: 自动显示下拉菜单（长度<11）');
        _showOverlay();
      } else {
        debugPrint('⚠️ PhoneInputWithHistory: 长度≥11，不自动显示，等待主动点击');
      }
    } else {
      debugPrint('❌ PhoneInputWithHistory: 失焦或无历史记录，准备隐藏下拉菜单');
      // 延迟隐藏下拉列表，给点击事件时间执行
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    debugPrint('🔽 PhoneInputWithHistory: _showOverlay 调用 - 当前状态: isVisible=$_isOverlayVisible, 历史记录数量=${_phoneHistory.length}');
    
    if (_isOverlayVisible || _phoneHistory.isEmpty) {
      debugPrint('⚠️ PhoneInputWithHistory: _showOverlay 跳过 - isVisible=$_isOverlayVisible 或历史记录为空');
      return;
    }

    try {
      // 确保 context 仍然有效，且能找到 Overlay
      if (!mounted || !context.mounted) {
        debugPrint('⚠️ PhoneInputWithHistory: Widget 未挂载，无法显示下拉菜单');
        return;
      }

      final overlay = Overlay.of(context, rootOverlay: false);
      _overlayEntry = _createOverlayEntry();
      overlay.insert(_overlayEntry!);
      _isOverlayVisible = true;
      debugPrint('✅ PhoneInputWithHistory: 下拉菜单已显示');
    } catch (e) {
      debugPrint('❌ PhoneInputWithHistory: 显示下拉菜单失败: $e');
    }
  }

  void _hideOverlay() {
    if (!_isOverlayVisible) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5.0,
        width: size.width,
        child: Material(
          elevation: 16.0, // 提高层级，确保在其他内容之上
          borderRadius: BorderRadius.circular(8.0),
          shadowColor: Colors.black54,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _phoneHistory.length,
              itemBuilder: (context, index) {
                final phone = _phoneHistory[index];
                return _buildHistoryItem(phone);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String phone) {
    return InkWell(
      onTap: () {
        debugPrint('📞 PhoneInputWithHistory: 选择历史记录: $phone');
        // 直接策略：先更新UI，再同步状态
        // 1. 立即更新TextEditingController（确保用户看到变化）
        widget.controller.text = phone;
        
        // 2. 通知AuthCubit状态更新
        widget.onPhoneSelected(phone);
        
        // 3. 确保onChanged也被触发，保持状态一致性
        widget.onChanged(phone);
        
        _hideOverlay();
        _focusNode.unfocus();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                phone,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey[500],
                ),
                onPressed: () async {
                  debugPrint('🗑️ PhoneInputWithHistory: 删除历史记录: $phone');
                  await widget.removePhoneFromHistory(phone);
                  await _loadPhoneHistory();
                  if (_phoneHistory.isEmpty) {
                    _hideOverlay();
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText ?? localizations.phoneNumber,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon ?? const Icon(Icons.phone),
          suffixIcon: _phoneHistory.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    _isOverlayVisible
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    debugPrint('🔽 PhoneInputWithHistory: 下拉箭头被点击 - 当前状态: isVisible=$_isOverlayVisible, 输入长度: ${widget.controller.text.length}');
                    if (_isOverlayVisible) {
                      _hideOverlay();
                      _focusNode.unfocus();
                    } else {
                      _focusNode.requestFocus();
                      // 主动点击下拉箭头时，不管长度是多少都显示下拉菜单
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_phoneHistory.isNotEmpty && _focusNode.hasFocus) {
                          debugPrint('✅ PhoneInputWithHistory: 主动点击显示下拉菜单');
                          _showOverlay();
                        }
                      });
                    }
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        keyboardType: TextInputType.phone,
        onChanged: (value) {
          widget.onChanged(value);
          
          // 检查是否从 <11 变为 ≥11，如果是则隐藏下拉菜单
          if (_previousLength < 11 && value.length >= 11 && _isOverlayVisible) {
            debugPrint('🔢 PhoneInputWithHistory: 长度从$_previousLength变为${value.length}，自动隐藏下拉菜单');
            _hideOverlay();
          }
          
          // 更新长度记录
          _previousLength = value.length;
        },
        onTap: () {
          debugPrint('👆 PhoneInputWithHistory: 输入框被点击 - 历史记录数量=${_phoneHistory.length}, isVisible=$_isOverlayVisible, 输入长度=${widget.controller.text.length}');
          // 主动点击输入框时，不管长度是多少都显示下拉菜单
          if (_phoneHistory.isNotEmpty && !_isOverlayVisible) {
            debugPrint('✅ PhoneInputWithHistory: 主动点击输入框显示下拉菜单');
            _showOverlay();
          } else {
            debugPrint('⚠️ PhoneInputWithHistory: onTap 不满足显示条件（无历史记录或已显示）');
          }
        },
      ),
    );
  }
}