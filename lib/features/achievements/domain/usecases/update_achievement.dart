import '../repositories/achievements_repository.dart';

class UpdateAchievement {
  final AchievementsRepository repo;
  UpdateAchievement(this.repo);

  Future<dynamic> call(String id, Map<String, dynamic> data, {String? imagePath}) => repo.updateAchievement(id, data, imagePath: imagePath);
}
