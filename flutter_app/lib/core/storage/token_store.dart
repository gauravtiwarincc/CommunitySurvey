import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStoreProtocol {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class TokenStore implements TokenStoreProtocol {
  final _storage = const FlutterSecureStorage();
  static const _keyToken = 'jwt_access_token';

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  static const _keyContextType = 'active_context_type';
  static const _keyContextId = 'active_context_id';

  Future<void> saveActiveContext(String type, String id) async {
    await _storage.write(key: _keyContextType, value: type);
    await _storage.write(key: _keyContextId, value: id);
  }

  Future<Map<String, String>?> getActiveContext() async {
    final type = await _storage.read(key: _keyContextType);
    final id = await _storage.read(key: _keyContextId);
    if (type != null && id != null) {
      return {'contextType': type, 'contextId': id};
    }
    return null;
  }

  Future<void> clearActiveContext() async {
    await _storage.delete(key: _keyContextType);
    await _storage.delete(key: _keyContextId);
  }
}
