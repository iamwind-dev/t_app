import 'package:flutter/material.dart';

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
      return _ImageCard(
        imageUrl: widget.imageUrls.first,
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
                child: _ImageCard(
                  imageUrl: widget.imageUrls[index],
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

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.imageUrl, this.height});

  final String imageUrl;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: _MediaImage(path: imageUrl),
      ),
    );
  }
}

class _MediaImage extends StatelessWidget {
  const _MediaImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (_isRemotePath(path)) {
      return Image.network(path, fit: BoxFit.cover);
    }

    return Image.asset(path, fit: BoxFit.cover);
  }
}

bool _isRemotePath(String path) {
  final uri = Uri.tryParse(path);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.hasAuthority;
}
