import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ThreadMediaSection extends StatefulWidget {
  const ThreadMediaSection({super.key, required this.imageUrls});

  final List<String> imageUrls;

  static const double singleImageHeight = 240;
  static const double multiImageHeight = 220;
  static const double multiImageGap = 12;
  static const double indicatorSpacing = 10;
  static const double indicatorDotSize = 6;
  static const double indicatorHeight = indicatorDotSize;

  static double heightForCount(int count) {
    if (count <= 0) {
      return 0;
    }

    if (count == 1) {
      return singleImageHeight;
    }

    return multiImageHeight + indicatorSpacing + indicatorHeight;
  }

  @override
  State<ThreadMediaSection> createState() => _ThreadMediaSectionState();
}

class _ThreadMediaSectionState extends State<ThreadMediaSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.imageUrls.length == 1) {
      return _MediaCard(
        mediaUrl: widget.imageUrls.first,
        height: ThreadMediaSection.singleImageHeight,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: ThreadMediaSection.multiImageHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              if (_currentPage == index) {
                return;
              }

              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.imageUrls.length - 1
                      ? 0
                      : ThreadMediaSection.multiImageGap,
                ),
                child: _MediaCard(
                  mediaUrl: widget.imageUrls[index],
                  height: ThreadMediaSection.multiImageHeight,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: ThreadMediaSection.indicatorSpacing),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({required this.mediaUrl, this.height});

  final String mediaUrl;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: _MediaSurface(path: mediaUrl),
      ),
    );
  }
}

class _MediaSurface extends StatelessWidget {
  const _MediaSurface({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (_isVideoPath(path)) {
      return _MediaVideo(path: path);
    }

    return _MediaImage(path: path);
  }
}

class _MediaImage extends StatelessWidget {
  const _MediaImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (_isRemotePath(path)) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const _MediaErrorPlaceholder(
            icon: Icons.broken_image_outlined,
            label: 'Cannot load image',
          );
        },
      );
    }

    return Image.asset(path, fit: BoxFit.cover);
  }
}

class _MediaVideo extends StatefulWidget {
  const _MediaVideo({required this.path});

  final String path;

  @override
  State<_MediaVideo> createState() => _MediaVideoState();
}

class _MediaVideoState extends State<_MediaVideo> {
  VideoPlayerController? _controller;
  bool _hasError = false;
  bool _isPaused = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final controller = _isRemotePath(widget.path)
          ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
          : VideoPlayerController.asset(widget.path);

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
      if (!mounted) {
        return;
      }
      setState(() {
        _isPaused = true;
      });
      return;
    }

    await controller.play();
    if (!mounted) {
      return;
    }
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const _MediaErrorPlaceholder(
        icon: Icons.videocam_off_rounded,
        label: 'Cannot load video',
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.28),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              _isPaused ? Icons.play_circle_fill_rounded : Icons.pause_circle,
              size: 52,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaErrorPlaceholder extends StatelessWidget {
  const _MediaErrorPlaceholder({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isRemotePath(String path) {
  final uri = Uri.tryParse(path);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.hasAuthority;
}

bool _isVideoPath(String path) {
  final normalizedPath = path.split('?').first.toLowerCase();
  return normalizedPath.endsWith('.mp4') ||
      normalizedPath.endsWith('.mov') ||
      normalizedPath.endsWith('.m4v') ||
      normalizedPath.endsWith('.webm');
}
