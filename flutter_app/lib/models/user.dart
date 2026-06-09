import 'package:community_survey/models/admin_models.dart';

enum UserRole {
  user,
  admin,
  superAdmin;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }

  String toJson() => name;
}

class User {
  final String id;
  final String fullName;
  final String? mobile;
  final String? aadhaar;
  final UserRole role;
  final OrganizationConfig? organization;
  final String? organizationType;
  final String? state;
  final String? district;
  final String? city;
  final String? fathersName;
  final String? gender;
  final String? address;
  final String? pincode;
  final String? education;
  final String? occupation;
  final String? socialCategory;
  final int? walletBalance;
  final int? rewardPoints;
  final bool isActive;

  User({
    required this.id,
    required this.fullName,
    this.mobile,
    this.aadhaar,
    this.role = UserRole.user,
    this.organization,
    this.organizationType,
    this.state,
    this.district,
    this.city,
    this.fathersName,
    this.gender,
    this.address,
    this.pincode,
    this.education,
    this.occupation,
    this.socialCategory,
    this.walletBalance,
    this.rewardPoints,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobile: json['mobile'] as String?,
      aadhaar: json['aadhaar'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      organization: json['organizationId'] != null
          ? OrganizationConfig.fromJson(json['organizationId'] as Map<String, dynamic>)
          : json['organization'] != null
              ? OrganizationConfig.fromJson(json['organization'] as Map<String, dynamic>)
              : null,
      organizationType: json['organizationType'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      fathersName: json['fathersName'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
      education: json['education'] as String?,
      occupation: json['occupation'] as String?,
      socialCategory: json['socialCategory'] as String?,
      walletBalance: json['walletBalance'] as int?,
      rewardPoints: json['rewardPoints'] as int?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'mobile': mobile,
      'aadhaar': aadhaar,
      'role': role.toJson(),
      'organizationId': organization?.toJson(),
      'organizationType': organizationType,
      'state': state,
      'district': district,
      'city': city,
      'fathersName': fathersName,
      'gender': gender,
      'address': address,
      'pincode': pincode,
      'education': education,
      'occupation': occupation,
      'socialCategory': socialCategory,
      'walletBalance': walletBalance,
      'rewardPoints': rewardPoints,
      'isActive': isActive,
    };
  }
}
