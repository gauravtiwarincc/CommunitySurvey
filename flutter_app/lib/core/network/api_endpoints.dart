class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:3001/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String joinOrg = '/auth/join-org';

  // Config
  static const String config = '/config';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminSurveys = '/admin/surveys';
  static const String adminSurveyAnalytics = '/admin/surveys/analytics';
  static const String organizationTheme = '/organizations/theme';
  
  static String adminUserDetail(String id) => '/admin/users/$id';
  static String adminUserStatus(String id) => '/admin/users/$id/status';
  static String adminUserRole(String id) => '/admin/users/$id/role';
  static String adminArchiveSurvey(String id) => '/admin/surveys/$id/archive';

  // Advertisements
  static const String advertisements = '/advertisements';
  static String advertisementView(String id) => '/advertisements/$id/view';

  // Rewards
  static const String rewardItems = '/rewards/items';
  static const String redeemReward = '/rewards/redeem';

  // Participant Surveys
  static const String surveysDashboard = '/dashboard';
  static const String surveysList = '/surveys';
  static String surveyDetail(String id) => '/surveys/$id';
  static const String submitSurvey = '/surveys/submit';
}
