import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../repositories/user_repository_contract.dart';
import '../usecases/get_profile_usecase.dart';
import '../usecases/update_profile_usecase.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>(
  (ref) => UserRemoteDataSourceImpl(
    apiService: ref.watch(apiServiceProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
  ),
);

final userRepositoryProvider = Provider<UserRepositoryContract>(
  (ref) => UserRepositoryImpl(
    remoteDataSource: ref.watch(userRemoteDataSourceProvider),
  ),
);

final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.read(userRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.read(userRepositoryProvider)),
);

final currentUserProfileProvider = FutureProvider<User?>((ref) async {
  return ref.read(getProfileUseCaseProvider).call();
});
