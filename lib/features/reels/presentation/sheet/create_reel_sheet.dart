import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/reels/presentation/reel_video_constraints.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_cubit.dart';
import 'package:t_app/features/uploads/data/upload_video_result.dart';
import 'package:t_app/features/uploads/domain/uploads_image_repository.dart';
import 'package:video_player/video_player.dart';

Future<void> showCreateReelSheet(BuildContext context) {
  final uploadsRepository = context.read<UploadsImageRepository>();
  final authUser = context.read<AuthCubit>().state.user;
  final currentUser = User(
    id: authUser?.id ?? 'current_user',
    name: authUser?.displayName ?? authUser?.username ?? 'You',
    username: authUser?.username ?? 'you',
    avatarUrl: authUser?.avatarUrl,
  );

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) {
      return CreateReelSheet(
        feedbackContext: context,
        currentUser: currentUser,
        uploadsRepository: uploadsRepository,
        onSubmit: ({
          required String videoUrl,
          required String caption,
          int? durationSeconds,
        }) {
          return context.read<ReelsCubit>().createReel(
                videoUrl: videoUrl,
                caption: caption,
                durationSeconds: durationSeconds,
              );
        },
      );
    },
  );
}

class CreateReelSheet extends StatefulWidget {
  const CreateReelSheet({
    super.key,
    required this.feedbackContext,
    required this.currentUser,
    required this.uploadsRepository,
    required this.onSubmit,
  });

  final BuildContext feedbackContext;
  final User currentUser;
  final UploadsImageRepository uploadsRepository;
  final Future<void> Function({
    required String videoUrl,
    required String caption,
    int? durationSeconds,
  }) onSubmit;

  @override
  State<CreateReelSheet> createState() => _CreateReelSheetState();
}

class _CreateReelSheetState extends State<CreateReelSheet> {
  static const int _maxVideoBytes = 25 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _captionController;
  XFile? _selectedVideo;
  Uint8List? _selectedBytes;
  String? _selectedContentType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (!mounted || picked == null) {
      return;
    }

    final fileSize = await picked.length();
    if (fileSize > _maxVideoBytes) {
      _showError('Video must be smaller than 25MB.');
      return;
    }

    final durationError = await _validatePickedVideoDuration(picked);
    if (!mounted || durationError != null) {
      if (durationError != null) {
        _showError(durationError);
      }
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedVideo = picked;
      _selectedBytes = bytes;
      _selectedContentType = picked.mimeType ?? _videoContentType(picked.name);
    });
  }

  Future<String?> _validatePickedVideoDuration(XFile video) async {
    final controller = VideoPlayerController.file(File(video.path));

    try {
      await controller.initialize();
      return validateReelVideoDuration(controller.value.duration);
    } catch (_) {
      return 'Cannot read selected video.';
    } finally {
      await controller.dispose();
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (_selectedVideo == null || _selectedBytes == null) {
      _showError('Pick a video before creating a reel.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final upload = await widget.uploadsRepository.uploadVideo(
        fileName: _selectedVideo!.name,
        bytes: _selectedBytes!,
        contentType: _selectedContentType ?? 'video/mp4',
      );

      await widget.onSubmit(
        videoUrl: upload.url,
        caption: _captionController.text.trim(),
        durationSeconds: upload.durationSeconds,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      _showSuccess(widget.feedbackContext, upload);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      _showError(error.message);
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      _showError(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      _showError('Cannot create reel right now.');
    }
  }

  String _videoContentType(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (lowerName.endsWith('.webm')) {
      return 'video/webm';
    }

    return 'video/mp4';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(BuildContext context, UploadVideoResult upload) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          upload.durationSeconds != null
              ? 'Reel created (${upload.durationSeconds}s).'
              : 'Reel created.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _CreateReelHeader(
                  onCancel: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
                Divider(height: 1, color: theme.dividerColor),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 48,
                            child: Column(
                              children: [
                                AvatarView(
                                  user: widget.currentUser,
                                  radius: 20,
                                ),
                                Container(
                                  width: 1.5,
                                  height: 120,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.currentUser.username,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _captionController,
                                  enabled: !_isSubmitting,
                                  maxLines: null,
                                  minLines: 4,
                                  maxLength: 500,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    height: 1.35,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Write a caption...',
                                    hintStyle: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    counterStyle: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _VideoSelectionCard(
                                  fileName: _selectedVideo?.name,
                                  onTap: _isSubmitting ? null : _pickVideo,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _CreateReelFooter(
                  isSubmitting: _isSubmitting,
                  hasVideo: _selectedVideo != null,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateReelHeader extends StatelessWidget {
  const _CreateReelHeader({required this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: onCancel == null ? 0.5 : 1,
              child: Text(
                'Cancel',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'New reel',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Icon(
            Icons.more_horiz_rounded,
            size: 24,
            color: colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _VideoSelectionCard extends StatelessWidget {
  const _VideoSelectionCard({
    required this.fileName,
    required this.onTap,
  });

  final String? fileName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasVideo = fileName != null && fileName!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    hasVideo
                        ? Icons.play_circle_outline_rounded
                        : Icons.video_library_outlined,
                    size: 26,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasVideo ? 'Video selected' : 'Choose a video',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasVideo
                            ? fileName!
                            : 'Upload from gallery to create a reel up to 60 seconds.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  hasVideo ? 'Change' : 'Pick',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateReelFooter extends StatelessWidget {
  const _CreateReelFooter({
    required this.isSubmitting,
    required this.hasVideo,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final bool hasVideo;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            hasVideo
                ? 'Cloud upload enabled'
                : 'Choose a video up to 60 seconds',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isSubmitting || !hasVideo ? null : onSubmit,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSubmitting || !hasVideo ? 0.55 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 38,
                padding: EdgeInsets.symmetric(
                  horizontal: isSubmitting ? 12 : 18,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSubmitting) ...[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      'Create reel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
