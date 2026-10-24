import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

const _timeline = [
  OrderStatus.placed,
  OrderStatus.accepted,
  OrderStatus.preparing,
  OrderStatus.ready,
  OrderStatus.pickedUp,
  OrderStatus.delivered,
];

/// Live order view. The same screen serves the student who ordered,
/// the runner delivering it, and the vendor cooking it — actions change by viewer.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final order = ref.watch(orderProvider(orderId)).value;
    final user = ref.watch(sessionProvider);

    if (order == null || user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isRunner = order.runnerId == user.id;
    final isVendor = user.role == UserRole.vendor && user.outletId == order.outletId;

    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.shortId}')),
      body: Constrained(
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(_headline(order), style: text.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${order.outletName} → ${order.dropLocation}',
              style: text.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            if (order.status == OrderStatus.cancelled)
              Text('This order was cancelled.', style: text.bodyLarge?.copyWith(color: AppColors.amber))
            else
              _Timeline(order: order),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      Icons.person_outline,
                      'Ordered by',
                      order.studentId == user.id
                          ? order.studentName
                          : '${order.studentName} · +91 ${order.contactPhone}',
                    ),
                    _InfoRow(
                      Icons.directions_run,
                      'Runner',
                      order.runnerName == null
                          ? 'Looking for a runner…'
                          : order.runnerPhone == null
                          ? order.runnerName!
                          : '${order.runnerName} · +91 ${order.runnerPhone}',
                    ),
                    if (order.note.isNotEmpty) _InfoRow(Icons.sticky_note_2_outlined, 'Note', order.note),
                    const Divider(height: 24),
                    for (final l in order.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(child: Text('${l.qty} × ${l.name}')),
                            Text(rupees(l.total)),
                          ],
                        ),
                      ),
                    _FeeRow('Delivery', rupees(order.deliveryFee)),
                    _FeeRow('Convenience fee', rupees(order.convenienceFee)),
                    if (order.walletUsed > 0) _FeeRow('Paid from wallet', '−${rupees(order.walletUsed)}'),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(child: Text('Paid online', style: text.titleMedium)),
                        Text(rupees(order.paidOnline), style: text.titleMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._actions(
              context,
              ref,
              order,
              isRunner: isRunner,
              isVendor: isVendor,
              isOwner: order.studentId == user.id,
            ),
          ],
        ),
      ),
    );
  }

  String _headline(Order o) => switch (o.status) {
    OrderStatus.placed => 'Waiting for the outlet…',
    OrderStatus.accepted => 'Order accepted 👍',
    OrderStatus.preparing => 'Being prepared 🔥',
    OrderStatus.ready => o.runnerId == null ? 'Ready, finding a runner' : 'Ready, runner on the way',
    OrderStatus.pickedUp => 'On the way to you 🏃',
    OrderStatus.delivered => 'Delivered. Enjoy! 🎉',
    OrderStatus.cancelled => 'Cancelled',
  };

  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref,
    Order order, {
    required bool isRunner,
    required bool isVendor,
    required bool isOwner,
  }) {
    final repo = ref.read(repositoryProvider);
    void set(OrderStatus s) => repo.updateStatus(order.id, s);

    if (isVendor) {
      return switch (order.status) {
        OrderStatus.placed => [
          FilledButton(onPressed: () => set(OrderStatus.accepted), child: const Text('Accept order')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => set(OrderStatus.cancelled), child: const Text('Decline')),
        ],
        OrderStatus.accepted => [
          FilledButton(onPressed: () => set(OrderStatus.preparing), child: const Text('Start preparing')),
        ],
        OrderStatus.preparing => [
          FilledButton(onPressed: () => set(OrderStatus.ready), child: const Text('Mark ready')),
        ],
        _ => const [],
      };
    }
    if (isRunner) {
      return switch (order.status) {
        OrderStatus.accepted ||
        OrderStatus.preparing => [const FilledButton(onPressed: null, child: Text('Wait for the food to be ready'))],
        OrderStatus.ready => [FilledButton(onPressed: () => set(OrderStatus.pickedUp), child: const Text('Picked up'))],
        OrderStatus.pickedUp => [
          FilledButton(onPressed: () => set(OrderStatus.delivered), child: const Text('Mark delivered')),
        ],
        _ => const [],
      };
    }
    if (isOwner && order.status == OrderStatus.placed) {
      return [OutlinedButton(onPressed: () => set(OrderStatus.cancelled), child: const Text('Cancel order'))];
    }
    return const [];
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final current = _timeline.indexOf(order.status);
    return Column(
      children: [
        for (var i = 0; i < _timeline.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: i == current ? 22 : 16,
                        height: i == current ? 22 : 16,
                        margin: EdgeInsets.only(top: i == current ? 0 : 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= current ? AppColors.brand : AppColors.surfaceHigh,
                          border: i == current
                              ? Border.all(color: AppColors.brand.withValues(alpha: 0.35), width: 5)
                              : null,
                        ),
                      ),
                      if (i < _timeline.length - 1)
                        Expanded(child: Container(width: 2, color: i < current ? AppColors.brand : AppColors.outline)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _timeline[i].label,
                            style: text.titleMedium?.copyWith(color: i <= current ? AppColors.text : AppColors.muted),
                          ),
                        ),
                        if (order.statusTimes[_timeline[i]] != null)
                          Text(
                            timeOf(order.statusTimes[_timeline[i]]!),
                            style: text.bodySmall?.copyWith(color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 10),
        Text('$label  ', style: const TextStyle(color: AppColors.muted)),
        Expanded(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );
}

class _FeeRow extends StatelessWidget {
  const _FeeRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(value, style: const TextStyle(color: AppColors.muted)),
      ],
    ),
  );
}
