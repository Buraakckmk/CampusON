class UserModel {
  final String uid;
  final String email;
  final String universityDomain;
  final bool isVerified;
  final int level;

  UserModel({
    required this.uid,
    required this.email,
    required this.universityDomain,
    required this.isVerified,
    required this.level,
  });

  // Factory to create User from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      universityDomain: map['university_domain'] ?? '',
      isVerified: map['is_verified'] ?? false,
      level: map['level']?.toInt() ?? 1,
    );
  }

  // Parse domain from email helper
  static String parseDomain(String email) {
    final parts = email.split('@');
    if (parts.length > 1) {
      return parts[1];
    }
    return '';
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'university_domain': universityDomain,
      'is_verified': isVerified,
      'level': level,
    };
  }
}
