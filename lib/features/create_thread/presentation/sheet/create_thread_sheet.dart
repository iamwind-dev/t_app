import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_app/features/reels/presentation/sheet/create_reel_sheet.dart';
import 'package:t_app/features/create_thread/data/models/thread_draft.dart';
import 'package:t_app/features/create_thread/presentation/widget/ai_scanning_text.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_moderation_ui.dart';
import 'package:t_app/features/uploads/data/upload_image_result.dart';
import 'package:t_app/features/uploads/domain/uploads_image_repository.dart';
import 'package:t_app/features/posts/data/moderated_thread_submission.dart';

enum ComposerMode { create, reply }

class ThreadComposerReplyContext {
  const ThreadComposerReplyContext({
    required this.parentThreadId,
    required this.username,
    required this.avatarAssetPath,
    required this.content,
    required this.createdAt,
  });

  final String parentThreadId;
  final String username;
  final String? avatarAssetPath;
  final String content;
  final String createdAt;

  /// Builds the reply preview metadata from an existing thread node.
  factory ThreadComposerReplyContext.fromThread(ThreadItemModel thread) {
    return ThreadComposerReplyContext(
      parentThreadId: thread.id,
      username: thread.author.username,
      avatarAssetPath: thread.author.avatarAssetPath,
      content: thread.content,
      createdAt: thread.createdAt,
    );
  }
}

class ThreadComposerSubmitRequest {
  const ThreadComposerSubmitRequest({
    required this.mode,
    required this.items,
    this.mediaUrls = const <String>[],
    this.parentThreadId,
  });

  final ComposerMode mode;
  final List<String> items;
  final List<String> mediaUrls;
  final String? parentThreadId;

  String get primaryContent =>
      items.firstWhere((item) => item.trim().isNotEmpty, orElse: () => '');
}

typedef ThreadComposerSubmitCallback =
    Future<ModeratedThreadSubmission> Function(ThreadComposerSubmitRequest request);

Future<void> showCreateThreadSheet({
  required BuildContext context,
  required User currentUser,
  ThreadComposerSubmitCallback? onSubmit,
  void Function(ModeratedThreadSubmission)? onSubmissionAccepted,
}) {
  return showThreadComposerSheet(
    context: context,
    currentUser: currentUser,
    onSubmit: onSubmit,
    onSubmissionAccepted: onSubmissionAccepted,
  );
}

Future<void> showThreadComposerSheet({
  required BuildContext context,
  required User currentUser,
  ComposerMode mode = ComposerMode.create,
  ThreadComposerReplyContext? replyContext,
  ThreadComposerSubmitCallback? onSubmit,
  void Function(ModeratedThreadSubmission)? onSubmissionAccepted,
}) {
  final uploadsRepository = context.read<UploadsImageRepository>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      return ThreadComposerSheet(
        currentUser: currentUser,
        uploadsRepository: uploadsRepository,
        mode: mode,
        replyContext: replyContext,
        onSubmit: onSubmit,
        onSubmissionAccepted: onSubmissionAccepted,
      );
    },
  );
}

enum PostState { idle, aiChecking, postingSuccess }

class ThreadComposerSheet extends StatefulWidget {
  const ThreadComposerSheet({
    super.key,
    required this.currentUser,
    required this.uploadsRepository,
    this.mode = ComposerMode.create,
    this.replyContext,
    this.onSubmit,
    this.onSubmissionAccepted,
  });

  final User currentUser;
  final UploadsImageRepository uploadsRepository;
  final ComposerMode mode;
  final ThreadComposerReplyContext? replyContext;
  final ThreadComposerSubmitCallback? onSubmit;
  final void Function(ModeratedThreadSubmission)? onSubmissionAccepted;

  @override
  State<ThreadComposerSheet> createState() => _ThreadComposerSheetState();
}

