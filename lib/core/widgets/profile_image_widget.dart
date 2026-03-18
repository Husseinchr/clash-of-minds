import 'dart:convert';
import 'package:flutter/material.dart';

/// Widget to display profile images (both base64 and network URLs)
class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BoxFit fit;

  const ProfileImageWidget({
    super.key,
    this.imageUrl,
    this.size = 150,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if it's a base64 data URL
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    // Regular network image
    return Image.network(
      imageUrl!,
      fit: fit,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      size: size * 0.5,
      color: Colors.grey[400],
    );
  }
}
