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

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _loadPhoneHistory();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  Future<void> _loadPhoneHistory() async {
    _phoneHistory = await widget.getPhoneHistory();
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _phoneHistory.isNotEmpty) {
      _showOverlay();
    } else {
      // 延迟隐藏下拉列表，给点击事件时间执行
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    if (_isOverlayVisible || _phoneHistory.isEmpty) {
      return;
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOverlayVisible = true;
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

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0, // 提高层级
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
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
      ),
    );
  }

  Widget _buildHistoryItem(String phone) {
    return InkWell(
      onTap: () {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.history,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                phone,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: () async {
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
                    if (_isOverlayVisible) {
                      _hideOverlay();
                      _focusNode.unfocus();
                    } else {
                      _focusNode.requestFocus();
                    }
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        keyboardType: TextInputType.phone,
        onChanged: widget.onChanged,
        onTap: () {
          if (_phoneHistory.isNotEmpty && !_isOverlayVisible) {
            _showOverlay();
          }
        },
      ),
    );
  }
}