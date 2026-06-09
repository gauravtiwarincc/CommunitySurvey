class ApiEndpoints {
  static const String baseUrl = 'https://thesentinel.in/api';

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
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
  static String adminArchiveSurvey(String id) => '/admin/surveys/$id/archive';

  // Participant Surveys
  static const String surveysDashboard = '/dashboard';
  static const String surveysList = '/surveys';
  static String surveyDetail(String id) => '/surveys/$id';
  static String submitSurvey(String id) => '/surveys/$id/submit';
}
