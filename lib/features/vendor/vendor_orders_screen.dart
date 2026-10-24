import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider)!;
    final outlet = ref.watch(outletProvider(user.outletId!));
    final orders = ref.watch(outletOrdersProvider).value ?? const [];
    final repo = ref.read(repositoryProvider);

    final incoming = orders.where((o) => o.status == OrderStatus.placed).toList();
    final kitchen = orders.where((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.preparing).toList();
    final ready = orders.where((o) => o.status == OrderStatus.ready || o.status == OrderStatus.pickedUp).toList();
    final today = orders.where((o) => o.status == OrderStatus.delivered).toList();
    final revenue = today.fold(0, (sum, o) => sum + o.itemsTotal);

    Widget column(String title, List<Order> list, Widget? Function(Order) action) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Text(title, style: text.titleLarge),
                const SizedBox(width: 8),
                Text('${list.length}', style: text.titleLarge?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          if (list.isEmpty) Text('Nothing here', style: text.bodyMedium?.copyWith(color: AppColors.muted)),
          for (final o in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderTile(
                order: o,
                subtitle:
                    '${o.lines.map((l) => '${l.qty}× ${l.name}').join(', ')}\n→ ${o.dropLocation} · +91 ${o.contactPhone}'
                    '${o.runnerName != null ? ' · runner: ${o.runnerName}' : ''}',
                trailing: action(o),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${outlet?.emoji ?? ''}  ${outlet?.name ?? ''}'),
        actions: [
          if (outlet != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Text(
                    outlet.isOpen ? 'Open' : 'Closed',
                    style: text.labelLarge?.copyWith(color: outlet.isOpen ? AppColors.brand : AppColors.amber),
                  ),
                  Switch(value: outlet.isOpen, onChanged: (v) => repo.setOutletOpen(outlet.id, v)),
                ],
              ),
            ),
        ],
      ),
      body: Constrained(
        maxWidth: 1200,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                '${today.length} delivered · ${rupees(revenue)} in sales',
                style: text.bodyLarge?.copyWith(color: AppColors.muted),
              ),
            ),
            LayoutBuilder(
              builder: (context, c) {
                final cols = [
                  column(
                    'New',
                    incoming,
                    (o) => Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => repo.updateStatus(o.id, OrderStatus.cancelled),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => repo.updateStatus(o.id, OrderStatus.accepted),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  column(
                    'In the kitchen',
                    kitchen,
                    (o) => SizedBox(
                      width: double.infinity,
                      child: o.status == OrderStatus.accepted
                          ? FilledButton(
                              onPressed: () => repo.updateStatus(o.id, OrderStatus.preparing),
                              child: const Text('Start preparing'),
                            )
                          : FilledButton(
                              onPressed: () => repo.updateStatus(o.id, OrderStatus.ready),
                              child: const Text('Mark ready'),
                            ),
                    ),
                  ),
                  column('Ready / out', ready, (_) => null),
                ];
                // Board layout on wide screens, stacked on phones.
                if (c.maxWidth < 900) return Column(children: cols);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final col in cols) Expanded(child: col)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
