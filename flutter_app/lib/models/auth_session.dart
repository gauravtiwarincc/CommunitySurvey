import 'package:community_survey/models/user.dart';
import 'package:community_survey/models/admin_models.dart';

class AuthenticatedUser {
  final String id;
  final String mobileNumber;
  final String countryCode;
  final UserRole role;
  final OrganizationConfig? organization;

  AuthenticatedUser({
    required this.id,
    required this.mobileNumber,
    required this.countryCode,
    required this.role,
    this.organization,
  });

  String? get organizationId => organization?.id;

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? json['mobile'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '+91',
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      organization: json['organization'] != null
          ? json['organization'] is String
              ? null
              : OrganizationConfig.fromJson(json['organization'] as Map<String, dynamic>)
          : json['organizationId'] != null
              ? json['organizationId'] is String
                  ? null
                  : OrganizationConfig.fromJson(json['organizationId'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'countryCode': countryCode,
      'role': role.toJson(),
      'organization': organization?.toJson(),
    };
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final AuthenticatedUser user;

  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired {
    return DateTime.now().add(const Duration(seconds: 60)).isAfter(expiresAt);
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(hours: 1)),
      user: AuthenticatedUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
