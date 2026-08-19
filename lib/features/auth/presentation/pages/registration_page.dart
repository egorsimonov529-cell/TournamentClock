import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../core/utils/form_validators.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Введите имя';
    if (value.length < 2) return 'Минимум 2 символа';
    return null;
  }

  String? _validateEmail(String? value) {
    return FormValidators.email(value);
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Введите телефон';
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.length < 10) return 'Некорректный номер';
    return null;
  }

  String? _validatePassword(String? value) {
    return FormValidators.password(value);
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Подтвердите пароль';
    if (value != _passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  bool _validateForm() {
    setState(() {
      _nameError = _validateName(_nameController.text);
      _emailError = _validateEmail(_emailController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmError = _validateConfirm(_passwordConfirmController.text);
    });
    return _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmError == null &&
        _agreeTerms;
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;
    final success = await ref
        .read(authStateProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          acceptedTerms: _agreeTerms,
        );
    if (!mounted) return;
    if (success) {
      context.go('/cabinet');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(authStateProvider).message ??
              '╨Ю╤И╨╕╨▒╨║╨░ ╤А╨╡╨│╨╕╤Б╤В╤А╨░╤Ж╨╕╨╕',
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref
        .read(authStateProvider.notifier)
        .signInWithGoogle();
    if (!mounted) return;
    if (success) {
      context.go('/cabinet');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(authStateProvider).message ??
              'Google-╨▓╤Е╨╛╨┤ ╤В╤А╨╡╨▒╤Г╨╡╤В ╨╜╨░╤Б╤В╤А╨╛╨╣╨║╨╕ OAuth',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authStateProvider).status == AuthStatus.authenticating;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: isLoading ? null : () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Создание аккаунта",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Зарегистрируйтесь в нашем покерном клубе",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Форма
            AppTextField(
              label: "Имя и фамилия",
              controller: _nameController,
              hintText: "Иван Петров",
            ),
            if (_nameError != null) _buildError(_nameError!),

            const SizedBox(height: 16),

            AppTextField(
              label: "Email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: "ivan@example.com",
            ),
            if (_emailError != null) _buildError(_emailError!),

            const SizedBox(height: 16),

            AppTextField(
              label: "Телефон",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hintText: "+7 (999) 123-45-67",
            ),
            if (_phoneError != null) _buildError(_phoneError!),

            const SizedBox(height: 16),

            AppTextField(
              label: "Пароль",
              controller: _passwordController,
              obscure: _obscurePassword,
              hintText: "Минимум 6 символов",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: isLoading
                    ? null
                    : () =>
                          setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            if (_passwordError != null) _buildError(_passwordError!),

            const SizedBox(height: 16),

            AppTextField(
              label: "Повторите пароль",
              controller: _passwordConfirmController,
              obscure: _obscureConfirm,
              hintText: "Повторите пароль",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: isLoading
                    ? null
                    : () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            if (_confirmError != null) _buildError(_confirmError!),

            const SizedBox(height: 24),

            // Согласие с правилами
            AppCheckbox(
              value: _agreeTerms,
              text:
                  "Я согласен с правилами клуба и политикой конфиденциальности",
              onChanged: isLoading
                  ? null
                  : (v) => setState(() => _agreeTerms = v ?? false),
            ),
            if (!_agreeTerms)
              const Padding(
                padding: EdgeInsets.only(left: 48, top: 4),
                child: Text(
                  'Необходимо согласие',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ),

            const SizedBox(height: 32),

            PrimaryButton(
              label: "Зарегистрироваться",
              onPressed: isLoading ? null : _handleRegister,
              loading: isLoading,
            ),

            const SizedBox(height: 12),
            GhostButton(
              label: '╨Т╨╛╨╣╤В╨╕ ╤З╨╡╤А╨╡╨╖ Google',
              onPressed: isLoading ? null : _handleGoogleLogin,
            ),

            const SizedBox(height: 16),

            // Ссылка на вход
            Center(
              child: GestureDetector(
                onTap: isLoading ? null : () => context.go('/login'),
                child: const Text(
                  "Уже есть аккаунт? Войти",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        error,
        style: const TextStyle(fontSize: 12, color: AppColors.error),
      ),
    );
  }
}