class _ThreadComposerSheetState extends State<ThreadComposerSheet>
    with SingleTickerProviderStateMixin {
  static const int _maxImageCount = 4;
  static const int _maxImageBytes = 5 * 1024 * 1024;

  late ThreadDraft _draft;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _replyControlsEnabled = true;
  PostState _postState = PostState.idle;
  late AnimationController _scanController;
  final ImagePicker _imagePicker = ImagePicker();
  List<_ComposerImageAttachment> _imageAttachments = const [];

  bool get _isReplyMode => widget.mode == ComposerMode.reply;

  @override
  void initState() {
    super.initState();
    _draft = const ThreadDraft(items: [ThreadDraftItem(id: 'draft_1')]);
    _controllers = [TextEditingController()];
    _focusNodes = [FocusNode()];
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateDraftItem(int index, String value) {
    final nextItems = [..._draft.items];
    nextItems[index] = nextItems[index].copyWith(content: value);
    setState(() {
      _draft = _draft.copyWith(items: nextItems);
    });
  }

  /// Opens the gallery and stages up to four images for the pending submit.
  Future<void> _pickImages() async {
    final remainingSlots = _maxImageCount - _imageAttachments.length;
    if (remainingSlots <= 0) {
      _showSubmitError('Ban chi co the dinh kem toi da 4 anh.');
      return;
    }

    final pickedImages = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      limit: remainingSlots,
    );
    if (!mounted || pickedImages.isEmpty) {
      return;
    }

    final nextAttachments = <_ComposerImageAttachment>[
      ..._imageAttachments,
    ];
    var hasInvalidType = false;
    var hasOversizedFile = false;
    for (final image in pickedImages) {
      if (nextAttachments.length >= _maxImageCount) {
        break;
      }

      final contentType = image.mimeType ?? _imageContentType(image.name);
      if (!_isSupportedImageType(contentType)) {
        hasInvalidType = true;
        continue;
      }

      final fileSize = await image.length();
      if (fileSize > _maxImageBytes) {
        hasOversizedFile = true;
        continue;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }

      nextAttachments.add(
        _ComposerImageAttachment(
          fileName: image.name,
          bytes: bytes,
          contentType: contentType,
        ),
      );
    }

    setState(() {
      _imageAttachments = nextAttachments;
    });

    if (hasInvalidType) {
      _showSubmitError('Chi ho tro anh JPEG, PNG hoac WebP.');
    } else if (hasOversizedFile) {
      _showSubmitError('Moi anh phai nho hon 5MB.');
    }
  }

  /// Removes one staged image before upload.
  void _removeImageAttachmentAt(int index) {
    setState(() {
      _imageAttachments = [
        ..._imageAttachments.take(index),
        ..._imageAttachments.skip(index + 1),
      ];
    });
  }

  /// Uploads staged images one by one and returns the remote URLs for submit.
  Future<List<String>> _uploadImageUrls() async {
    final uploadType = _isReplyMode
        ? UploadImageType.reply
        : UploadImageType.post;
    final urls = <String>[];

    for (final attachment in _imageAttachments) {
      final upload = await widget.uploadsRepository.uploadImage(
        fileName: attachment.fileName,
        bytes: attachment.bytes,
        contentType: attachment.contentType,
        type: uploadType,
      );
      urls.add(upload.secureUrl);
    }

    return urls;
  }

  /// Maps a picked image extension to the multipart MIME type expected by Dio.
  String _imageContentType(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  bool _isSupportedImageType(String contentType) {
    return contentType == 'image/jpeg' ||
        contentType == 'image/png' ||
        contentType == 'image/webp';
  }

  /// Shows a short failure message when local picking or remote upload fails.
  void _showSubmitError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Adds a new block only when the composer is in create mode.
  void _addDraftItem() {
    if (_isReplyMode) {
      return;
    }

    final newIndex = _draft.items.length + 1;
    setState(() {
      _draft = _draft.copyWith(
        items: [
          ..._draft.items,
          ThreadDraftItem(id: 'draft_$newIndex'),
        ],
      );
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNodes.last.requestFocus();
    });
  }

  void _openCreateReelFlow() {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCreateReelSheet(rootContext);
    });
  }

  /// Uploads staged media first, then delegates the final post or reply submit.
  Future<void> _submit() async {
    if (_postState != PostState.idle) {
      return;
    }

    final items = _controllers
        .map((controller) => controller.text.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) {
      return;
    }

    try {
      setState(() {
        _postState = PostState.aiChecking;
      });
      _scanController.forward(from: 0.0);

      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) {
        return;
      }

      List<String> mediaUrls = const <String>[];
      if (_imageAttachments.isNotEmpty) {
        mediaUrls = await _uploadImageUrls();
      }
      if (!mounted) {
        return;
      }

      ModeratedThreadSubmission? submission;
      if (widget.onSubmit != null) {
        submission = await widget.onSubmit!(
          ThreadComposerSubmitRequest(
            mode: widget.mode,
            items: items,
            mediaUrls: mediaUrls,
            parentThreadId: widget.replyContext?.parentThreadId,
          ),
        );
      }
      if (submission == null) {
        _resetComposerState();
        return;
      }

      await _handleSubmissionResult(submission);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _resetComposerState();
      _showSubmitError(
        _imageAttachments.isNotEmpty
            ? 'Khong the tai anh len luc nay.'
            : 'Khong the dang bai luc nay.',
      );
    }
  }

  /// Routes the backend moderation decision into the appropriate composer UX.
  Future<void> _handleSubmissionResult(ModeratedThreadSubmission submission) async {
    final moderation = submission.moderation;
    if (moderation?.isAiUnavailable == true) {
      _showSubmitError('AI moderation unavailable');
    }

    if (moderation == null ||
        (moderation.action == 'ALLOW' && moderation.isWarning == false)) {
      await _acceptSubmission(submission);
      return;
    }

    if (moderation.shouldWarnUser ||
        moderation.isWarning ||
        moderation.shouldBlockOrReview) {
      final acceptedByUi = await showModerationWarningDialog(
        context,
        moderation,
      );
      if (!mounted) {
        return;
      }

      if (acceptedByUi) {
        await _acceptSubmission(submission);
        return;
      }

      _resetComposerState();
      return;
    }

    await _acceptSubmission(submission);
  }

  /// Finalizes a submission only after the moderation UX has been resolved.
  Future<void> _acceptSubmission(ModeratedThreadSubmission submission) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _postState = PostState.postingSuccess;
    });

    if (widget.onSubmissionAccepted != null) {
      widget.onSubmissionAccepted!(submission);
    }

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  /// Restores the composer to editable mode without clearing the draft.
  void _resetComposerState() {
    if (!mounted) {
      return;
    }

    setState(() {
      _postState = PostState.idle;
    });
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
        heightFactor: 0.94,
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
                ThreadComposerHeader(
                  mode: widget.mode,
                  onCancel: () => Navigator.of(context).pop(),
                ),
                Divider(height: 1, color: theme.dividerColor),
                Expanded(
                  child: _ThreadDraftComposer(
                    currentUser: widget.currentUser,
                    draft: _draft,
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onChanged: _updateDraftItem,
                    onAddToThread: _addDraftItem,
                    imageAttachments: _imageAttachments,
                    onPickImages: _pickImages,
                    onRemoveImageAttachment: _removeImageAttachmentAt,
                    onPickVideo: _openCreateReelFlow,
                    postState: _postState,
                    scanController: _scanController,
                    mode: widget.mode,
                    replyContext: widget.replyContext,
                  ),
                ),
                ThreadComposerFooter(
                  mode: widget.mode,
                  replyControlsEnabled: _replyControlsEnabled,
                  onToggleReplyControls: () {
                    setState(() {
                      _replyControlsEnabled = !_replyControlsEnabled;
                    });
                  },
                  onSubmit: _submit,
                  postState: _postState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThreadComposerHeader extends StatelessWidget {
  const ThreadComposerHeader({
    super.key,
    required this.mode,
    required this.onCancel,
  });

  final ComposerMode mode;
  final VoidCallback onCancel;

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
            child: Text(
              'Hủy',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                mode == ComposerMode.reply ? 'Trả lời' : 'Chủ đề mới',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 22,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.more_horiz_rounded,
                size: 24,
                color: colorScheme.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreadDraftComposer extends StatelessWidget {
  const _ThreadDraftComposer({
    required this.currentUser,
    required this.draft,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onAddToThread,
    required this.imageAttachments,
    required this.onPickImages,
    required this.onRemoveImageAttachment,
    required this.onPickVideo,
    required this.postState,
    required this.scanController,
    required this.mode,
    this.replyContext,
  });

  final User currentUser;
  final ThreadDraft draft;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final VoidCallback onAddToThread;
  final List<_ComposerImageAttachment> imageAttachments;
  final Future<void> Function() onPickImages;
  final void Function(int index) onRemoveImageAttachment;
  final VoidCallback onPickVideo;
  final PostState postState;
  final AnimationController scanController;
  final ComposerMode mode;
  final ThreadComposerReplyContext? replyContext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: [
        if (replyContext != null) ...[
          ReplyContextPreview(replyContext: replyContext!),
          const SizedBox(height: 18),
        ],
        for (var index = 0; index < draft.items.length; index++)
          _ThreadDraftItemComposer(
            currentUser: currentUser,
            controller: controllers[index],
            focusNode: focusNodes[index],
            isLastItem: index == draft.items.length - 1,
            showMediaComposer: index == 0,
            onChanged: (value) => onChanged(index, value),
            onAddToThread: onAddToThread,
            imageAttachments: imageAttachments,
            onPickImages: onPickImages,
            onPickVideo: onPickVideo,
            onRemoveImageAttachment: onRemoveImageAttachment,
            postState: postState,
            scanController: scanController,
            mode: mode,
          ),
      ],
    );
  }
}

class ReplyContextPreview extends StatelessWidget {
  const ReplyContextPreview({super.key, required this.replyContext});

  final ThreadComposerReplyContext replyContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarView(
            user: User(
              id: replyContext.parentThreadId,
              name: replyContext.username,
              username: replyContext.username,
              avatarAssetPath: replyContext.avatarAssetPath,
            ),
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        replyContext.username,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      replyContext.createdAt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  replyContext.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadDraftItemComposer extends StatelessWidget {
  const _ThreadDraftItemComposer({
    required this.currentUser,
    required this.controller,
    required this.focusNode,
    required this.isLastItem,
    required this.showMediaComposer,
    required this.onChanged,
    required this.onAddToThread,
    required this.imageAttachments,
    required this.onPickImages,
    required this.onPickVideo,
    required this.onRemoveImageAttachment,
    required this.postState,
    required this.scanController,
    required this.mode,
  });

  final User currentUser;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLastItem;
  final bool showMediaComposer;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddToThread;
  final List<_ComposerImageAttachment> imageAttachments;
  final Future<void> Function() onPickImages;
  final VoidCallback onPickVideo;
  final void Function(int index) onRemoveImageAttachment;
  final PostState postState;
  final AnimationController scanController;
  final ComposerMode mode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const avatarRadius = 20.0;
    const smallAvatarRadius = 11.0;
    const leftColumnWidth = 48.0;

    final isCheckingOrSuccess = postState != PostState.idle;
    final isSuccess = postState == PostState.postingSuccess;

    return Padding(
      padding: EdgeInsets.only(bottom: isLastItem ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: leftColumnWidth,
            child: Column(
              children: [
                AvatarView(user: currentUser, radius: avatarRadius),
                if (mode == ComposerMode.create) ...[
                  Container(
                    width: 1.5,
                    height: 76,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  AvatarView(
                    user: currentUser,
                    radius: smallAvatarRadius,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser.username,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isCheckingOrSuccess
                      ? AnimatedBuilder(
                          animation: scanController,
                          builder: (context, _) => AiScanningText(
                            text: controller.text,
                            progress: scanController.value,
                            isSuccess: isSuccess,
                          ),
                        )
                      : TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: onChanged,
                          maxLines: null,
                          minLines: 4,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colorScheme.onSurface,
                                height: 1.35,
                              ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: mode == ComposerMode.reply
                                ? 'Trả lời...'
                                : 'Có gì mới?',
                            hintStyle: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: colorScheme.onSurface,
                        ),
                ),
                const SizedBox(height: 12),
                ComposerToolbar(
                  onPickImages: onPickImages,
                  onPickVideo: onPickVideo,
                ),
                if (showMediaComposer && imageAttachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ComposerImageStrip(
                    attachments: imageAttachments,
                    onRemoveImage: onRemoveImageAttachment,
                  ),
                ],
                if (mode == ComposerMode.create && isLastItem) ...[
                  const SizedBox(height: 14),
                  AddToThreadRow(
                    currentUser: currentUser,
                    onTap: onAddToThread,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ComposerToolbar extends StatelessWidget {
  const ComposerToolbar({
    super.key,
    required this.onPickImages,
    required this.onPickVideo,
  });

  static const _icons = [
    Icons.image_outlined,
    Icons.video_library_outlined,
    Icons.gif_box_outlined,
    Icons.subject_rounded,
    Icons.format_quote_rounded,
    Icons.more_horiz_rounded,
  ];

  final Future<void> Function() onPickImages;
  final VoidCallback onPickVideo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(_icons.length, (index) {
        return GestureDetector(
          onTap: switch (index) {
            0 => () => onPickImages(),
            1 => onPickVideo,
            _ => null,
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              right: index == _icons.length - 1 ? 0 : 18,
            ),
            child: Icon(
              _icons[index],
              size: 22,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }),
    );
  }
}

class _ComposerImageStrip extends StatelessWidget {
  const _ComposerImageStrip({
    required this.attachments,
    required this.onRemoveImage,
  });

  final List<_ComposerImageAttachment> attachments;
  final void Function(int index) onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _ComposerImageCard(
            attachment: attachments[index],
            onRemove: () => onRemoveImage(index),
          );
        },
      ),
    );
  }
}

class _ComposerImageCard extends StatelessWidget {
  const _ComposerImageCard({
    required this.attachment,
    required this.onRemove,
  });

  final _ComposerImageAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: ColoredBox(
            color: colorScheme.surfaceContainerLow,
            child: Image.memory(
              attachment.bytes,
              width: 92,
              height: 92,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddToThreadRow extends StatelessWidget {
  const AddToThreadRow({
    super.key,
    required this.currentUser,
    required this.onTap,
  });

  final User currentUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AvatarView(
            user: currentUser,
            radius: 11,
          ),
          const SizedBox(width: 10),
          Text(
            'Thêm vào chủ đề',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ThreadComposerFooter extends StatelessWidget {
  const ThreadComposerFooter({
    super.key,
    required this.mode,
    required this.replyControlsEnabled,
    required this.onToggleReplyControls,
    required this.onSubmit,
    required this.postState,
  });

  final ComposerMode mode;
  final bool replyControlsEnabled;
  final VoidCallback onToggleReplyControls;
  final VoidCallback onSubmit;
  final PostState postState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isChecking = postState == PostState.aiChecking;
    final isSuccess = postState == PostState.postingSuccess;

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
            Icons.public_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            mode == ComposerMode.reply ? 'Đang trả lời' : 'Lựa chọn trả lời',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (mode == ComposerMode.create) ...[
            GestureDetector(
              onTap: isChecking || isSuccess ? null : onToggleReplyControls,
              behavior: HitTestBehavior.opaque,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isChecking || isSuccess ? 0.5 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 30,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: replyControlsEnabled
                        ? colorScheme.onSurface
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Align(
                    alignment: replyControlsEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: replyControlsEnabled
                            ? colorScheme.surface
                            : colorScheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          GestureDetector(
            onTap: isChecking || isSuccess ? null : onSubmit,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 38,
              padding: EdgeInsets.symmetric(
                horizontal: isChecking || isSuccess ? 12 : 18,
              ),
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
                border: isSuccess
                    ? Border.all(color: Colors.green.withValues(alpha: 0.5))
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isChecking) ...[
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
                  if (isSuccess) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    isSuccess
                        ? 'Thành công'
                        : (mode == ComposerMode.reply ? 'Trả lời' : 'Đăng'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSuccess ? Colors.green : colorScheme.onSurface,
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
}

class _ComposerImageAttachment {
  const _ComposerImageAttachment({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String fileName;
  final Uint8List bytes;
  final String contentType;
}
