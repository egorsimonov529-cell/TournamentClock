import '../../../../core/models/user.dart';

abstract class UserRepositoryContract {
  Future<User?> getProfile();
  Future<User> updateProfile({required User user});
}
