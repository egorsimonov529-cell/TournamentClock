import '../../../../core/models/user.dart';
import '../repositories/user_repository_contract.dart';

class GetProfileUseCase {
  final UserRepositoryContract _repository;

  const GetProfileUseCase(this._repository);

  Future<User?> call() => _repository.getProfile();
}
