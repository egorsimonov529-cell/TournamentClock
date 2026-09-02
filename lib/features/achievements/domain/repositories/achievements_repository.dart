import '../models/achievement.dart';

abstract class AchievementsRepository {
  Future<List<Achievement>> fetchAchievements();
  Future<dynamic> createAchievement(Map<String, dynamic> data, {dynamic image});
  Future<dynamic> updateAchievement(String id, Map<String, dynamic> data, {dynamic image});
  Future<void> deleteAchievement(String id);
}
