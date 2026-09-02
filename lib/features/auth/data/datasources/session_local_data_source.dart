import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/models/demo_session.dart';

abstract class SessionLocalDataSource {
  Future<void> saveUser(User user, {required bool rememberMe});
  Future<User?> getUser();
  Future<DemoSession> restoreSession();
  Future<void> clearSession();
  Future<bool> shouldRememberSession();
}

class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  final SharedPrefsService _sharedPrefs;

  const SessionLocalDataSourceImpl({required SharedPrefsService sharedPrefs})
    : _sharedPrefs = sharedPrefs;

  @override
  Future<void> saveUser(User user, {required bool rememberMe}) async {
    await _sharedPrefs.setString(
      AppConstants.demoSessionUserKey,
      jsonEncode(user.toJson()),
    );
    await _sharedPrefs.setBool(AppConstants.rememberMeKey, rememberMe);
    if (rememberMe) {
      await _sharedPrefs.setString(AppConstants.savedLoginKey, user.login);
    } else {
      await _sharedPrefs.remove(AppConstants.savedLoginKey);
    }
  }

  @override
  Future<User?> getUser() async {
    await _sharedPrefs.init();
    final payload = _sharedPrefs.getString(AppConstants.demoSessionUserKey);
    if (payload == null || payload.isEmpty) return null;

    try {
      return User.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DemoSession> restoreSession() async {
    await _sharedPrefs.init();
    final rememberMe = _sharedPrefs.getBool(AppConstants.rememberMeKey) == true;
    if (!rememberMe) {
      return const DemoSession.anonymous();
    }

    final user = await getUser();
    return user == null
        ? const DemoSession.anonymous()
        : DemoSession.authenticated(user);
  }

  @override
  Future<void> clearSession() async {
    await _sharedPrefs.remove(AppConstants.rememberMeKey);
    await _sharedPrefs.remove(AppConstants.savedLoginKey);
    await _sharedPrefs.remove(AppConstants.demoSessionUserKey);
  }

  @override
  Future<bool> shouldRememberSession() async {
    await _sharedPrefs.init();
    return _sharedPrefs.getBool(AppConstants.rememberMeKey) == true;
  }
}
