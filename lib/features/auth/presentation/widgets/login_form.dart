import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/providers/auth_state_provider.dart';
import '../../domain/models/auth_state.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;

  String? _loginError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Автозаполнение логина если "Запомнить меня" было включено
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedLogin();
    });
  }

  Future<void> _loadSavedLogin() async {
    final prefs = ref.read(sharedPrefsServiceProvider);
    final savedLogin = prefs.getString('saved_login');
    if (savedLogin != null && savedLogin.isNotEmpty && mounted) {
      setState(() {
        _loginController.text = savedLogin;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Очистить ошибки валидации
  void _clearErrors() {
    setState(() {
      _loginError = null;
      _passwordError = null;
    });
  }

  /// Валидация формы
  bool _validateForm() {
    _clearErrors();

    final loginResult = FormValidators.login(_loginController.text);
    final passwordResult = FormValidators.password(_passwordController.text);

    setState(() {
      _loginError = loginResult;
      _passwordError = passwordResult;
    });

    return loginResult == null && passwordResult == null;
  }

  /// Обработка входа
  Future<void> _handleLogin() async {
    // Сначала валидируем форму
    if (!_validateForm()) {
      return;
    }

    // Проверяем текущее состояние авторизации
    final authState = ref.read(authStateProvider);

    if (authState.status == AuthStatus.authenticating) {
      return;
    }

    // Вызываем login через provider
    final success = await ref
        .read(authStateProvider.notifier)
        .login(
          login: _loginController.text,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

    // Если успешно — переходим на нужную страницу по роли
    if (success && mounted) {
      final authState = ref.read(authStateProvider);
      final role = authState.userRole ?? "player";

      if (role == "player") {
        context.go("/user");
      } else {
        context.go("/dashboard");
      }
    }
    // Ошибка уже отображена через authStateProvider
  }

  @override
  Widget build(BuildContext context) {
    // Следим за состоянием авторизации
    final authState = ref.watch(authStateProvider);

    final isLoading = authState.status == AuthStatus.authenticating;

    final errorMessage = authState.message;

    // Если есть ошибка от сервера — отображаем
    if (errorMessage != null && errorMessage.isNotEmpty) {
      // Проверяем что это не просто "Session verified"
      if (errorMessage != 'Session verified') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _passwordError = errorMessage;
            });
          }
        });
      }
    }

    return Column(
      children: [
        AppTextField(
          label: "Логин",
          controller: _loginController,
          keyboardType: TextInputType.emailAddress,
        ),

        if (_loginError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              _loginError!,
              style: const TextStyle(
                color: Color(0xffEF4444),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const Gap(18),

        AppTextField(
          label: "Пароль",
          controller: _passwordController,
          obscure: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          suffixIcon: IconButton(
            onPressed: isLoading
                ? null
                : () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
          ),
        ),

        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              _passwordError!,
              style: const TextStyle(
                color: Color(0xffEF4444),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const Gap(8),

        AppCheckbox(
          value: _rememberMe,
          text: "Запомнить меня",
          onChanged: isLoading
              ? null
              : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
        ),

        const Gap(28),

        PrimaryButton(
          label: "Войти",
          onPressed: isLoading ? null : _handleLogin,
          loading: isLoading,
        ),
        const Gap(12),

        const Gap(18),
        TextButton(
          onPressed: isLoading ? null : () => context.push('/recovery'),
          child: const Text('Забыли пароль?'),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.push('/register'),
          child: const Text('Нет аккаунта? Зарегистрироваться'),
        ),
      ],
    );
  }
}
