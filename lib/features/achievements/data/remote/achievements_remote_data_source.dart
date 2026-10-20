import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/services/api_service.dart';

class AchievementsRemoteDataSource {
  final ApiService api;
  AchievementsRemoteDataSource(this.api);

  Future<List<dynamic>> fetchAchievements() async {
    final res = await api.get('/achievements');
    return (res.data as List).cast<dynamic>();
  }

  Future<dynamic> createAchievement({
    required Map<String, dynamic> body,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final form = FormData.fromMap(Map.of(body));
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      try {
        form.files.add(MapEntry('image', MultipartFile.fromBytes(imageBytes, filename: imageName)));
      } catch (e) {
        // Ignored on web
      }
    }
    final res = await api.postMultipart('/achievements', form);
    return res.data;
  }

  Future<dynamic> updateAchievement(
    String id, {
    required Map<String, dynamic> body,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final form = FormData.fromMap(Map.of(body));
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      try {
        form.files.add(MapEntry('image', MultipartFile.fromBytes(imageBytes, filename: imageName)));
      } catch (e) {
        // Ignored on web
      }
    }
    final res = await api.putMultipart('/achievements/$id', form);
    return res.data;
  }

  Future<void> deleteAchievement(String id) async {
    await api.delete('/achievements/$id');
  }
}
