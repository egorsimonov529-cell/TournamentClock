import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_text_field.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Настройки профиля",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Управляйте своими данными и настройками",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileSection(),
          const SizedBox(height: 32),
          _buildSecuritySection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Личные данные",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: ProfileTextField(label: "Имя", hintText: "Введите имя"),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ProfileTextField(
                  label: "Фамилия",
                  hintText: "Введите фамилию",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ProfileTextField(label: "Email", hintText: "your@email.com"),
          const SizedBox(height: 16),
          const ProfileTextField(
            label: "Логин",
            hintText: "your_login",
            readOnly: true,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Сохранить",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1D232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Безопасность",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const ProfileTextField(label: "Текущий пароль", obscureText: true),
          const SizedBox(height: 16),
          const ProfileTextField(label: "Новый пароль", obscureText: true),
          const SizedBox(height: 16),
          const ProfileTextField(
            label: "Подтвердите пароль",
            obscureText: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Изменить пароль",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
