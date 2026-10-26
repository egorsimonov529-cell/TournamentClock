import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_clock/core/constants/app_constants.dart';
import 'package:tournament_clock/core/services/secure_storage_service.dart';
import 'package:tournament_clock/core/ui/ios/ios_card.dart';
import '../../domain/models/player_model.dart';
import '../../../../core/models/rps_rank.dart';
import '../../../../core/ui/ios/ios_button.dart';
import '../../../../core/ui/ios/ios_input.dart';
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
      final token = await SecureStorageService().read('auth_access_token');
      if (token != null && token.isNotEmpty) {
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
      final token = await SecureStorageService().read('auth_access_token');
      if (token != null && token.isNotEmpty) {
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
    final displayName = widget.player.nickname?.isNotEmpty == true
      ? widget.player.nickname!
      : (widget.player.firstName?.isNotEmpty == true ? widget.player.firstName! : (widget.player.lastName?.isNotEmpty == true ? widget.player.lastName! : widget.player.login));
    
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
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => _IosProfileSettingsPage(player: widget.player),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white12),
                  ListTile(
                    leading: const Icon(CupertinoIcons.lock),
                    title: const Text('Изменить пароль', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => _IosChangePasswordPage(player: widget.player),
                        ),
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

// ===== iOS страница редактирования профиля =====
class _IosProfileSettingsPage extends ConsumerStatefulWidget {
  final PlayerProfile player;
  
  const _IosProfileSettingsPage({required this.player});

  @override
  ConsumerState<_IosProfileSettingsPage> createState() => _IosProfileSettingsPageState();
}

class _IosProfileSettingsPageState extends ConsumerState<_IosProfileSettingsPage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _nickname;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.player.firstName ?? '');
    _lastName = TextEditingController(text: widget.player.lastName ?? '');
    _nickname = TextEditingController(text: widget.player.nickname ?? '');
    _email = TextEditingController(text: widget.player.email ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nickname.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty && 
        _lastName.text.trim().isEmpty && 
        _nickname.text.trim().isEmpty) {
      _showMessage('Хотя бы одно поле должно быть заполнено');
      return;
    }

    setState(() => _saving = true);
    
    try {
      await ApiService().post('/users/profile', data: {
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'nickname': _nickname.text.trim(),
      });
      
      if (mounted) {
        _showMessage('Данные сохранены', isSuccess: true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String text, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isSuccess ? const Color(0xFF34C759) : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Редактировать профиль'),
        previousPageTitle: 'Назад',
        trailing: TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Сохранить',
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              IosCard(
                child: Column(
                  children: [
                    IosInput(
                      controller: _firstName,
                      placeholder: 'Имя',
                      prefixIcon: CupertinoIcons.person,
                    ),
                    const SizedBox(height: 12),
                    IosInput(
                      controller: _lastName,
                      placeholder: 'Фамилия',
                      prefixIcon: CupertinoIcons.person,
                    ),
                    const SizedBox(height: 12),
                    IosInput(
                      controller: _nickname,
                      placeholder: 'Никнейм',
                      prefixIcon: CupertinoIcons.at,
                    ),
                    const SizedBox(height: 12),
                    IosInput(
                      controller: _email,
                      placeholder: 'Email',
                      prefixIcon: CupertinoIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== iOS страница смены пароля =====
class _IosChangePasswordPage extends ConsumerStatefulWidget {
  final PlayerProfile player;
  
  const _IosChangePasswordPage({required this.player});

  @override
  ConsumerState<_IosChangePasswordPage> createState() => _IosChangePasswordPageState();
}

class _IosChangePasswordPageState extends ConsumerState<_IosChangePasswordPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPassword.text.trim();
    final next = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      _showMessage('Заполните все поля');
      return;
    }

    if (next.length < 6) {
      _showMessage('Новый пароль должен содержать минимум 6 символов');
      return;
    }

    if (current == next) {
      _showMessage('Новый пароль должен отличаться от текущего');
      return;
    }

    if (next != confirm) {
      _showMessage('Подтверждение пароля не совпадает');
      return;
    }

    setState(() => _saving = true);
    
    try {
      await ApiService().post('/auth/change-password', data: {
        'currentPassword': current,
        'newPassword': next,
      });
      
      if (mounted) {
        _showMessage('Пароль изменён', isSuccess: true);
        _currentPassword.clear();
        _newPassword.clear();
        _confirmPassword.clear();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Ошибка: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String text, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isSuccess ? const Color(0xFF34C759) : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Изменить пароль'),
        previousPageTitle: 'Назад',
        trailing: TextButton(
          onPressed: _saving ? null : _changePassword,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Изменить',
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              IosCard(
                child: Column(
                  children: [
                    IosInput(
                      controller: _currentPassword,
                      placeholder: 'Текущий пароль',
                      prefixIcon: CupertinoIcons.lock,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    IosInput(
                      controller: _newPassword,
                      placeholder: 'Новый пароль',
                      prefixIcon: CupertinoIcons.lock_fill,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    IosInput(
                      controller: _confirmPassword,
                      placeholder: 'Подтвердите пароль',
                      prefixIcon: CupertinoIcons.checkmark_seal,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Минимум 6 символов',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
