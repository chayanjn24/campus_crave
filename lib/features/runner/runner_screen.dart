import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

/// Students who opted in can pick up open deliveries and earn the delivery fee.
class RunnerScreen extends ConsumerWidget {
  const RunnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider)!;

    if (!user.isRunner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Run')),
        body: EmptyState(
          emoji: '🏃',
          title: 'Earn while you walk',
          message:
              'Heading back to your hostel anyway? Carry an order on the way and earn ${rupees(deliveryFee)} per delivery into your wallet, to spend on your own orders.',
          action: FilledButton(
            onPressed: () => ref.read(sessionProvider.notifier).update(user.copyWith(isRunner: true)),
            child: const Text('Become a runner'),
          ),
        ),
      );
    }

    final open = ref.watch(openDeliveriesProvider).value ?? const [];
    final mine = ref.watch(myDeliveriesProvider).value ?? const [];
    final active = mine.where((o) => o.status.isActive).toList();
    final wallet = ref.watch(walletProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Run')),
      body: Constrained(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _StatCard(label: 'Wallet', value: rupees(wallet), highlight: true),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Deliveries',
                    value: '${mine.where((o) => o.status == OrderStatus.delivered).length}',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Active', value: '${active.length}'),
                ],
              ),
            ),
            if (active.isNotEmpty) ...[
              const SectionTitle('Your deliveries'),
              for (final o in active)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: OrderTile(order: o, subtitle: '${o.outletName} → ${o.dropLocation} · ${o.itemsLabel}'),
                ),
            ],
            const SectionTitle('Up for grabs'),
            if (open.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No open deliveries right now. New ones appear here as outlets accept orders.',
                  style: text.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ),
            for (final o in open)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: OrderTile(
                  order: o,
                  onTap: () {},
                  subtitle: '${o.outletName} → ${o.dropLocation} · ${o.itemsLabel}',
                  trailing: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          await ref.read(repositoryProvider).claimDelivery(o.id, user);
                          if (context.mounted) context.push('/order/${o.id}');
                        } on StateError catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        }
                      },
                      child: Text('Deliver for ${rupees(o.deliveryFee)}'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = highlight ? AppColors.onBrand : AppColors.text;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? AppColors.brand : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: highlight ? null : Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: text.headlineSmall?.copyWith(color: fg)),
            Text(label, style: text.bodySmall?.copyWith(color: highlight ? AppColors.onBrand : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
