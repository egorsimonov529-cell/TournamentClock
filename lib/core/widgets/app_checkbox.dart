import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String text;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.border,
          ),
          onChanged: onChanged,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}