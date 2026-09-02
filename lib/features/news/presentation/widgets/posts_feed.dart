import 'package:flutter/material.dart';
import 'package:tournament_clock/core/config/app_config.dart';

import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_button.dart';
import 'package:tournament_clock/core/services/api_service.dart';
import '../pages/news_detail_page.dart';

/// Helper to get full image URL from relative path
String? _getFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  // Если это уже полный URL — возвращаем как есть
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  // Если это относительный путь — добавляем базовый URL без /api/v1
  final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api/v1', '');
  final cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
  return '$baseUrl$cleanPath';
}

class PostsFeed extends StatefulWidget {
  const PostsFeed({super.key});

  @override
  State<PostsFeed> createState() => _PostsFeedState();
}

class _PostsFeedState extends State<PostsFeed> {
  List<dynamic> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    try {
      final res = await ApiService().get('/posts');
      setState(() { _posts = res.data as List<dynamic>; });
    } catch (_) {
      setState(() { _posts = []; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_posts.isEmpty) return const Center(child: IosCard(child: Padding(padding: EdgeInsets.all(12), child: Text('Нет новостей', style: TextStyle(color: Colors.white54)))));
    return ListView.separated(
      itemCount: _posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      itemBuilder: (context, index) {
        final p = _posts[index] as Map<String, dynamic>;
        final imageUrl = _getFullImageUrl(p['image_url'] as String?);
        return IosCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(p['body'] ?? '', style: const TextStyle(color: Colors.white70), maxLines: 3, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IosButton(
                                label: 'Читать',
                                filled: false,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailPage(post: p)));
                                },
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (imageUrl != null) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 88,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)));
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
