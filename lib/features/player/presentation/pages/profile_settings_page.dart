import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ios/ios_input.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_button.dart';
import '../../domain/models/player_model.dart';
// profile_text_field replaced by iOS inputs

class ProfileSettingsPage extends StatefulWidget {
  final PlayerProfile player;

  const ProfileSettingsPage({super.key, required this.player});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _profileKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _login;
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.player.firstName);
    _lastName = TextEditingController(text: widget.player.lastName);
    _email = TextEditingController(text: widget.player.email);
    _login = TextEditingController(text: widget.player.login);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _login.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileKey.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _savingProfile = false);
    _message('Данные профиля сохранены');
  }

  Future<void> _changePassword() async {
    if (!_passwordKey.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _currentPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
    setState(() => _savingPassword = false);
    _message('Пароль изменён');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 650;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Настройки профиля',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки профиля',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Управляйте своими данными и настройками',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _section(
              title: 'Личные данные',
              child: Form(
                key: _profileKey,
                child: Column(
                  children: [
                    if (compact) ...[
                      IosInput(controller: _firstName, placeholder: 'Имя'),
                      const SizedBox(height: 12),
                      IosInput(controller: _lastName, placeholder: 'Фамилия'),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: IosInput(
                              controller: _firstName,
                              placeholder: 'Имя',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: IosInput(
                              controller: _lastName,
                              placeholder: 'Фамилия',
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    IosInput(controller: _email, placeholder: 'Email'),
                    const SizedBox(height: 12),
                    IosInput(controller: _login, placeholder: 'Логин'),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: _savingProfile
                          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                          : IosButton(label: 'Сохранить', onPressed: _saveProfile),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _section(
              title: 'Безопасность',
              child: Form(
                key: _passwordKey,
                child: Column(
                  children: [
                    IosInput(controller: _currentPassword, placeholder: 'Текущий пароль', obscure: true),
                    const SizedBox(height: 12),
                    IosInput(controller: _newPassword, placeholder: 'Новый пароль', obscure: true),
                    const SizedBox(height: 12),
                    IosInput(controller: _confirmPassword, placeholder: 'Подтвердите пароль', obscure: true),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: _savingPassword
                          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                          : IosButton(label: 'Изменить пароль', onPressed: _changePassword),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) => IosCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );

  // Buttons are rendered inline to support loading states
}
