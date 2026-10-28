import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tournament_clock/core/services/api_service.dart';
import 'package:tournament_clock/features/auth/domain/providers/auth_state_provider.dart';
import 'package:tournament_clock/features/player/domain/providers/player_provider.dart';
import 'package:tournament_clock/features/tables/domain/providers/seating_provider.dart';
import 'package:tournament_clock/features/tournament/domain/providers/tournament_provider.dart';

/// Глобальный сервис для принудительного обновления всех данных
final refreshServiceProvider = Provider<RefreshService>((ref) {
  return RefreshService(ref: ref);
});

class RefreshService {
  final Ref ref;
  
  RefreshService({required this.ref});
  
  /// Обновляет ВСЕ данные: профиль, турниры, рассадку
  void refreshAll() {
    try {
      // Обновляем профиль пользователя
      ref.invalidateAndRefresh(playerProfileProvider);
      
      // Обновляем турниры
      ref.invalidateAndRefresh(tournamentProvider);
      
      // Обновляем рассадку (если есть активные турниры)
      final tournaments = ref.read(tournamentProvider);
      for (final tournament in tournaments) {
        ref.invalidateAndRefresh(seatingProvider(tournament.id));
      }
    } catch (e) {
      print('[RefreshService] Ошибка обновления: $e');
    }
  }
  
  /// Обновляет только турниры и рассадку
  void refreshTournaments() {
    try {
      ref.invalidateAndRefresh(tournamentProvider);
      
      final tournaments = ref.read(tournamentProvider);
      for (final tournament in tournaments) {
        ref.invalidateAndRefresh(seatingProvider(tournament.id));
      }
    } catch (e) {
      print('[RefreshService] Ошибка обновления турниров: $e');
    }
  }
  
  /// Обновляет только профиль
  void refreshProfile() {
    try {
      ref.invalidateAndRefresh(playerProfileProvider);
    } catch (e) {
      print('[RefreshService] Ошибка обновления профиля: $e');
    }
  }
}

/// Extension для удобного вызова invalidateAndRefresh
extension RefExtension on Ref {
  void invalidateAndRefresh(ProviderBase provider) {
    invalidate(provider);
  }
}
