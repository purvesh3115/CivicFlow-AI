import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class EvidenceImageViewer extends StatefulWidget {
  final String? imagePathOrUrl;
  final List<String>? attachments;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableZoom;
  final Widget? overlay;
  final String? title;

  const EvidenceImageViewer({
    super.key,
    this.imagePathOrUrl,
    this.attachments,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableZoom = true,
    this.overlay,
    this.title,
  });

  @override
  State<EvidenceImageViewer> createState() => _EvidenceImageViewerState();
}

class _EvidenceImageViewerState extends State<EvidenceImageViewer> {
  int _currentIndex = 0;

  List<String> get _allImages {
    final list = <String>[];
    if (widget.imagePathOrUrl != null &&
        widget.imagePathOrUrl!.trim().isNotEmpty) {
      list.add(widget.imagePathOrUrl!.trim());
    }
    if (widget.attachments != null) {
      for (final att in widget.attachments!) {
        final clean = att.trim();
        if (clean.isNotEmpty && !list.contains(clean)) {
          list.add(clean);
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    if (images.isEmpty) {
      return _buildPlaceholder(radius);
    }

    final activeSource = images[_currentIndex.clamp(0, images.length - 1)];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: widget.enableZoom
              ? () => _openFullScreenViewer(context, images, _currentIndex)
              : null,
          child: ClipRRect(
            borderRadius: radius,
            child: Container(
              height: widget.height,
              width: widget.width,
              color: AppColors.surfaceContainerLow,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildSingleImage(activeSource, widget.fit),
                  if (widget.overlay != null) widget.overlay!,
                  if (widget.enableZoom)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to Zoom',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (images.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1}/${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant.withAlpha(80),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildSingleImage(images[index], BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleImage(String source, BoxFit fit) {
    // 1. Network Image
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorState(),
      );
    }

    // 2. Asset Image
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorState(),
      );
    }

    // 3. Local File (Mobile & Desktop)
    if (!kIsWeb) {
      try {
        final file = File(source);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorState(),
          );
        }
      } catch (_) {
        // Fallback below
      }
    }

    // 4. Default fallback
    return _buildErrorState();
  }

  Widget _buildPlaceholder(BorderRadius radius) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxHeight < 90 || constraints.maxWidth < 90;
        return ClipRRect(
          borderRadius: radius,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceContainerLow,
                  AppColors.surfaceContainerHigh,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: isSmall
                  ? const Icon(
                      Icons.image_not_supported_outlined,
                      size: 22,
                      color: AppColors.primary,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Evidence Photo Attached',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No visual files were submitted for this record',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxHeight < 80 || constraints.maxWidth < 80;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: isSmall
                ? const Icon(
                    Icons.broken_image_rounded,
                    size: 20,
                    color: Colors.white70,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 32,
                        color: Colors.white.withAlpha(120),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unable to load photo',
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _openFullScreenViewer(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
          title: widget.title ?? 'Complaint Evidence',
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _renderImage(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white70, size: 64),
        ),
      );
    }
    if (source.startsWith('assets/')) {
      return Image.asset(source, fit: BoxFit.contain);
    }
    if (!kIsWeb) {
      try {
        final file = File(source);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.contain);
        }
      } catch (_) {}
    }
    return const Center(
      child: Icon(Icons.broken_image, color: Colors.white70, size: 64),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.images.length > 1)
              Text(
                'Photo ${_activeIndex + 1} of ${widget.images.length}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (idx) => setState(() => _activeIndex = idx),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: _renderImage(widget.images[index]),
            ),
          );
        },
      ),
    );
  }
}
