import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/reward_item.dart';

class RewardService {
  final Dio _dio;

  RewardService(this._dio);

  Future<List<RewardItem>> fetchRewardItems() async {
    final response = await _dio.get(ApiEndpoints.rewardItems);
    final data = response.data;
    if (data['success'] == true) {
      final List items = data['data'] ?? data['items'] ?? [];
      return items.map((e) => RewardItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to load reward items.');
    }
  }

  Future<Map<String, dynamic>> redeemItem(String itemId) async {
    final response = await _dio.post(
      ApiEndpoints.redeemReward,
      data: {'itemId': itemId},
    );
    final data = response.data;
    if (data['success'] == true) {
      return data; // contains 'message' and 'updatedUser'
    } else {
      throw Exception(data['message'] ?? 'Failed to redeem item.');
    }
  }
}

final rewardServiceProvider = Provider<RewardService>((ref) {
  return RewardService(ref.watch(dioProvider));
});
