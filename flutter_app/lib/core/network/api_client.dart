import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/features/auth/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = ref.read(authProvider).session;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    } else {
      final token = await ref.read(tokenStoreProvider).getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      if (response.statusCode == 401) {
        final data = response.data;
        final message = (data is Map && data.containsKey('message'))
            ? data['message'] as String
            : 'Session expired. Please log in again.';
        if (!err.requestOptions.path.contains('/auth')) {
          ref.read(authProvider.notifier).evictSession(message);
        }
      } else if (response.statusCode == 403) {
        final data = response.data;
        final message = (data is Map && data.containsKey('message'))
            ? data['message'] as String
            : 'Access forbidden.';
        if (err.requestOptions.path.contains('/auth')) {
          ref.read(authProvider.notifier).handleDeactivationDuringAuth(message);
        }
      }
    }
    handler.next(err);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
  ));
  return dio;
});

String getApiErrorMessage(dynamic error) {
  if (error is DioException) {
    final response = error.response;
    if (response != null && response.data is Map) {
      return response.data['message'] ?? 'Server error occurred.';
    }
    return error.message ?? 'Network error occurred.';
  }
  return error.toString().replaceAll('Exception: ', '');
}
