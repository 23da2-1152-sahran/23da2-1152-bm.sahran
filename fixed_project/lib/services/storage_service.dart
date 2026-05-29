import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// StorageService handles Firebase Storage operations for image uploads
class StorageService {
  static final StorageService _instance = StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  StorageService._internal();

  /// Get singleton instance
  factory StorageService() {
    return _instance;
  }

  /// Upload profile image for a user
  /// Returns download URL
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final fileName =
          'profiles/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Upload product image (admin use)
  /// Returns download URL
  Future<String> uploadProductImage(String productId, File imageFile) async {
    try {
      final fileName =
          'products/$productId/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading product image: $e');
      rethrow;
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete user profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('profiles/$userId');
      await ref.listAll().then((list) async {
        for (var item in list.items) {
          await item.delete();
        }
      });
    } catch (e) {
      print('Error deleting profile images: $e');
      rethrow;
    }
  }
}
