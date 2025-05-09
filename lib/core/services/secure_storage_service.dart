import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage implements LocalStorage {
  final FlutterSecureStorage _secureStorage;
  static const _sessionKey = 'supabase_session';

  // Store session in memory for sync access
  String? _session;

  SecureLocalStorage([FlutterSecureStorage? secureStorage])
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initializes storage and loads any existing session
  @override
  Future<void> initialize() async {
    _session = await _secureStorage.read(key: _sessionKey);
  }

  /// Gets the current stored session
  Future<String?> getSession() async {
    return _session ?? await _secureStorage.read(key: _sessionKey);
  }

  /// Persists session to secure storage
  @override
  Future<void> persistSession(String session) async {
    _session = session;
    await _secureStorage.write(key: _sessionKey, value: session);
  }

  /// Removes the stored session
  @override
  Future<void> removePersistedSession() async {
    _session = null;
    await _secureStorage.delete(key: _sessionKey);
  }

  /// Gets current access token
  @override
  Future<String?> accessToken() async {
    return _session;
  }

  /// Checks if access token exists
  @override
  Future<bool> hasAccessToken() async {
    final token = await getSession();
    return token != null;
  }

  // Helper methods for general secure storage
  Future<String?> read(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> write(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }

  Future<void> delete(String key) {
    return _secureStorage.delete(key: key);
  }

  /// Gets all stored key/value pairs
  Future<Map<String, String>> getAll() async {
    return await _secureStorage.readAll();
  }

  /// Clears all stored data
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
    _session = null;
  }
}
