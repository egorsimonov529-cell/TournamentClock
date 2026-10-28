import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/constants/app_constants.dart';
import '../../../features/tables/domain/providers/seating_provider.dart';

/// Provider для WebSocket соединения
final seatingWebSocketProvider = Provider<SeatingWebSocketService>((ref) {
  final service = SeatingWebSocketService(ref: ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Сервис для real-time обновлений рассадки
class SeatingWebSocketService {
  final Ref ref;
  io.Socket? _socket;
  final Map<String, String> _joinedTournaments = {};

  SeatingWebSocketService({required this.ref});
  
  /// Callback для принудительного обновления seating
  Function()? onSeatingUpdate;
  
  /// Callback для обновления статуса турнира
  Function()? onTournamentStatusUpdate;

  io.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected == true;

  /// Инициализация WebSocket соединения
  void init() {
    if (_socket != null && _socket!.connected) return;
    if (_socket != null) {
      // Already created, just reconnect
      _socket?.connect();
      return;
    }

    final baseUrl = AppConstants.apiBaseUrl;
    // Удаляем /api/v1 если есть, оставляем только host:port
    String wsUrl = baseUrl.replaceAll('/api/v1', '');
    
    print('[WS] Connecting to: $wsUrl');
    
    _socket = io.io(wsUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Cookie': ''}, // Для авторизации если нужно
    });

    _socket!.onConnect((_) {
      print('[WS] Connected: ${_socket!.id}');
      // Переподключаемся к турнирам
      for (final tournamentId in _joinedTournaments.keys) {
        _socket!.emit('join_tournament', tournamentId);
      }
    });

    _socket!.onDisconnect((_) {
      print('[WS] Disconnected');
    });

    _socket!.onConnectError((data) {
      print('[WS] Connect error: $data');
    });

    // Слушаем события обновления рассадки
    _socket!.on('seating_updated', (data) {
      print('[WS] Seating updated: $data');
      _handleSeatingUpdate(data);
    });

    // Слушаем события обновления статуса турнира
    _socket!.on('tournament_status_updated', (data) {
      print('[WS] Tournament status updated: $data');
      _handleTournamentStatusUpdate(data);
    });

    _socket!.connect();
  }

  /// Подключение к турниру
  void joinTournament(String tournamentId) {
    if (_socket == null || !_socket!.connected) {
      init();
    }

    if (_socket!.connected) {
      _socket!.emit('join_tournament', tournamentId);
      _joinedTournaments[tournamentId] = tournamentId;
      print('[WS] Joined tournament: $tournamentId');
    } else {
      // Если не подключены, добавляем в очередь
      _joinedTournaments[tournamentId] = tournamentId;
      print('[WS] Queued tournament: $tournamentId');
    }
  }

  /// Отключение от турнира
  void leaveTournament(String tournamentId) {
    if (_socket?.connected == true) {
      _socket!.emit('leave_tournament', tournamentId);
    }
    _joinedTournaments.remove(tournamentId);
    print('[WS] Left tournament: $tournamentId');
  }

  /// Обработка события обновления рассадки
  void _handleSeatingUpdate(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Вызываем callback если установлен
      if (onSeatingUpdate != null) {
        onSeatingUpdate!();
      }
    }
  }
  
  /// Обработка события обновления статуса турнира
  void _handleTournamentStatusUpdate(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (onTournamentStatusUpdate != null) {
        onTournamentStatusUpdate!();
      }
    }
  }

  /// Закрытие соединения
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _joinedTournaments.clear();
    onSeatingUpdate = null;
    onTournamentStatusUpdate = null;
  }
}

extension _MapEx on Map {
  get firstOrNull => isEmpty ? null : values.first;
}
