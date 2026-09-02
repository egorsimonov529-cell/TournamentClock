import '../repositories/achievements_repository.dart';

class UpdateAchievement {
  final AchievementsRepository repo;
  UpdateAchievement(this.repo);

  Future<dynamic> call(String id, Map<String, dynamic> data, {image}) => repo.updateAchievement(id, data, image: image);
}
