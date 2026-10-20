import '../models/achievement.dart';

abstract class AchievementsRepository {
  Future<List<Achievement>> fetchAchievements();
  Future<dynamic> createAchievement(Map<String, dynamic> data, {List<int>? imageBytes, String? imageName});
  Future<dynamic> updateAchievement(String id, Map<String, dynamic> data, {List<int>? imageBytes, String? imageName});
  Future<void> deleteAchievement(String id);
}
