import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';

class LoyaltyData {
  final String level;
  final int currentPoints;
  final int requiredPoints;
  final String nextLevel;
  final int nextLevelRequired;
  final List<String> benefits;
  final List<LoyaltyCampaign> campaigns;

  const LoyaltyData({
    required this.level,
    required this.currentPoints,
    required this.requiredPoints,
    required this.nextLevel,
    required this.nextLevelRequired,
    required this.benefits,
    required this.campaigns,
  });
}

class LoyaltyCampaign {
  final String id;
  final String title;
  final String description;
  final bool isActive;

  const LoyaltyCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory LoyaltyCampaign.fromJson(Map<String, dynamic> json) {
    return LoyaltyCampaign(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? false,
    );
  }
}

class LoyaltyNotifier extends AsyncNotifier<LoyaltyData> {
  @override
  Future<LoyaltyData> build() async {
    return await load();
  }

  Future<LoyaltyData> load() async {
    final campaigns = await _fetchCampaigns();
    
    // Default data - will be replaced with real data when backend provides user loyalty info
    return LoyaltyData(
      level: 'Silver',
      currentPoints: 3200,
      requiredPoints: 10000,
      nextLevel: 'Gold',
      nextLevelRequired: 10000,
      benefits: [
        'Кэшбэк до 5%',
        'Приоритетная регистрация на турниры',
        'Персональные бонусы',
        'Приглашения на закрытые ивенты',
      ],
      campaigns: campaigns,
    );
  }

  Future<List<LoyaltyCampaign>> _fetchCampaigns() async {
    try {
      final response = await ApiService().get('/loyalty/campaigns');
      final data = response.data;
      
      if (data is List) {
        return data
            .map((json) => LoyaltyCampaign.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Failed to fetch loyalty campaigns: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await load());
  }
}

final loyaltyProvider =
    AsyncNotifierProvider<LoyaltyNotifier, LoyaltyData>(
  () => LoyaltyNotifier(),
);
