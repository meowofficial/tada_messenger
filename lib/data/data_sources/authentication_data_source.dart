import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthenticationDataSource {
  Future<String?> getStoredUsername();

  Future<void> storeUsername(String username);

  Future<void> removeStoredUsername();
}

class AuthenticationDataSourceImpl implements AuthenticationDataSource {
  const AuthenticationDataSourceImpl({
    required this.sharedPreferences,
  });

  static const _usernameKey = 'username';
  final SharedPreferences sharedPreferences;

  @override
  Future<String?> getStoredUsername() {
    return Future.value(sharedPreferences.get(_usernameKey) as String?);
  }

  @override
  Future<void> storeUsername(String username) async {
    await sharedPreferences.setString(_usernameKey, username);
  }

  @override
  Future<void> removeStoredUsername() async {
    await sharedPreferences.remove(_usernameKey);
  }
}
