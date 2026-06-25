class UserContext {
  final String contextType; // "PROFILE" or "GROUP"
  final String contextId;
  final String displayName;
  final String? role;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? inviteCode;

  UserContext({
    required this.contextType,
    required this.contextId,
    required this.displayName,
    this.role,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.inviteCode,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      contextType: json['contextType'] as String,
      contextId: json['contextId'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String?,
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      inviteCode: json['inviteCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contextType': contextType,
      'contextId': contextId,
      'displayName': displayName,
      'role': role,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'inviteCode': inviteCode,
    };
  }
}
