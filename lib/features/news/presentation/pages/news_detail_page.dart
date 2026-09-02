import 'package:flutter/material.dart';

import '../../../../core/ui/ios/ios_card.dart';
import '../../../../core/ui/ios/ios_button.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  const NewsDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['image_url'] as String?;
    return Scaffold(
      appBar: AppBar(title: Text(post['title'] ?? '')), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
              ),
              const SizedBox(height: 12),
            ],
            IosCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(post['body'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(children: [IosButton(onPressed: () => Navigator.pop(context), label: 'Назад')]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
