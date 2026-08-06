import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/player_model.dart';

// ============================================================================
// Player Profile Provider
// ============================================================================

/// Провайдер состояния профиля игрока
final playerProfileProvider =
    FutureProvider<PlayerProfile>((ref) async {
  // TODO: Реализовать вызов API для получения профиля игрока
  // Пока используем mock данные
  
  await Future.delayed(const Duration(milliseconds: 500));
  
  return PlayerProfile(
    userId: "player_001",
    login: "PokerStar123",
    email: "player@example.com",
    firstName: "Александр",
    lastName: "Иванов",
    avatarUrl: null,
    role: "player",
    level: 12,
    xp: 4500,
    xpToNextLevel: 5000,
    rank: 142,
    rankPoints: 2850,
    winRate: 12.5,
    totalTournaments: 24,
    totalWins: 3,
    totalPodiums: 8,
    totalProfit: 45200.0,
    averageScore: 18.5,
    balance: 12500.0,
    createdAt: DateTime(2025, 3, 15),
    lastLoginAt: DateTime.now(),
  );
});
