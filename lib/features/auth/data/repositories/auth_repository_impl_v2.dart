import '../../../../core/config/app_config.dart';
import '../../../../core/models/auth_exception.dart';
import '../../../../core/models/auth_response.dart';
import '../../../../core/models/user.dart';
import '../../domain/models/demo_session.dart';
import '../../domain/repositories/auth_repository_contract.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/session_local_data_source.dart';

class AuthRepositoryImplV2 implements AuthRepositoryContract {
  final AuthRemoteDataSource _remoteDataSource;
  final SessionLocalDataSource _localDataSource;
  final bool isDemoMode;

  const AuthRepositoryImplV2({
    required AuthRemoteDataSource remoteDataSource,
    required SessionLocalDataSource localDataSource,
    this.isDemoMode = AppConfig.useDemoAuth,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  User _demoUser(String login, {String? name}) {
    final normalized = login.trim().toLowerCase();
    final isAdmin = normalized == 'admin' || normalized.startsWith('admin@');
    final role = isAdmin ? 'admin' : 'player';
    final parts = name?.trim().split(RegExp(r'\s+')) ?? const <String>[];
    return User(
      id: isAdmin ? 'demo-admin' : 'demo-player',
      login: login.trim(),
      email: normalized.contains('@')
          ? normalized
          : '$normalized@pokerclub.demo',
      role: role,
      firstName: parts.isNotEmpty ? parts.first : (isAdmin ? 'Админ' : 'Игрок'),
      lastName: parts.length > 1 ? parts.skip(1).join(' ') : null,
    );
  }

  AuthResponse _demoResponse(User user) =>
      AuthResponse(accessToken: '', refreshToken: '', user: user);

  @override
  Future<AuthResponse> login({
    required String login,
    required String password,
    bool rememberMe = false,
  }) async {
    if (isDemoMode) {
      final response = _demoResponse(_demoUser(login));
      await _localDataSource.saveUser(response.user, rememberMe: rememberMe);
      return response;
    }

    return _remoteDataSource.login(
      login: login,
      password: password,
      rememberMe: rememberMe,
    );
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    if (isDemoMode) {
      final response = _demoResponse(_demoUser(email, name: name));
      await _localDataSource.saveUser(response.user, rememberMe: false);
      return response;
    }

    return _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      acceptedTerms: acceptedTerms,
    );
  }

  @override
  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    if (isDemoMode) {
      throw const TokenException();
    }

    return _remoteDataSource.refreshToken(refreshToken: refreshToken);
  }

  @override
  Future<void> requestPasswordReset({required String contact}) async {
    final normalized = contact.trim();
    if (normalized.isEmpty) {
      throw const ValidationException(
        message: 'Введите email или телефон',
        fieldErrors: {'contact': 'Введите email или телефон'},
      );
    }

    if (isDemoMode) return;

    await _remoteDataSource.requestPasswordReset(contact: normalized);
  }

  @override
  Future<void> logout() async {
    if (isDemoMode) {
      await _localDataSource.clearSession();
      return;
    }

    await _remoteDataSource.logout();
  }

  @override
  Future<DemoSession> restoreSession() async {
    if (isDemoMode) {
      return _localDataSource.restoreSession();
    }

    final user = await getCurrentUser();
    return user == null
        ? const DemoSession.anonymous()
        : DemoSession.authenticated(user);
  }

  @override
  Future<User?> checkSession() async {
    if (isDemoMode) {
      final session = await restoreSession();
      return session.user;
    }

    return await getCurrentUser();
  }

  @override
  Future<AuthResponse?> autoLogin() async {
    final session = await restoreSession();
    return session.user == null ? null : _demoResponse(session.user!);
  }

  @override
  Future<User?> getCurrentUser() async {
    if (isDemoMode) {
      return _localDataSource.getUser();
    }

    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearSession();
    await _remoteDataSource.logout();
  }
}
