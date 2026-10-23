import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tournament_clock/core/constants/app_constants.dart';
import 'package:tournament_clock/core/services/secure_storage_service.dart';
import 'package:tournament_clock/core/ui/ios/ios_card.dart';
import '../../domain/models/player_model.dart';
import '../../../../core/models/rps_rank.dart';
import '../../../../core/ui/ios/ios_button.dart';
import '../../../auth/domain/providers/auth_state_provider.dart';

class IosProfilePage extends ConsumerStatefulWidget {
  final PlayerProfile player;

  const IosProfilePage({super.key, required this.player});

  @override
  ConsumerState<IosProfilePage> createState() => _IosProfilePageState();
}

class _IosProfilePageState extends ConsumerState<IosProfilePage> {
  bool _uploadingAvatar = false;

  Future<void> _uploadAvatar() async {
    try {
      setState(() => _uploadingAvatar = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );

      if (result == null || result.files.single.bytes == null) {
        return;
      }

      final bytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
      final token = await SecureStorageService().read('access_token');
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final file = MultipartFile.fromBytes(bytes, filename: fileName);
      final formData = FormData();
      formData.files.add(MapEntry('avatar', file));
      final response = await dio.post('/users/avatar', data: formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аватарка загружена')),
        );
        // Перезагружаем страницу для обновления аватарки
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  Future<void> _deleteAvatar() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
      final token = await SecureStorageService().read('access_token');
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      await dio.delete('/users/avatar');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аватарка удалена')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = widget.player.avatarUrl != null && widget.player.avatarUrl!.isNotEmpty;
    final displayName = widget.player.firstName?.isNotEmpty == true
      ? widget.player.firstName!
      : (widget.player.lastName?.isNotEmpty == true ? widget.player.lastName! : widget.player.login);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(displayName)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IosCard(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: hasAvatar ? NetworkImage(widget.player.avatarUrl!) : null,
                        backgroundColor: Colors.white12,
                        child: hasAvatar ? null : Text(widget.player.login.isNotEmpty ? widget.player.login[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _uploadAvatar,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.camera,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'RPS ${widget.player.rpsRank.label}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.player.rankPoints > 0 ? '${widget.player.rankPoints} rating' : '—',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (hasAvatar) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _deleteAvatar,
                      child: const Text(
                        'Удалить аватарку',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            IosCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.person),
                    title: const Text('Изменить профиль', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    onTap: () {
                      // TODO: Navigate to edit profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция в разработке')),
                      );
                    },
                  ),
                  const Divider(color: Colors.white12),
                  ListTile(
                    leading: const Icon(CupertinoIcons.lock),
                    title: const Text('Изменить пароль', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    onTap: () {
                      // TODO: Navigate to change password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция в разработке')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IosButton(
              label: 'Выйти из аккаунта',
              filled: false,
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
