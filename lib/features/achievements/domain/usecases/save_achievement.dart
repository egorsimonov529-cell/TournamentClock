import '../repositories/achievements_repository.dart';

class SaveAchievement {
  final AchievementsRepository repo;
  SaveAchievement(this.repo);

  Future<dynamic> call(Map<String, dynamic> data, {String? imagePath}) => repo.createAchievement(data, imagePath: imagePath);
}
