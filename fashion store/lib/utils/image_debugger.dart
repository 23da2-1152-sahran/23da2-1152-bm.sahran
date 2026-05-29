import 'package:flutter/foundation.dart';

/// Debug tool to diagnose image loading issues on web vs mobile
class ImageDebugger {
  static void debugImageUrl(String imageUrl) {
    const isWeb = kIsWeb;
    final isNetworkImage = imageUrl.startsWith('http');
    final isAssetImage = imageUrl.startsWith('assets/');
    final isFirebaseUrl = imageUrl.contains('firebasestorage.googleapis.com');

    debugPrint('🔍 IMAGE DEBUG INFO');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('URL: $imageUrl');
    debugPrint('Platform: ${isWeb ? '🌐 WEB' : '📱 MOBILE'}');
    debugPrint('Image Type:');
    debugPrint('  - Network: $isNetworkImage');
    debugPrint('  - Asset: $isAssetImage');
    debugPrint('  - Firebase: $isFirebaseUrl');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (isWeb) {
      debugPrint('🌐 WEB PLATFORM DETECTED');
      if (isAssetImage) {
        debugPrint('✅ Asset path detected: Should work on web');
        debugPrint('   Make sure: assets/ is configured in pubspec.yaml');
      } else if (isNetworkImage && isFirebaseUrl) {
        debugPrint('✅ Firebase Storage URL detected');
        debugPrint('   Web requires CORS headers (already configured in web/index.html)');
      } else if (isNetworkImage) {
        debugPrint('⚠️  External URL detected');
        debugPrint('   Web has CORS restrictions for external URLs');
        debugPrint('   Solution: Use Firebase Storage URLs instead');
      }
    } else {
      debugPrint('📱 MOBILE PLATFORM DETECTED');
      if (isAssetImage) {
        debugPrint('✅ Asset path: Works on mobile');
      } else if (isNetworkImage) {
        debugPrint('✅ Network URL: Works on mobile (no CORS restrictions)');
      }
    }

    debugPrint('');
  }

  /// Generate test URL for debugging
  static String getTestAssetUrl(int productId) {
    return 'assets/sculptural_wool_overcoat.png';
  }
}
