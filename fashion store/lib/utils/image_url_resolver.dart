import 'package:flutter/foundation.dart';

/// Utility to resolve image URLs with CORS support for web
class ImageUrlResolver {
  /// CORS proxy service that handles images and adds proper headers
  /// This service works well for most image formats and handles CORS
  static const String _corsProxyBase = 'https://images.weserv.nl/';

  /// Check if we need CORS proxy (web platform)
  static bool _needsCorsProxy() {
    return kIsWeb;
  }

  /// Wrap external image URL with CORS proxy if needed
  static String resolveImageUrl(String originalUrl) {
    if (originalUrl.isEmpty) return originalUrl;

    // If not web, return original URL
    if (!_needsCorsProxy()) {
      return originalUrl;
    }

    // If it's a local asset, return as is
    if (!originalUrl.startsWith('http')) {
      return originalUrl;
    }

    // For web, wrap with CORS proxy
    // Using images.weserv.nl which handles CORS and optimizes images
    try {
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return '$_corsProxyBase?url=$encodedUrl&n=-1';
    } catch (e) {
      // If encoding fails, return original URL
      return originalUrl;
    }
  }

  /// Alternative: Use simple proxy wrapping (less reliable but faster)
  static String resolveImageUrlSimple(String originalUrl) {
    if (originalUrl.isEmpty || !_needsCorsProxy()) {
      return originalUrl;
    }

    if (!originalUrl.startsWith('http')) {
      return originalUrl;
    }

    // Simple URL rewriting for CORS proxy
    return '$_corsProxyBase?url=${Uri.encodeComponent(originalUrl)}';
  }
}
