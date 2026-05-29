import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to migrate external image URLs to Firebase Storage
class ImageMigrationService {
  static final ImageMigrationService _instance =
      ImageMigrationService._internal();

  ImageMigrationService._internal();

  factory ImageMigrationService() => _instance;

  /// Update product image URL in Firestore
  /// This converts external image URLs to Firebase Storage URLs
  Future<void> updateProductImageUrl(
    String productId,
    String newImageUrl,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'image': newImageUrl,
        'imageUrl': newImageUrl, // Keep both for backward compatibility
      });
      print('✓ Product $productId image updated');
    } catch (e) {
      print('Error updating product image: $e');
      rethrow;
    }
  }

  /// Guide: How to upload and update product images
  /// 
  /// Example usage:
  /// ```dart
  /// // 1. Upload image file to Firebase Storage
  /// File imageFile = File('path/to/image.jpg');
  /// String downloadUrl = 
  ///     await StorageService().uploadProductImage('product_id', imageFile);
  /// 
  /// // 2. Update Firestore product document with new URL
  /// await ImageMigrationService().updateProductImageUrl(
  ///   'product_id',
  ///   downloadUrl,
  /// );
  /// ```
}
