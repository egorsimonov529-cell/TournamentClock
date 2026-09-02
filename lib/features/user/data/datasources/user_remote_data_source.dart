import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/club_api_client.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';

abstract class UserRemoteDataSource {
  Future<User?> getProfile();
  Future<User> updateProfile({required User user});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;
  final ClubApiClient _apiClient;

  UserRemoteDataSourceImpl({
    required ApiService apiService,
    required SecureStorageService secureStorage,
    ClubApiClient? apiClient,
  }) : _apiService = apiService,
       _secureStorage = secureStorage,
       _apiClient = apiClient ?? ClubApiClient(apiService);

  @override
  Future<User?> getProfile() async {
    try {
      final user = await _apiClient.getProfile();
      await _secureStorage.write(
        key: AppConstants.demoSessionUserKey,
        value: jsonEncode(user.toJson()),
      );
      return user;
    } catch (_) {
      final payload = await _secureStorage.read(AppConstants.demoSessionUserKey);
      if (payload == null || payload.isEmpty) return null;

      try {
        return User.fromJson(jsonDecode(payload) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<User> updateProfile({required User user}) async {
    final updatedUser = await _apiClient.updateProfile(user: user);
    await _secureStorage.write(
      key: AppConstants.demoSessionUserKey,
      value: jsonEncode(updatedUser.toJson()),
    );
    return updatedUser;
  }
}
