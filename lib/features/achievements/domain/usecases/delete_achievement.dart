import '../repositories/achievements_repository.dart';

class DeleteAchievement {
  final AchievementsRepository repo;
  DeleteAchievement(this.repo);

  Future<void> call(String id) => repo.deleteAchievement(id);
}
