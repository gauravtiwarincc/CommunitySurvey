import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/admin_models.dart';

class OrganizationService {
  final Dio _dio;
  OrganizationService(this._dio);

  Future<OrganizationConfig> fetchConfig(String code) async {
    final response = await _dio.get(
      ApiEndpoints.config,
      queryParameters: {'code': code},
    );
    final data = response.data;
    if (data['success'] == true) {
      return OrganizationConfig.fromJson(data['organization'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to load configuration.');
    }
  }
}

final organizationServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService(ref.watch(dioProvider));
});
