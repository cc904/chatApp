import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cc/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/user_service.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/core/constants/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _logger = LogService.instance;
  final _formKey = GlobalKey<FormState>();

  // 文本编辑控制器
  late TextEditingController _nicknameController;
  late TextEditingController _statusController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // 头像相关
  File? _selectedAvatarFile;
  String? _currentAvatarUrl;

  // 图片选择器
  final ImagePicker _picker = ImagePicker();

  // 是否有未保存的更改
  bool _hasUnsavedChanges = false;

  // 上传进度
  int _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profileCubit = context.read<ProfileCubit>();
    final user = profileCubit.state.user;

    _nicknameController = TextEditingController(text: user?.name ?? '');
    _statusController = TextEditingController(text: user?.status ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _currentAvatarUrl = user?.avatar;

    // 监听文本变化
    _nicknameController.addListener(_onTextChanged);
    _statusController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _statusController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          UINotificationService().showSuccess('个人信息更新成功');
          Navigator.pop(context);
        } else if (state.status == ProfileStatus.error) {
          UINotificationService().showError(state.error ?? '更新失败');
        }
      },
      builder: (context, state) {
        // 当有用户数据时，确保控制器内容是最新的
        if (state.user != null) {
          final user = state.user!;

          // 更新控制器内容（只在内容不同时更新，避免无限循环）
          if (_nicknameController.text != (user.name)) {
            _nicknameController.text = user.name;
          }
          if (_statusController.text != (user.status ?? '')) {
            _statusController.text = user.status ?? '';
          }
          if (_phoneController.text != (user.phone ?? '')) {
            _phoneController.text = user.phone ?? '';
          }
          if (_emailController.text != (user.email ?? '')) {
            _emailController.text = user.email ?? '';
          }
          if (_currentAvatarUrl != user.avatar) {
            _currentAvatarUrl = user.avatar;
          }
        }

        // 如果正在加载且还没有用户数据，显示加载指示器
        if (state.status == ProfileStatus.loading && state.user == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F7),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF2F2F7),
              foregroundColor: Colors.black,
              elevation: 0,
              title: const Text('编辑资料'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: _buildAppBar(),
          body: _buildBody(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF2F2F7),
      foregroundColor: Colors.black,
      elevation: 0,
      title: const Text('编辑资料'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _onBackPressed,
      ),
      actions: [
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return TextButton(
              onPressed:
                  state.status == ProfileStatus.loading ? null : _onSavePressed,
              child: state.status == ProfileStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 头像编辑区域
            _buildAvatarSection(),

            const SizedBox(height: 30),

            // 基本信息编辑区域
            _buildBasicInfoSection(),

            const SizedBox(height: 20),

            // 联系方式区域
            _buildContactSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          // 头像
          GestureDetector(
            onTap: _showAvatarOptions,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _selectedAvatarFile != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(_selectedAvatarFile!),
                        )
                      : UserAvatar(
                          avatarUrl: _currentAvatarUrl,
                          name: _nicknameController.text.isNotEmpty
                              ? _nicknameController.text
                              : '用户',
                          radius: 60,
                          backgroundColor: AppColors.primary,
                        ),
                ),

                // 编辑图标
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '点击更换头像',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildInputTile(
            label: '昵称',
            controller: _nicknameController,
            hintText: '请输入昵称',
            maxLength: 20,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '昵称不能为空';
              }
              if (value.trim().length < 2) {
                return '昵称至少需要2个字符';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildReadOnlyTile(
            label: '手机号',
            value: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : '未绑定',
            trailing: TextButton(
              onPressed: _phoneController.text.isEmpty ? _bindPhone : null,
              child: Text(
                _phoneController.text.isEmpty ? '绑定' : '已绑定',
                style: TextStyle(
                  color: _phoneController.text.isEmpty
                      ? AppColors.primary
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 16),
          _buildReadOnlyTile(
            label: '邮箱',
            value: _emailController.text.isNotEmpty
                ? _emailController.text
                : '未绑定',
            trailing: TextButton(
              onPressed: _emailController.text.isEmpty ? _bindEmail : null,
              child: Text(
                _emailController.text.isEmpty ? '绑定' : '已绑定',
                style: TextStyle(
                  color: _emailController.text.isEmpty
                      ? AppColors.primary
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTile({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLength: maxLength,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                counterText: maxLength != null ? null : '',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTile({
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: value == '未绑定' ? Colors.grey[400] : Colors.black87,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '更换头像',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  icon: Icons.camera_alt,
                  label: '拍照',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAvatarOption(
                  icon: Icons.photo_library,
                  label: '从相册选择',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedAvatarFile != null || _currentAvatarUrl != null)
                  _buildAvatarOption(
                    icon: Icons.delete,
                    label: '删除头像',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _removeAvatar();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: optionColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: optionColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: optionColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedAvatarFile = File(image.path);
          _hasUnsavedChanges = true;
        });

        _logger.i('头像已选择', extra: {'imagePath': image.path});
      }
    } catch (e) {
      _logger.e('选择头像失败', error: e);
      UINotificationService().showError('选择头像失败');
    }
  }

  void _removeAvatar() {
    setState(() {
      _selectedAvatarFile = null;
      _currentAvatarUrl = null;
      _hasUnsavedChanges = true;
    });

    _logger.i('头像已删除');
  }

  void _bindPhone() {
    // TODO: 实现手机号绑定功能
    UINotificationService().showInfo('手机号绑定功能开发中');
  }

  void _bindEmail() {
    // TODO: 实现邮箱绑定功能
    UINotificationService().showInfo('邮箱绑定功能开发中');
  }

  void _onBackPressed() {
    if (_hasUnsavedChanges) {
      _showDiscardChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃更改'),
        content: const Text('您有未保存的更改，确定要放弃吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回上一页
            },
            child: const Text(
              '放弃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profileCubit = context.read<ProfileCubit>();

    try {
      String? avatarUrl = _currentAvatarUrl;

      // 如果选择了新头像，先上传头像
      if (_selectedAvatarFile != null) {
        _logger.i('开始上传头像');

        // 显示上传进度对话框
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildUploadProgressDialog(),
        );

        try {
          final response = await UserService.instance.uploadAvatar(
            _selectedAvatarFile!,
            onProgress: (progress) {
              // 更新上传进度
              setState(() {
                _uploadProgress = progress;
              });
            },
          );

          // 关闭进度对话框
          if (mounted) Navigator.of(context).pop();

          if (response?.success == true &&
              response?.user.avatar.isNotEmpty == true) {
            avatarUrl = response!.user.avatar;
            _logger.i('头像上传成功', extra: {'avatarUrl': avatarUrl});
          } else {
            throw Exception('头像上传失败: ${response?.message ?? "未知错误"}');
          }
        } catch (e) {
          // 关闭进度对话框
          if (mounted) Navigator.of(context).pop();
          rethrow;
        }
      }

      // 🔧 修复：统一通过ProfileCubit处理所有更新
      // 无论是否有头像更新，都通过ProfileCubit统一处理状态管理
      profileCubit.updateUserInfo(
        nickname: _nicknameController.text.trim(),
        avatar: avatarUrl,
        status: _statusController.text.trim(),
      );

      _logger.i('保存个人信息', extra: {
        'nickname': _nicknameController.text.trim(),
        'status': _statusController.text.trim(),
        'hasNewAvatar': _selectedAvatarFile != null,
        'avatarUrl': avatarUrl,
      });
    } catch (error) {
      _logger.e('保存个人信息失败', error: error);
      UINotificationService().showError('保存失败: $error');
    }
  }

  Widget _buildUploadProgressDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('上传头像'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: _uploadProgress / 100,
              ),
              const SizedBox(height: 16),
              Text('上传进度: $_uploadProgress%'),
            ],
          ),
        );
      },
    );
  }
}
