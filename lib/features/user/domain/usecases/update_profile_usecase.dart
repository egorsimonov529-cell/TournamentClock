import '../../../../core/models/user.dart';
import '../repositories/user_repository_contract.dart';

class UpdateProfileUseCase {
  final UserRepositoryContract _repository;

  const UpdateProfileUseCase(this._repository);

  Future<User> call({required User user}) => _repository.updateProfile(user: user);
}
