import 'package:flutter_test/flutter_test.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/models/auth_session.dart';

void main() {
  group('AuthSession Model Decoding Tests', () {
    test('AuthSession decodes correctly using token key', () {
      final json = {
        'success': true,
        'token': 'my_jwt_token_123',
        'expiresAt': '2026-06-09T12:00:00Z',
        'user': {
          '_id': 'user-123',
          'mobile': '9876543210',
          'role': 'user',
        }
      };

      final session = AuthSession.fromJson(json);
      expect(session.accessToken, 'my_jwt_token_123');
      expect(session.user.id, 'user-123');
      expect(session.user.mobileNumber, '9876543210');
    });

    test('AuthSession decodes correctly using accessToken key', () {
      final json = {
        'success': true,
        'accessToken': 'my_jwt_token_456',
        'expiresAt': '2026-06-09T12:00:00Z',
        'user': {
          '_id': 'user-456',
          'mobile': '9876543210',
          'role': 'user',
        }
      };

      final session = AuthSession.fromJson(json);
      expect(session.accessToken, 'my_jwt_token_456');
    });
  });

  group('User Model Decoding Tests', () {
    test('User decodes isActive defaulting to true when omitted', () {
      final json = {
        '_id': 'user-1',
        'fullName': 'John Doe',
        'role': 'user',
      };

      final user = User.fromJson(json);
      expect(user.id, 'user-1');
      expect(user.fullName, 'John Doe');
      expect(user.isActive, true);
    });

    test('User decodes isActive as false when explicit', () {
      final json = {
        '_id': 'user-1',
        'fullName': 'John Doe',
        'role': 'user',
        'isActive': false,
      };

      final user = User.fromJson(json);
      expect(user.isActive, false);
    });
  });

  group('UserProfileInfo Model Decoding Tests', () {
    test('UserProfileInfo decodes isActive defaulting to true when omitted', () {
      final json = {
        '_id': 'user-2',
        'fullName': 'Jane Smith',
        'mobile': '9876543210',
        'aadhaar': 'XXXX XXXX 1234',
        'role': 'admin',
        'walletBalance': 500,
        'rewardPoints': 200,
        'createdAt': '2026-06-09T11:50:55Z',
      };

      final profile = UserProfileInfo.fromJson(json);
      expect(profile.id, 'user-2');
      expect(profile.fullName, 'Jane Smith');
      expect(profile.isActive, true);
    });

    test('UserProfileInfo decodes isActive as false when explicit', () {
      final json = {
        '_id': 'user-2',
        'fullName': 'Jane Smith',
        'mobile': '9876543210',
        'aadhaar': 'XXXX XXXX 1234',
        'role': 'admin',
        'walletBalance': 500,
        'rewardPoints': 200,
        'createdAt': '2026-06-09T11:50:55Z',
        'isActive': false,
      };

      final profile = UserProfileInfo.fromJson(json);
      expect(profile.isActive, false);
    });
  });
}
