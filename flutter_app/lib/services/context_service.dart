import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/user_context.dart';

final contextServiceProvider = Provider<ContextService>((ref) {
  final dio = ref.watch(dioProvider);
  return ContextService(dio);
});

class ContextService {
  final Dio _dio;

  ContextService(this._dio);

  Future<List<UserContext>> getAvailableContexts() async {
    try {
      final response = await _dio.get(ApiEndpoints.availableContexts);
      final data = response.data;
      if (data['success'] == true) {
        final List contextsData = data['contexts'];
        return contextsData.map((e) => UserContext.fromJson(e)).toList();
      }
      throw Exception('Failed to load contexts');
    } catch (e) {
      throw Exception(getApiErrorMessage(e));
    }
  }
}
