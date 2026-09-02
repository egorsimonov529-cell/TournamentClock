import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';

class AdminTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime createdAt;

  const AdminTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  factory AdminTransaction.fromJson(Map<String, dynamic> json) =>
      AdminTransaction(
        id: json['id'] as String? ?? '',
        description: json['description'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
  };
}

class LoyaltyCampaign {
  final String id;
  final String title;
  final String description;
  final bool active;

  const LoyaltyCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.active,
  });

  factory LoyaltyCampaign.fromJson(Map<String, dynamic> json) => LoyaltyCampaign(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    active: json['active'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'active': active,
  };

  LoyaltyCampaign copyWith({bool? active}) => LoyaltyCampaign(
    id: id,
    title: title,
    description: description,
    active: active ?? this.active,
  );
}

class AdminWorkspaceState {
  final List<AdminTransaction> transactions;
  final List<LoyaltyCampaign> campaigns;
  final String clubName;
  final String clubShortName;
  final String logoAssetPath;
  final String currency;
  final bool notificationsEnabled;
  final String? address;
  final String? city;

  const AdminWorkspaceState({
    required this.transactions,
    required this.campaigns,
    required this.clubName,
    required this.clubShortName,
    required this.logoAssetPath,
    required this.currency,
    required this.notificationsEnabled,
    this.address,
    this.city,
  });

  factory AdminWorkspaceState.fromJson(Map<String, dynamic> json) =>
      AdminWorkspaceState(
        transactions: (json['transactions'] as List<dynamic>? ?? const [])
            .map((item) => AdminTransaction.fromJson(item as Map<String, dynamic>))
            .toList(),
        campaigns: (json['campaigns'] as List<dynamic>? ?? const [])
            .map((item) => LoyaltyCampaign.fromJson(item as Map<String, dynamic>))
            .toList(),
        clubName: json['club_name'] as String? ?? '',
        clubShortName: json['club_short_name'] as String? ?? '',
        logoAssetPath: json['logo_asset_path'] as String? ?? '',
        currency: json['currency'] as String? ?? 'RUB',
        notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
        address: json['address'] as String?,
        city: json['city'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'club_name': clubName,
    'club_short_name': clubShortName,
    'logo_asset_path': logoAssetPath,
    'currency': currency,
    'notifications_enabled': notificationsEnabled,
    'transactions': transactions.map((item) => item.toJson()).toList(),
    'campaigns': campaigns.map((item) => item.toJson()).toList(),
    'address': address,
    'city': city,
  };

  AdminWorkspaceState copyWith({
    List<AdminTransaction>? transactions,
    List<LoyaltyCampaign>? campaigns,
    String? clubName,
    String? clubShortName,
    String? logoAssetPath,
    String? currency,
    bool? notificationsEnabled,
    String? address,
    String? city,
  }) => AdminWorkspaceState(
    transactions: transactions ?? this.transactions,
    campaigns: campaigns ?? this.campaigns,
    clubName: clubName ?? this.clubName,
    clubShortName: clubShortName ?? this.clubShortName,
    logoAssetPath: logoAssetPath ?? this.logoAssetPath,
    currency: currency ?? this.currency,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    address: address ?? this.address,
    city: city ?? this.city,
  );
}

class AdminWorkspaceNotifier extends StateNotifier<AdminWorkspaceState> {
  AdminWorkspaceNotifier()
    : super(
        AdminWorkspaceState(
          transactions: [
            AdminTransaction(
              id: 'tx-1',
              description: 'Взносы за турниры',
              amount: 185000,
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
            AdminTransaction(
              id: 'tx-2',
              description: 'Выплата призового фонда',
              amount: -120000,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          campaigns: const [
            LoyaltyCampaign(
              id: 'welcome',
              title: 'Приветственный бонус',
              description: '500 бонусных баллов новым игрокам',
              active: true,
            ),
            LoyaltyCampaign(
              id: 'weekly',
              title: 'Еженедельный кэшбэк',
              description: '5% от турнирных взносов',
              active: false,
            ),
          ],
          clubName: 'Poker Club ERM',
          clubShortName: 'ERM',
          logoAssetPath: 'assets/logos/logo_white.svg',
          currency: 'RUB',
          notificationsEnabled: true,
        ),
      );

  Future<void> addTransaction(String description, double amount) async {
    final newTx = AdminTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      createdAt: DateTime.now(),
    );
    
    try {
      final response = await ApiService().post('/admin/transactions', data: {
        'description': description,
        'amount': amount,
      });
      
      if (response.data != null && response.data['id'] != null) {
        final created = AdminTransaction.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(
          transactions: [created, ...state.transactions],
        );
      } else {
        // Если бэкенд не вернул ID — используем локальный
        state = state.copyWith(
          transactions: [newTx, ...state.transactions],
        );
      }
    } catch (e) {
      print('Ошибка добавления транзакции: $e');
      // Даже если бэкенд упал — добавляем локально
      state = state.copyWith(
        transactions: [newTx, ...state.transactions],
      );
    }
  }

  void toggleCampaign(String id, bool active) {
    state = state.copyWith(
      campaigns: state.campaigns
          .map(
            (campaign) => campaign.id == id
                ? campaign.copyWith(active: active)
                : campaign,
          )
          .toList(),
    );
  }

  Future<void> saveSettings({
    required String clubName,
    required String clubShortName,
    required String logoAssetPath,
    required String currency,
    required bool notificationsEnabled,
    String? address,
    String? city,
  }) async {
    // Keep previous state to allow rollback on failure
    final prev = state;
    state = state.copyWith(
      clubName: clubName.trim(),
      clubShortName: clubShortName.trim(),
      logoAssetPath: logoAssetPath.trim(),
      currency: currency,
      notificationsEnabled: notificationsEnabled,
      address: address,
      city: city,
    );

    // Persist to backend
    try {
      await ApiService().post('/admin/workspace', data: {
        'club_name': clubName.trim(),
        'club_short_name': clubShortName.trim(),
        'logo_asset_path': logoAssetPath.trim(),
        'currency': currency,
        'notifications_enabled': notificationsEnabled,
        'address': address,
        'city': city,
      });
    } catch (e) {
      // Rollback local state on failure
      state = prev;
      rethrow;
    }
  }
}

final adminWorkspaceProvider =
    StateNotifierProvider<AdminWorkspaceNotifier, AdminWorkspaceState>(
      (ref) => AdminWorkspaceNotifier(),
    );
