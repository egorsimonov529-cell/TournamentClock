import '../../../../core/models/user.dart';
import '../datasources/user_remote_data_source.dart';
import '../../domain/repositories/user_repository_contract.dart';

class UserRepositoryImpl implements UserRepositoryContract {
  final UserRemoteDataSource _remoteDataSource;

  const UserRepositoryImpl({required UserRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<User?> getProfile() => _remoteDataSource.getProfile();

  @override
  Future<User> updateProfile({required User user}) =>
      _remoteDataSource.updateProfile(user: user);
}
