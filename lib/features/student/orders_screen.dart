import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/providers.dart';
import '../../widgets/common.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider).value ?? const [];
    final active = orders.where((o) => o.status.isActive).toList();
    final past = orders.where((o) => !o.status.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your orders')),
      body: orders.isEmpty
          ? EmptyState(
              emoji: '🧾',
              title: 'No orders yet',
              message: 'Your first order is one tap away.',
              action: FilledButton(onPressed: () => context.go('/home'), child: const Text('Find food')),
            )
          : Constrained(
              maxWidth: 720,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (active.isNotEmpty) ...[
                    const SectionTitle('In progress'),
                    for (final o in active)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: OrderTile(order: o),
                      ),
                  ],
                  if (past.isNotEmpty) ...[
                    const SectionTitle('Past orders'),
                    for (final o in past)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: OrderTile(order: o),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
