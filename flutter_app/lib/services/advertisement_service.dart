import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/advertisement.dart';

class AdvertisementService {
  final Dio _dio;

  AdvertisementService(this._dio);

  Future<List<Advertisement>> fetchAdvertisements() async {
    final response = await _dio.get(ApiEndpoints.advertisements);
    final data = response.data;
    if (data['success'] == true) {
      final List ads = data['data'] ?? data['advertisements'] ?? [];
      return ads.map((e) => Advertisement.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to load advertisements.');
    }
  }

  Future<Map<String, dynamic>> submitView(String adId) async {
    final response = await _dio.post(ApiEndpoints.advertisementView(adId));
    final data = response.data;
    if (data['success'] == true) {
      return {
        'message': data['message'] ?? 'Reward earned!',
        'rewardPoints': data['rewardPoints'] ?? 0,
      };
    } else {
      throw Exception(data['message'] ?? 'Failed to submit view.');
    }
  }
}

final advertisementServiceProvider = Provider<AdvertisementService>((ref) {
  return AdvertisementService(ref.watch(dioProvider));
});
