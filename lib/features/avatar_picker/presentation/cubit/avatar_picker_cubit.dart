import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cc/core/services/log_service.dart';

/// 头像选择器状态
class AvatarPickerState extends Equatable {
  final File? imageFile;
  final String? imageUrl;
  final bool isLoading;
  final String? error;

  const AvatarPickerState({
    this.imageFile,
    this.imageUrl,
    this.isLoading = false,
    this.error,
  });

  AvatarPickerState copyWith({
    File? imageFile,
    String? imageUrl,
    bool? isLoading,
    String? error,
  }) {
    return AvatarPickerState(
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [imageFile, imageUrl, isLoading, error];
}

/// 头像选择器Cubit
class AvatarPickerCubit extends Cubit<AvatarPickerState> {
  final LogService _logger = LogService('avatar_picker_cubit.dart');
  final ImagePicker _picker = ImagePicker();

  AvatarPickerCubit() : super(const AvatarPickerState());

  /// 从相机拍摄头像
  Future<void> takePhoto() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        emit(state.copyWith(
          imageFile: File(pickedFile.path),
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      _logger.e('拍摄照片失败', error: e);
      emit(state.copyWith(isLoading: false, error: '拍摄照片失败: $e'));
    }
  }

  /// 从相册选择头像
  Future<void> pickFromGallery() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        emit(state.copyWith(
          imageFile: File(pickedFile.path),
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      _logger.e('选择照片失败', error: e);
      emit(state.copyWith(isLoading: false, error: '选择照片失败: $e'));
    }
  }

  /// 清除已选择的头像
  void clearImage() {
    emit(state.copyWith(imageFile: null, imageUrl: null, error: null));
  }
} 