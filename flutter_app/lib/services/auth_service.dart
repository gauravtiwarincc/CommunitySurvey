import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/auth_session.dart';
import 'package:community_survey/models/user.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthSession> login({required String mobile, required String password}) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'mobile': mobile,
        'password': password,
      },
    );
    final data = response.data;
    if (data['success'] == true) {
      return AuthSession.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Login failed.');
    }
  }

  Future<AuthSession> register({
    required String fullName,
    String fathersName = '',
    required String gender,
    required String mobile,
    required String password,
    String aadhaar = '',
    required String address,
    String? organizationId,
    String? organizationName,
    String? organizationType,
    String? organizationCode,
    required String state,
    required String district,
    required String pincode,
    required String education,
    required String occupation,
    required String socialCategory,
    required String city,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'fathersName': fathersName,
        'gender': gender,
        'mobile': mobile,
        'password': password,
        if (aadhaar.isNotEmpty) 'aadhaar': aadhaar,
        'address': address,
        if (organizationId != null) 'organizationId': organizationId,
        if (organizationName != null) 'organizationName': organizationName,
        if (organizationType != null) 'organizationType': organizationType,
        if (organizationCode != null) 'organizationCode': organizationCode,
        'state': state,
        'district': district,
        'pincode': pincode,
        'education': education,
        'occupation': occupation,
        'socialCategory': socialCategory,
        'city': city,
      },
    );
    final data = response.data;
    if (data['success'] == true) {
      return AuthSession.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Registration failed.');
    }
  }

  Future<User> updateProfile({
    String? fullName,
    String? gender,
    String? aadhaar,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    String? education,
    String? occupation,
    String? socialCategory,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.profile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (gender != null) 'gender': gender,
        if (aadhaar != null) 'aadhaar': aadhaar,
        if (address != null) 'address': address,
        if (state != null) 'state': state,
        if (district != null) 'district': district,
        if (city != null) 'city': city,
        if (pincode != null) 'pincode': pincode,
        if (education != null) 'education': education,
        if (occupation != null) 'occupation': occupation,
        if (socialCategory != null) 'socialCategory': socialCategory,
      },
    );
    final data = response.data;
    if (data['success'] == true) {
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to update profile.');
    }
  }

  Future<User> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    final data = response.data;
    if (data['success'] == true) {
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to load profile.');
    }
  }

  Future<User> joinOrganization(String code) async {
    final response = await _dio.post(
      ApiEndpoints.joinOrg,
      data: {'organizationCode': code},
    );
    final data = response.data;
    if (data['success'] == true) {
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to join group.');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});
