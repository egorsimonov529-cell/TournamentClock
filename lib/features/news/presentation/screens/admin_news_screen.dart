import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tournament_clock/core/services/api_service.dart';
import 'package:tournament_clock/core/config/app_config.dart';
import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_input.dart';
import '../../../../core/ui/ios/ios_button.dart';

/// Helper to get full image URL from relative path
String? _getFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api/v1', '');
  final cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
  return '$baseUrl$cleanPath';
}

class AdminNewsScreen extends ConsumerStatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  ConsumerState<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends ConsumerState<AdminNewsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String? _pickedPath;
  bool _isPosting = false;
  List<dynamic> _posts = [];
  bool _loadingPosts = true;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // On web, show dialog to paste URL
      final controller = TextEditingController();
      final url = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('URL изображения'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'https://example.com/image.jpg'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Выбрать'),
            ),
          ],
        ),
      );
      if (url != null && url.isNotEmpty) {
        setState(() => _pickedPath = url);
      }
      return;
    }

    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.isNotEmpty) {
      setState(() => _pickedPath = res.files.single.path);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() { _loadingPosts = true; });
    try {
      final res = await ApiService().get('/posts');
      setState(() { _posts = res.data as List<dynamic>; });
    } catch (_) {
      setState(() { _posts = []; });
    } finally {
      setState(() { _loadingPosts = false; });
    }
  }

  Future<void> _post() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty) return;
    setState(() { _isPosting = true; });
    try {
      final api = ApiService();
      final form = FormData.fromMap({
        'title': title,
        'body': body,
        'is_published': true,
      });

      if (_pickedPath != null && !kIsWeb) {
        try {
          form.files.add(MapEntry(
            'image',
            MultipartFile.fromFileSync(
              _pickedPath!,
              filename: _pickedPath!.split(Platform.pathSeparator).last,
            ),
          ));
        } catch (e) {
          // Ignored if file not accessible
        }
      }

      await api.postMultipart('/posts', form);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пост опубликован')));
      _title.clear();
      _body.clear();
      setState(() => _pickedPath = null);
      await _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    } finally {
      setState(() { _isPosting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          IosInput(controller: _title, label: 'Заголовок'),
          const SizedBox(height: 8),
          IosInput(controller: _body, label: 'Текст', maxLines: 4),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!kIsWeb)
                IosButton(onPressed: _pickImage, label: 'Выбрать фото', filled: false)
              else
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Вставить URL'),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _pickedPath == null
                      ? 'Файл не выбран'
                      : _pickedPath!.split(Platform.pathSeparator).last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _isPosting
                  ? const SizedBox(width: 120, height: 40, child: Center(child: CircularProgressIndicator()))
                  : IosButton(onPressed: _post, label: 'Опубликовать'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (_loadingPosts) const Center(child: CircularProgressIndicator()),
          if (!_loadingPosts)
            Expanded(
              child: _posts.isEmpty
                  ? const Center(child: Text('Нет постов'))
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (_, i) {
                        final post = _posts[i] as Map<String, dynamic>;
                        final imageUrl = _getFullImageUrl(post['image_url'] as String?);
                        return IosCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['title'] as String? ?? 'Без заголовка',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (imageUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  post['body'] as String? ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
