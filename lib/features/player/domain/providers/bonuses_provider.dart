import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';

class Bonus {
  final String id;
  final String title;
  final String description;
  final String type;
  final String value;
  final String conditions;
  final bool isActive;
  final DateTime createdAt;

  const Bonus({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.conditions,
    required this.isActive,
    required this.createdAt,
  });

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      value: json['value'] as String? ?? '',
      conditions: json['conditions'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BonusesFilter {
  final String tab;

  const BonusesFilter({this.tab = 'available'});
}

class BonusesNotifier extends AsyncNotifier<List<Bonus>> {
  String _currentTab = 'available';

  @override
  Future<List<Bonus>> build() async {
    return await load();
  }

  Future<List<Bonus>> load({String? tab}) async {
    if (tab != null) {
      _currentTab = tab;
    }

    try {
      final response = await ApiService().get('/bonuses');
      final data = response.data;

      if (data is List) {
        return data
            .map((json) => Bonus.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Failed to fetch bonuses: $e');
      return [];
    }
  }

  void setTab(String tab) {
    _currentTab = tab;
    load(tab: tab);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await load());
  }

  List<Bonus> getFilteredBonuses() {
    final bonuses = state.value ?? [];
    
    switch (_currentTab) {
      case 'active':
        return bonuses.where((b) => b.isActive).toList();
      case 'history':
        return []; // Future: filter by user redemption history
      case 'available':
      default:
        return bonuses.where((b) => b.isActive).toList();
    }
  }
}

final bonusesProvider =
    AsyncNotifierProvider<BonusesNotifier, List<Bonus>>(
  () => BonusesNotifier(),
);
