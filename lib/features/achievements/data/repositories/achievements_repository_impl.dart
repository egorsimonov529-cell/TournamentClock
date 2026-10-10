import '../../domain/models/achievement.dart';
import '../../domain/repositories/achievements_repository.dart';
import '../remote/achievements_remote_data_source.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  final AchievementsRemoteDataSource remote;
  AchievementsRepositoryImpl(this.remote);

  @override
  Future<List<Achievement>> fetchAchievements() async {
    final data = await remote.fetchAchievements();
    return (data as List).map((item) {
      if (item is Achievement) return item;
      if (item is Map<String, dynamic>) return Achievement.fromJson(item);
      throw Exception('Unexpected data format');
    }).toList();
  }

  @override
  Future<dynamic> createAchievement(Map<String, dynamic> data, {String? imagePath}) => remote.createAchievement(body: data, imagePath: imagePath);

  @override
  Future<dynamic> updateAchievement(String id, Map<String, dynamic> data, {String? imagePath}) => remote.updateAchievement(id, body: data, imagePath: imagePath);

  @override
  Future<void> deleteAchievement(String id) => remote.deleteAchievement(id);
}
