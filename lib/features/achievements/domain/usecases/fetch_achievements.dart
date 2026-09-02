import '../models/achievement.dart';
import '../repositories/achievements_repository.dart';

class FetchAchievements {
  final AchievementsRepository repo;
  FetchAchievements(this.repo);

  Future<List<Achievement>> call() => repo.fetchAchievements();
}
