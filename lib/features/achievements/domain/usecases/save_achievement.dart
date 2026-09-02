import '../repositories/achievements_repository.dart';

class SaveAchievement {
  final AchievementsRepository repo;
  SaveAchievement(this.repo);

  Future<dynamic> call(Map<String, dynamic> data, {image}) => repo.createAchievement(data, image: image);
}
