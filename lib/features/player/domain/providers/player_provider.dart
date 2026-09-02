import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../models/player_model.dart';

/// Profile data is always built for the canonical authenticated user.
final playerProfileProvider = FutureProvider<PlayerProfile>((ref) async {
  final authUser = await ref.watch(currentAuthUserProvider.future);
  if (authUser == null) {
    throw StateError('Пользователь не авторизован');
  }

  try {
    final response = await ApiService().get('/users/profile');
    
    if (response.data is Map<String, dynamic>) {
      return PlayerProfile.fromApiJson(response.data as Map<String, dynamic>, authUser);
    }
  } catch (e) {
    print('Failed to fetch player profile from API: $e');
  }

  // Fallback to default profile
  return PlayerProfile(
    userId: authUser.id,
    login: authUser.login,
    email: authUser.email,
    firstName: authUser.firstName,
    lastName: authUser.lastName,
    avatarUrl: authUser.avatarUrl,
    role: authUser.role,
    level: 1,
    xp: 0,
    xpToNextLevel: 100,
    rank: 0,
    rankPoints: 0,
    rpsPoints: 0,
    rpsRank: RpsRank.fish,
    winRate: 0,
    totalTournaments: 0,
    totalWins: 0,
    totalPodiums: 0,
    totalProfit: 0,
    averageScore: 0,
    balance: 0,
    createdAt: authUser.createdAt ?? DateTime.now(),
    lastLoginAt: authUser.lastLoginAt ?? DateTime.now(),
  );
});
