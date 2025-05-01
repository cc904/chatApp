import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  bool _flashOn = false;
  bool _isGalleryMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('扫一扫'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _flashOn = !_flashOn;
              });
              dev.log('闪光灯: $_flashOn');
              // 这里应该添加实际控制闪光灯的代码
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 模拟相机预览
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          ),

          // 扫描框
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Stack(
                children: [
                  // 四个角的装饰
                  Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                  Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),

                  // 扫描线动画
                  Center(
                    child: Container(
                      height: 2,
                      width: 250,
                      color: Colors.green.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部提示文字
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    '将二维码/条码放入框内，即可自动扫描',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isGalleryMode
                      ? ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isGalleryMode = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('返回扫一扫'),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              _isGalleryMode = true;
                            });
                            dev.log('从相册选择二维码图片');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '相册',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建扫描框四个角的装饰
  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
        ),
      ),
    );
  }

  // 显示更多选项菜单
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(Icons.person_add, '添加朋友'),
            _buildOptionItem(Icons.group_add, '扫群二维码'),
            _buildOptionItem(Icons.account_balance_wallet, '收付款'),
            _buildOptionItem(Icons.translate, '翻译'),
          ],
        ),
      ),
    );
  }

  // 构建选项项
  Widget _buildOptionItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        dev.log('选择了选项: $text');
        // 这里添加相应选项的处理逻辑
      },
    );
  }

  // 处理扫描结果
  void _handleScanResult(String code) {
    dev.log('扫描结果: $code');
    // 根据扫描结果类型进行不同处理
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('扫描结果'),
        content: Text(code),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 处理结果，例如打开链接或添加好友等
            },
            child: const Text('处理', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
