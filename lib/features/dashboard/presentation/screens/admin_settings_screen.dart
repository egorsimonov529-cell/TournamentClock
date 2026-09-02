import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
  late String _currency;
  late bool _notifications;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    final state = ref.read(adminWorkspaceProvider);
    _clubName = TextEditingController(text: state.clubName);
    _clubShortName = TextEditingController(text: state.clubShortName);
    _logoAssetPath = TextEditingController(text: state.logoAssetPath);
    _currency = state.currency;
    _notifications = state.notificationsEnabled;
    _addressCtrl = TextEditingController(text: state.address ?? '');
    _cityCtrl = TextEditingController(text: state.city ?? '');
  }

  @override
  void dispose() {
    _clubName.dispose();
    _clubShortName.dispose();
    _logoAssetPath.dispose();
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff191D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Настройки клуба',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
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
            TextFormField(
              controller: _logoAssetPath,
              decoration: const InputDecoration(
                labelText: 'Путь к логотипу (assets/...)',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Укажите путь к логотипу'
                  : null,
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
                DropdownMenuItem(
                  value: 'RUB',
                  child: Text('RUB — Российский рубль'),
                ),
                DropdownMenuItem(value: 'USD', child: Text('USD — Доллар США')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR — Евро')),
              ],
              onChanged: (value) =>
                  setState(() => _currency = value ?? _currency),
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
            const SizedBox(height: 32),
            
            // Разделитель
            const Divider(color: Color(0xff2A2D35)),
            const SizedBox(height: 24),
            
            // Заголовок темы
            const Text(
              'Внешний вид',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            
            // Кнопка переключения темы
            InkWell(
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Тема изменена на "${nextTheme.label}"',
                    ),
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
                    // Иконка текущей темы
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
                    // Описание
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
                    // Стрелка
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
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    () async {
      try {
        await ref
            .read(adminWorkspaceProvider.notifier)
            .saveSettings(
              clubName: _clubName.text,
              clubShortName: _clubShortName.text,
              logoAssetPath: _logoAssetPath.text,
              currency: _currency,
              notificationsEnabled: _notifications,
              address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
              city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Настройки сохранены')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: ${e.toString()}')),
        );
      }
    }();
  }
}
