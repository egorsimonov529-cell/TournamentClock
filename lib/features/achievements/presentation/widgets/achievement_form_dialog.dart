import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/achievement.dart';
import '../../domain/providers/achievements_providers.dart';

class AchievementFormDialog extends ConsumerStatefulWidget {
  final Achievement? achievement;
  final String? remoteId;

  const AchievementFormDialog({super.key, this.achievement, this.remoteId});

  @override
  ConsumerState<AchievementFormDialog> createState() => _AchievementFormDialogState();
}

class _AchievementFormDialogState extends ConsumerState<AchievementFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _currentController;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.achievement?.title ?? '');
    _descriptionController = TextEditingController(text: widget.achievement?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.achievement?.imageUrl ?? '');
    _currentController = TextEditingController(text: (widget.achievement?.currentValue ?? 0).toString());
    _targetController = TextEditingController(text: (widget.achievement?.targetValue ?? 1).toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.achievement == null ? 'Новое достижение' : 'Редактировать достижение'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Путь к картинке (assets/...)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton(
                    onPressed: _pickImage,
                    child: const Text('Выбрать файл'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_pickedImage == null ? 'Файл не выбран' : _pickedImage!.path.split(Platform.pathSeparator).last)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Текущее значение'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Цель'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final current = int.tryParse(_currentController.text.trim()) ?? 0;
    final target = int.tryParse(_targetController.text.trim()) ?? 1;

    if (title.isEmpty || description.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните обязательные поля и корректную цель')),
      );
      return;
    }

    final item = Achievement(
      id: widget.achievement?.id ?? 'achievement-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      currentValue: current,
      targetValue: target,
      achieved: widget.achievement?.achieved ?? current >= target,
    );
    // Save remotely if backend available
    try {
      if (widget.remoteId != null) {
        final updateUc = ref.read(updateAchievementUsecaseProvider);
        await updateUc(widget.remoteId!, {
          'title': title,
          'description': description,
          'current_value': current,
          'target_value': target,
          'achieved': item.achieved,
        }, image: _pickedImage);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Достижение обновлено')));
      } else {
        final saveUc = ref.read(saveAchievementUsecaseProvider);
        await saveUc({
          'title': title,
          'description': description,
          'current_value': current,
          'target_value': target,
          'achieved': item.achieved,
        }, image: _pickedImage);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Достижение создано')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')));
      return;
    }

    Navigator.pop(context, item);
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _pickedImage = File(res.files.single.path!);
      });
    }
  }
}
