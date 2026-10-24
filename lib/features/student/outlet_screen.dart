import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import 'cart_bar.dart';

class OutletScreen extends ConsumerStatefulWidget {
  const OutletScreen({super.key, required this.outletId});

  final String outletId;

  @override
  ConsumerState<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends ConsumerState<OutletScreen> {
  var _vegOnly = false;
  String? _category;

  Future<void> _add(Outlet outlet, MenuItem item) async {
    final cart = ref.read(cartProvider.notifier);
    if (cart.add(outlet, item)) return;
    final replace = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start a new cart?'),
        content: Text(
          'Your cart has items from ${ref.read(cartProvider).outlet!.name}. '
          'Orders come from one outlet at a time.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Start new')),
        ],
      ),
    );
    if (replace == true) cart.replaceWith(outlet, item);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final outlet = ref.watch(outletProvider(widget.outletId));
    final menu = ref.watch(menuProvider(widget.outletId)).value ?? const [];
    final cart = ref.watch(cartProvider);

    if (outlet == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final categories = {for (final m in menu) m.category}.toList()
      ..sort((a, b) => (b == 'Combos' ? 1 : 0) - (a == 'Combos' ? 1 : 0));
    final visible = menu
        .where((m) => (!_vegOnly || m.isVeg) && (_category == null || m.category == _category))
        .toList();

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: const CartBar(),
      body: Constrained(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Text(outlet.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outlet.name, style: text.headlineMedium),
                      Text(outlet.tagline, style: text.bodyMedium?.copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${outlet.location}  ·  ${outlet.hours}\n${outlet.cuisine}  ·  ${outlet.prepMinutes}–${outlet.prepMinutes + 15} min  ·  ${rupees(deliveryFee)} delivery',
              style: text.labelLarge?.copyWith(color: AppColors.brand),
            ),
            if (!outlet.isOpen) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Closed right now. You can browse, but not order.',
                  style: text.bodyMedium?.copyWith(color: AppColors.amber),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Veg only'),
                    selected: _vegOnly,
                    onSelected: (v) => setState(() => _vegOnly = v),
                  ),
                  const SizedBox(width: 8),
                  for (final c in categories) ...[
                    ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      showCheckmark: false,
                      onSelected: (v) => setState(() => _category = v ? c : null),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final item in visible)
              _MenuRow(
                item: item,
                qty: cart.outlet?.id == outlet.id ? cart.quantityOf(item.id) : 0,
                canOrder: outlet.isOpen && item.isAvailable,
                onAdd: () => _add(outlet, item),
                onRemove: () => ref.read(cartProvider.notifier).remove(item),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.qty,
    required this.canOrder,
    required this.onAdd,
    required this.onRemove,
  });

  final MenuItem item;
  final int qty;
  final bool canOrder;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VegDot(isVeg: item.isVeg),
                    const SizedBox(width: 8),
                    Flexible(child: Text(item.name, style: text.titleMedium)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  spacing: 8,
                  children: [
                    Text(rupees(item.price), style: text.bodyLarge),
                    if (item.isCombo) ...[
                      Text(
                        rupees(item.originalPrice!),
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.muted,
                        ),
                      ),
                      Text(
                        'Save ${rupees(item.saving)}',
                        style: text.labelMedium?.copyWith(color: AppColors.veg, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
                if (item.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(item.description, style: text.bodySmall?.copyWith(color: AppColors.muted)),
                  ),
                if (!item.isAvailable) Text('Sold out', style: text.labelMedium?.copyWith(color: AppColors.amber)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (qty == 0)
            OutlinedButton(
              onPressed: canOrder ? onAdd : null,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, 40),
                foregroundColor: AppColors.brand,
                side: BorderSide(color: canOrder ? AppColors.brand : AppColors.outline),
              ),
              child: const Text('ADD'),
            )
          else
            Container(
              height: 40,
              decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.remove, color: AppColors.onBrand, size: 18),
                  ),
                  Text(
                    '$qty',
                    style: text.titleMedium?.copyWith(color: AppColors.onBrand, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: canOrder ? onAdd : null,
                    icon: const Icon(Icons.add, color: AppColors.onBrand, size: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
