import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/uploads/data/upload_image_result.dart';
import 'package:t_app/features/uploads/domain/uploads_image_repository.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import '../widget/outline_button.dart';
import '../widget/primary_button.dart';

class AddProfilePhotoScreen extends StatefulWidget {
  const AddProfilePhotoScreen({super.key});

  @override
  State<AddProfilePhotoScreen> createState() => _AddProfilePhotoScreenState();
}

class _AddProfilePhotoScreenState extends State<AddProfilePhotoScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _previewBytes;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    if (_isSubmitting) {
      return;
    }
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (!mounted || image == null) {
      return;
    }

    final contentType = image.mimeType ?? _guessImageMimeType(image.name);
    if (!_isSupportedImageType(contentType)) {
      _showMessage('Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP.');
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImage = image;
      _previewBytes = bytes;
    });
  }

  Future<void> _completeRegistration({required bool skipAvatar}) async {
    if (_isSubmitting) {
      return;
    }

    if (!skipAvatar && _selectedImage == null) {
      _showMessage('Bạn chưa chọn ảnh đại diện.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (!skipAvatar && _selectedImage != null) {
        final image = _selectedImage!;
        final uploadsRepository = context.read<UploadsImageRepository>();
        final usersRepository = context.read<UsersProfileRepository>();
        final contentType = image.mimeType ?? _guessImageMimeType(image.name);

        final upload = await uploadsRepository.uploadImage(
          fileName: image.name,
          bytes: await image.readAsBytes(),
          contentType: contentType,
          type: UploadImageType.profileAvatar,
        );

        final profile = await usersRepository.updateMe(avatarUrl: upload.secureUrl);
        if (!mounted) {
          return;
        }
        context.read<AuthCubit>().replaceUserProfile(profile);
      }

      if (!mounted) {
        return;
      }
      await context.read<AuthCubit>().checkSession();
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể hoàn tất đăng ký. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Thêm ảnh đại diện',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hãy thêm ảnh đại diện để bạn bè nhận ra bạn. Bạn có thể bỏ qua bước này.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 46),
              Center(
                child: _previewBytes == null
                    ? Container(
                        width: 165,
                        height: 165,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: colorScheme.onSurfaceVariant,
                          size: 112,
                        ),
                      )
                    : ClipOval(
                        child: Image.memory(
                          _previewBytes!,
                          width: 165,
                          height: 165,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const Spacer(),
              PrimaryButton(
                text: _isSubmitting ? 'Đang xử lý...' : 'Chọn ảnh',
                onPressed: _isSubmitting ? null : _pickImage,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: _isSubmitting ? 'Đang hoàn tất...' : 'Tiếp tục',
                onPressed: _isSubmitting
                    ? null
                    : () => _completeRegistration(skipAvatar: false),
              ),
              const SizedBox(height: 12),
              OutlineButton(
                text: 'Bỏ qua',
                onPressed: _isSubmitting
                    ? null
                    : () => _completeRegistration(skipAvatar: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _guessImageMimeType(String fileName) {
  final lowerName = fileName.toLowerCase();
  if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lowerName.endsWith('.webp')) {
    return 'image/webp';
  }

  return 'image/png';
}

bool _isSupportedImageType(String contentType) {
  return contentType == 'image/jpeg' ||
      contentType == 'image/png' ||
      contentType == 'image/webp';
}
