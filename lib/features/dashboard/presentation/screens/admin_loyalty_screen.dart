import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/admin_workspace_state.dart';

class AdminLoyaltyScreen extends ConsumerWidget {
  const AdminLoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(adminWorkspaceProvider).campaigns;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff191D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Программы лояльности',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Управляйте локальными акциями клуба',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: campaigns.isEmpty
                ? const Center(child: Text('Кампаний пока нет'))
                : ListView.separated(
                    itemCount: campaigns.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return Card(
                        color: const Color(0xff1D232C),
                        child: SwitchListTile(
                          value: campaign.active,
                          onChanged: (value) {
                            ref
                                .read(adminWorkspaceProvider.notifier)
                                .toggleCampaign(campaign.id, value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? 'Кампания включена'
                                      : 'Кампания приостановлена',
                                ),
                              ),
                            );
                          },
                          secondary: Icon(
                            campaign.active
                                ? Icons.card_giftcard_rounded
                                : Icons.pause_circle_outline_rounded,
                          ),
                          title: Text(
                            campaign.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            campaign.description,
                            style: const TextStyle(color: Colors.white54),
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
