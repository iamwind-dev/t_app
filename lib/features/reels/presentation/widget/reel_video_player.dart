import 'package:flutter/material.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isActive;

  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.isActive,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isPaused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initialize();
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _isPaused = false;
      _hasError = false;
      if (widget.isActive) {
        _initialize();
      }
      return;
    }

    if (!oldWidget.isActive && widget.isActive) {
      _disposeController();
      _isPaused = false;
      _hasError = false;
      _initialize();
      return;
    }

    if (oldWidget.isActive && !widget.isActive) {
      _disposeController();
      _isPaused = false;
      _hasError = false;
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _isPaused = true;
      } else {
        controller.play();
        _isPaused = false;
      }
    });
  }

  Future<void> _initialize() async {
    if (!widget.isActive) {
      return;
    }

    for (final candidate
        in BackendUrlNormalizer.videoPlaybackCandidates(widget.videoUrl)) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(candidate));
      try {
        await controller.initialize();
        await controller.setLooping(true);
        await controller.play();

        if (!mounted || !widget.isActive) {
          await controller.dispose();
          return;
        }

        setState(() {
          _controller = controller;
          _hasError = false;
          _isPaused = false;
        });
        return;
      } catch (_) {
        await controller.dispose();
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasError = true;
    });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Text(
          'Cannot load video',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
          if (_isPaused)
            const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white70,
                size: 90,
              ),
            ),
        ],
      ),
    );
  }
}
