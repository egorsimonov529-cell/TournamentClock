import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/club_logo.dart';
import '../../domain/admin_workspace_state.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clubName;
  late final TextEditingController _clubShortName;
  late final TextEditingController _logoAssetPath;
  late final TextEditingController _aboutText;
  late String _currency;
  late bool _notifications;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  bool _uploadingLogo = false;
  bool _dataApplied = false;

  void _applyState(AdminWorkspaceState state) {
    if (_clubName.text != state.clubName) _clubName.text = state.clubName;
    if (_clubShortName.text != state.clubShortName) _clubShortName.text = state.clubShortName;
    if (_logoAssetPath.text != state.logoAssetPath) _logoAssetPath.text = state.logoAssetPath;
    if (_aboutText.text != state.clubDescription) _aboutText.text = state.clubDescription;
    if (_currency != state.currency) _currency = state.currency;
    if (_notifications != state.notificationsEnabled) _notifications = state.notificationsEnabled;
    if (_addressCtrl.text != (state.address ?? '')) _addressCtrl.text = state.address ?? '';
    if (_cityCtrl.text != (state.city ?? '')) _cityCtrl.text = state.city ?? '';
    _dataApplied = true;
  }

  @override
  void initState() {
    super.initState();
    // Инициализируем с дефолтными значениями
    _clubName = TextEditingController(text: 'Poker Club ERM');
    _clubShortName = TextEditingController(text: 'ERM');
    _logoAssetPath = TextEditingController(text: '');
    _aboutText = TextEditingController(text: 'Место для честной игры');
    _currency = 'RUB';
    _notifications = true;
    _addressCtrl = TextEditingController(text: '');
    _cityCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _clubName.dispose();
    _clubShortName.dispose();
    _logoAssetPath.dispose();
    _aboutText.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final nextTheme = currentTheme == AppThemeType.gold
        ? AppThemeType.emerald
        : AppThemeType.gold;
    final workspace = ref.watch(adminWorkspaceProvider);
    final currentLogoUrl = (workspace.logoUrl?.isNotEmpty ?? false) ? workspace.logoUrl! : null;
    final isCompact = MediaQuery.sizeOf(context).width < 680;

    // Применяем данные из провайдера (один раз)
    if (!_dataApplied) {
      _applyState(workspace);
      _dataApplied = true;
    }

    // Слушаем изменения провайдера — обновим контроллеры когда данные придут
    ref.listen<AdminWorkspaceState>(
      adminWorkspaceProvider,
      (previous, next) {
        if (next != previous && mounted) {
          _clubName.text = next.clubName;
          _clubShortName.text = next.clubShortName;
          _logoAssetPath.text = next.logoAssetPath;
          _aboutText.text = next.clubDescription;
          _currency = next.currency;
          _notifications = next.notificationsEnabled;
          _addressCtrl.text = next.address ?? '';
          _cityCtrl.text = next.city ?? '';
          setState(() {});
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xff101418),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Настройки клуба',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _clubName,
                      decoration: const InputDecoration(labelText: 'Название клуба'),
                      validator: (value) => value == null || value.trim().length < 3
                          ? 'Введите название клуба'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clubShortName,
                      decoration: const InputDecoration(
                        labelText: 'Краткое название для шапки окна',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Введите краткое название'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClubLogo(
                          logoUrl: currentLogoUrl,
                          size: 56,
                          borderRadius: 14.0,
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _logoAssetPath,
                                decoration: const InputDecoration(
                                  labelText: 'Логотип клуба',
                                  hintText: 'Загрузите файл или вставьте URL',
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: ElevatedButton.icon(
                                      onPressed: _uploadingLogo ? null : _uploadLogo,
                                      icon: _uploadingLogo
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.upload_rounded, size: 18),
                                      label: Text(
                                      _uploadingLogo ? 'Загрузка...' : 'Загрузить файл',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() => _logoAssetPath.text = '');
                                      ref.read(adminWorkspaceProvider.notifier).updateLogo(
                                        logoUrl: '',
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    label: const Text('Удалить'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _aboutText,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(labelText: 'Описание клуба / О клубе'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Адрес клуба'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'Город'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(labelText: 'Валюта'),
                      items: const [
                        DropdownMenuItem(value: 'RUB', child: Text('RUB — Российский рубль')),
                        DropdownMenuItem(value: 'USD', child: Text('USD — Доллар США')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR — Евро')),
                      ],
                      onChanged: (value) => setState(() => _currency = value ?? _currency),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _notifications,
                      onChanged: (value) => setState(() => _notifications = value),
                      title: const Text('Системные уведомления'),
                      subtitle: const Text(
                        'Показывать локальные уведомления о событиях',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: Color(0xff2A2D35)),
                    const SizedBox(height: 24),
                    const Text(
                      'Внешний вид',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выберите цветовую палитру приложения',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        ref.read(themeProvider.notifier).toggleTheme();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Тема изменена на "${nextTheme.label}"'),
                            backgroundColor: nextTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: currentTheme == AppThemeType.gold
                              ? const Color(0xff2A2318)
                              : const Color(0xff1A2E23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentTheme.primaryColor.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: currentTheme.primaryColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                currentTheme == AppThemeType.gold
                                    ? Icons.wb_sunny_rounded
                                    : Icons.eco_rounded,
                                color: currentTheme.primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Тема: ${currentTheme.label}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentTheme.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: currentTheme.primaryColor,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Нажмите для переключения на "${nextTheme.label}"',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Сохранить настройки'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(adminWorkspaceProvider.notifier).saveSettings(
        clubName: _clubName.text,
        clubShortName: _clubShortName.text,
        logoAssetPath: _logoAssetPath.text,
        currency: _currency,
        notificationsEnabled: _notifications,
        clubDescription: _aboutText.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки сохранены')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadLogo() async {
    try {
      setState(() => _uploadingLogo = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _uploadingLogo = false);
        return;
      }

      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
      final token = await _getAccessToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.post('/admin/logo', data: formData);

      if (mounted) {
        setState(() => _uploadingLogo = false);

        if (response.data != null && response.data['logo_url'] != null) {
          final logoUrl = response.data['logo_url'] as String;
          final baseUrl = AppConstants.apiBaseUrl.replaceAll('/api/v1', '');
          final fullUrl = logoUrl.startsWith('http') ? logoUrl : '$baseUrl$logoUrl';

          setState(() {
            _logoAssetPath.text = fullUrl;
          });

          ref.read(adminWorkspaceProvider.notifier).updateLogo(logoUrl: fullUrl);

          // Автоматически сохраняем на сервер
          try {
            await ref.read(adminWorkspaceProvider.notifier).saveSettings(
              clubName: _clubName.text,
              clubShortName: _clubShortName.text,
              logoAssetPath: fullUrl,
              currency: _currency,
              notificationsEnabled: _notifications,
              clubDescription: _aboutText.text.trim(),
              address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
              city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
            );
          } catch (e) {
            // Тихая ошибка — логотип уже в state
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Логотип загружен')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingLogo = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      final storage = SecureStorageService();
      return await storage.read(AppConstants.accessTokenKey);
    } catch (e) {
      return null;
    }
  }
}
