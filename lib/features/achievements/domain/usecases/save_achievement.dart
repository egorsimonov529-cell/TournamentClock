import '../repositories/achievements_repository.dart';

class SaveAchievement {
  final AchievementsRepository repo;
  SaveAchievement(this.repo);

  Future<dynamic> call(Map<String, dynamic> data, {List<int>? imageBytes, String? imageName}) => repo.createAchievement(data, imageBytes: imageBytes, imageName: imageName);
}
