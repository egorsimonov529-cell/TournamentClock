import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';

class Transaction {
  final String id;
  final String? userId;
  final String type;
  final String description;
  final double amount;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    this.userId,
    required this.type,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      type: json['type'] as String? ?? 'general',
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TransactionsFilter {
  final String? type;
  final bool showAll;

  const TransactionsFilter({this.type, this.showAll = false});
}

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  String? _filterType;

  @override
  Future<List<Transaction>> build() async {
    return await load();
  }

  Future<List<Transaction>> load({String? filterType}) async {
    if (filterType != null) {
      _filterType = filterType;
    }

    try {
      final queryParams = <String, dynamic>{};
      if (_filterType != null && _filterType != 'all') {
        queryParams['type'] = _filterType!;
      }

      final response = await ApiService().get('/admin/transactions');
      final data = response.data;

      if (data is Map && data.containsKey('data')) {
        final listData = data['data'] as List;
        return listData
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Failed to fetch transactions: $e');
      return [];
    }
  }

  void setFilter(String? type) {
    _filterType = type;
    load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await load());
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  () => TransactionsNotifier(),
);
