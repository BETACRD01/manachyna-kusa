// lib/shared/widgets/common/cached_network_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/image_cache_service.dart';

class CachedNetworkImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isCircular = false,
  });

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  String? _cachedImagePath;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _cachedImagePath = null;
    });

    try {
      final cachedPath = await ImageCacheService.getCachedImagePath(widget.imageUrl!);
      
      if (mounted) {
        setState(() {
          _cachedImagePath = cachedPath;
          _isLoading = false;
          _hasError = cachedPath == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child = _buildPlaceholder();
    } else if (_hasError || _cachedImagePath == null) {
      child = _buildErrorWidget();
    } else {
      child = Image.file(
        File(_cachedImagePath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    // Aplicar forma circular si es necesario
    if (widget.isCircular) {
      child = ClipOval(child: child);
    } else if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

  return SizedBox(
  width: widget.width,
  height: widget.height,
  child: child,
);

  }

  Widget _buildPlaceholder() {
    return widget.placeholder ?? Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: (widget.width ?? 50) * 0.5,
        color: Colors.grey[600],
      ),
    );
  }
}

// ============================================================
// AVATAR PROFILE CON CACHE
// ============================================================

class CachedProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;

  const CachedProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 25,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
        border: showBorder 
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        isCircular: true,
        fit: BoxFit.cover,
        placeholder: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Center(
            child: SizedBox(
              width: radius * 0.5,
              height: radius * 0.5,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          ),
        ),
        errorWidget: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Icon(
            Icons.person,
            size: radius,
            color: Colors.grey[600],
          ),
        ),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}