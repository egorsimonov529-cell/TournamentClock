import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/achievements_remote_data_source.dart';
import '../../data/repositories/achievements_repository_impl.dart';
import '../../domain/models/achievement.dart';
import '../../../../core/services/api_service.dart';
import '../usecases/fetch_achievements.dart';
import '../usecases/save_achievement.dart';
import '../usecases/update_achievement.dart';
import '../usecases/delete_achievement.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final achievementsRemoteDataSourceProvider = Provider((ref) => AchievementsRemoteDataSource(ref.watch(apiServiceProvider)));
final achievementsRepositoryProvider = Provider((ref) => AchievementsRepositoryImpl(ref.watch(achievementsRemoteDataSourceProvider)));
final fetchAchievementsUsecaseProvider = Provider((ref) => FetchAchievements(ref.watch(achievementsRepositoryProvider)));

final saveAchievementUsecaseProvider = Provider((ref) => SaveAchievement(ref.watch(achievementsRepositoryProvider)));
final updateAchievementUsecaseProvider = Provider((ref) => UpdateAchievement(ref.watch(achievementsRepositoryProvider)));
final deleteAchievementUsecaseProvider = Provider((ref) => DeleteAchievement(ref.watch(achievementsRepositoryProvider)));

final achievementsListProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final uc = ref.watch(fetchAchievementsUsecaseProvider);
  return await uc();
});
