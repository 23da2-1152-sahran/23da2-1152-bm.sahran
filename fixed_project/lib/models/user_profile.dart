/// UserProfile stores additional user information beyond Firebase Auth
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? shippingAddress;
  final String? city;
  final String? postalCode;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.profileImageUrl,
    this.shippingAddress,
    this.city,
    this.postalCode,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert UserProfile to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'shippingAddress': shippingAddress,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create UserProfile from Firestore Map
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      shippingAddress: map['shippingAddress'] as String?,
      city: map['city'] as String?,
      postalCode: map['postalCode'] as String?,
      country: map['country'] as String?,
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
    );
  }

  /// Create a copy with modified fields
  UserProfile copyWith({
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
    String? shippingAddress,
    String? city,
    String? postalCode,
    String? country,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
