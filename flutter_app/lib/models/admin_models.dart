class OrganizationConfig {
  final String id;
  final String organizationName;
  final String organizationCode;
  final String organizationType;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String? welcomeMessage;
  final String? supportEmail;
  final String? logoUrl;
  final bool isActive;

  OrganizationConfig({
    required this.id,
    required this.organizationName,
    required this.organizationCode,
    required this.organizationType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.welcomeMessage,
    this.supportEmail,
    this.logoUrl,
    this.isActive = true,
  });

  factory OrganizationConfig.fromJson(Map<String, dynamic> json) {
    return OrganizationConfig(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? '',
      organizationCode: json['organizationCode'] as String? ?? '',
      organizationType: json['organizationType'] as String? ?? 'Corporate',
      primaryColor: json['primaryColor'] as String? ?? '#2C0977',
      secondaryColor: json['secondaryColor'] as String? ?? '#E6005E',
      accentColor: json['accentColor'] as String? ?? '#00B300',
      welcomeMessage: json['welcomeMessage'] as String?,
      supportEmail: json['supportEmail'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'organizationName': organizationName,
      'organizationCode': organizationCode,
      'organizationType': organizationType,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'welcomeMessage': welcomeMessage,
      'supportEmail': supportEmail,
      'logoUrl': logoUrl,
      'isActive': isActive,
    };
  }
}

class UserProfileInfo {
  final String id;
  final String fullName;
  final String mobile;
  final String aadhaar;
  final String role;
  final int walletBalance;
  final int rewardPoints;
  final String? state;
  final String? district;
  final String? city;
  final String createdAt;
  bool isActive;

  UserProfileInfo({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.aadhaar,
    required this.role,
    required this.walletBalance,
    required this.rewardPoints,
    this.state,
    this.district,
    this.city,
    required this.createdAt,
    this.isActive = true,
  });

  factory UserProfileInfo.fromJson(Map<String, dynamic> json) {
    return UserProfileInfo(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      aadhaar: json['aadhaar'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      walletBalance: json['walletBalance'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      state: json['state'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'mobile': mobile,
      'aadhaar': aadhaar,
      'role': role,
      'walletBalance': walletBalance,
      'rewardPoints': rewardPoints,
      'state': state,
      'district': district,
      'city': city,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}

class CompletedSurveyItem {
  final String surveyId;
  final String title;
  final int rewardPoints;
  final String completedAt;

  CompletedSurveyItem({
    required this.surveyId,
    required this.title,
    required this.rewardPoints,
    required this.completedAt,
  });

  factory CompletedSurveyItem.fromJson(Map<String, dynamic> json) {
    return CompletedSurveyItem(
      surveyId: json['surveyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      completedAt: json['completedAt'] as String? ?? '',
    );
  }
}

class PendingSurveyItem {
  final String surveyId;
  final String title;
  final int rewardPoints;

  PendingSurveyItem({
    required this.surveyId,
    required this.title,
    required this.rewardPoints,
  });

  factory PendingSurveyItem.fromJson(Map<String, dynamic> json) {
    return PendingSurveyItem(
      surveyId: json['surveyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      rewardPoints: json['rewardPoints'] as int? ?? 0,
    );
  }
}

class AdminUserItem {
  final String id;
  final String fullName;
  final String mobile;
  final String aadhaar;
  final String role;
  final int walletBalance;
  final int rewardPoints;
  final int completedSurveysCount;
  final String createdAt;

  AdminUserItem({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.aadhaar,
    required this.role,
    required this.walletBalance,
    required this.rewardPoints,
    required this.completedSurveysCount,
    required this.createdAt,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      aadhaar: json['aadhaar'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      walletBalance: json['walletBalance'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      completedSurveysCount: json['completedSurveysCount'] as int? ?? json['completedCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class PaginationInfo {
  final int totalUsers;
  final int totalPages;
  final int currentPage;
  final int limit;

  PaginationInfo({
    required this.totalUsers,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      currentPage: json['currentPage'] as int? ?? 1,
      limit: json['limit'] as int? ?? 15,
    );
  }
}

class AdminSurveyItem {
  final String id;
  final String title;
  final int rewardPoints;
  final bool isGlobal;
  final int completionCount;

  AdminSurveyItem({
    required this.id,
    required this.title,
    required this.rewardPoints,
    required this.isGlobal,
    required this.completionCount,
  });

  factory AdminSurveyItem.fromJson(Map<String, dynamic> json) {
    return AdminSurveyItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      isGlobal: json['isGlobal'] as bool? ?? false,
      completionCount: json['completionCount'] as int? ?? 0,
    );
  }
}

