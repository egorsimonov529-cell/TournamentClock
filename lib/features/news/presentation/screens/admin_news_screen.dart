import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  File? _picked;
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
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.isNotEmpty) {
      setState(() { _picked = File(res.files.single.path!); });
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
      final form = FormData.fromMap({'title': title, 'body': body, 'is_published': true});
      if (_picked != null) {
        form.files.add(MapEntry('image', MultipartFile.fromFileSync(_picked!.path, filename: _picked!.path.split(Platform.pathSeparator).last)));
      }
      await api.postMultipart('/posts', form);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пост опубликован')));
      _title.clear(); _body.clear(); setState(() => _picked = null);
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
          Row(children: [
            IosButton(onPressed: _pickImage, label: 'Выбрать фото', filled: false),
            const SizedBox(width: 12),
            Expanded(child: Text(_picked == null ? 'Файл не выбран' : _picked!.path.split(Platform.pathSeparator).last)),
            const SizedBox(width: 12),
            _isPosting ? const SizedBox(width: 120, height: 40, child: Center(child: CircularProgressIndicator())) : IosButton(onPressed: _post, label: 'Опубликовать'),
          ]),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (_loadingPosts) const Center(child: CircularProgressIndicator()),
          if (!_loadingPosts)
            Expanded(
              child: _posts.isEmpty
                  ? Center(
                      child: IosCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: const Text('Постов нет'),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = _posts[index] as Map<String, dynamic>;
                        final imageUrl = _getFullImageUrl(p['image_url'] as String?);
                        return IosCard(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            leading: imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                                    ),
                                  )
                                : const Icon(Icons.newspaper, color: Colors.white54),
                            title: Text(p['title'] ?? ''),
                            subtitle: Text(p['body'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Удалить пост'),
                                    content: const Text('Вы уверены, что хотите удалить этот пост?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                                      IosButton(onPressed: () => Navigator.pop(ctx, true), label: 'Удалить'),
                                    ],
                                  ),
                                );
                                if (ok != true) return;
                                try {
                                  await ApiService().delete('/posts/${p['id']}');
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пост удалён')));
                                  await _loadPosts();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: ${e.toString()}')));
                                }
                              },
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
