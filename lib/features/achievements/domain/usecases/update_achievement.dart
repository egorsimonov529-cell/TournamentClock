import '../repositories/achievements_repository.dart';

class UpdateAchievement {
  final AchievementsRepository repo;
  UpdateAchievement(this.repo);

  Future<dynamic> call(String id, Map<String, dynamic> data, {List<int>? imageBytes, String? imageName}) => repo.updateAchievement(id, data, imageBytes: imageBytes, imageName: imageName);
}
