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
}
