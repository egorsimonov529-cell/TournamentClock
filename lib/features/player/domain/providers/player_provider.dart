import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/rps_rank.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';
import '../models/player_model.dart';

/// Profile data is always built for the canonical authenticated user.
final playerProfileProvider = FutureProvider<PlayerProfile>((ref) async {
  final authUser = await ref.watch(currentAuthUserProvider.future);
  if (authUser == null) {
    throw StateError('Пользователь не авторизован');
  }

  return PlayerProfile(
    userId: authUser.id,
    login: authUser.login,
    email: authUser.email,
    firstName: authUser.firstName,
    lastName: authUser.lastName,
    avatarUrl: authUser.avatarUrl,
    role: authUser.role,
    level: 12,
    xp: 4500,
    xpToNextLevel: 5000,
    rank: 142,
    rankPoints: 650,
    rpsRank: RpsRank.grinder,
    winRate: 12.5,
    totalTournaments: 24,
    totalWins: 3,
    totalPodiums: 8,
    totalProfit: 45200,
    averageScore: 18.5,
    balance: 0,
    createdAt: authUser.createdAt ?? DateTime.now(),
    lastLoginAt: authUser.lastLoginAt ?? DateTime.now(),
  );
});
