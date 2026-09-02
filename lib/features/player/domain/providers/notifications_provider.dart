import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool read;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['body'] as String? ?? '',
      time: json['created_at']?.toString() ?? '',
      read: json['read'] as bool? ?? false,
    );
  }
}

final notificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  try {
    // Пытаемся загрузить уведомления с бэкенда
    final res = await ApiService().get('/notifications');
    if (res.data is List) {
      return (res.data as List)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return const [];
  } catch (e) {
    print('Ошибка загрузки уведомлений: $e');
    // Если нет эндпоинта уведомлений — возвращаем пустой список
    return const [];
  }
});
