import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _note = TextEditingController();
  final _room = TextEditingController();
  final _phone = TextEditingController();
  String? _drop;
  var _useWallet = true;
  var _placing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider);
    _drop = user?.location;
    _room.text = user?.room ?? '';
    _phone.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _note.dispose();
    _room.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _ready =>
      _drop != null && (!needsRoom(_drop) || _room.text.trim().isNotEmpty) && isValidPhone(_phone.text.trim());

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    setState(() => _placing = true);
    // Razorpay test-mode checkout slots in here; until then payment is simulated.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final order = await ref
        .read(repositoryProvider)
        .placeOrder(
          student: ref.read(sessionProvider)!,
          outlet: cart.outlet!,
          lines: cart.lines,
          dropLocation: dropLabel(_drop!, _room.text.trim()),
          contactPhone: _phone.text.trim(),
          useWallet: _useWallet,
          note: _note.text.trim(),
        );
    ref.read(cartProvider.notifier).clear();
    if (mounted) context.pushReplacement('/order/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cart = ref.watch(cartProvider);
    final convenience = convenienceFeeFor(cart.itemsTotal);
    final total = cart.itemsTotal + deliveryFee + convenience;
    final balance = ref.watch(walletProvider).value ?? 0;
    final fromWallet = _useWallet ? (balance < total ? balance : total) : 0;
    final toPay = total - fromWallet;

    if (cart.isEmpty && !_placing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your cart')),
        body: EmptyState(
          emoji: '🛒',
          title: 'Cart is empty',
          message: 'Pick an outlet and add something tasty.',
          action: FilledButton(onPressed: () => context.go('/home'), child: const Text('Browse outlets')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: Constrained(
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (cart.outlet != null) Text('${cart.outlet!.emoji}  ${cart.outlet!.name}', style: text.titleLarge),
            const SizedBox(height: 12),
            for (final line in cart.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    VegDot(isVeg: cart.items[line.itemId]!.isVeg),
                    const SizedBox(width: 10),
                    Expanded(child: Text(line.name, style: text.bodyLarge)),
                    _Stepper(
                      qty: line.qty,
                      onRemove: () => ref.read(cartProvider.notifier).remove(cart.items[line.itemId]!),
                      onAdd: () => ref.read(cartProvider.notifier).add(cart.outlet!, cart.items[line.itemId]!),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(rupees(line.total), textAlign: TextAlign.right, style: text.bodyLarge),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _drop,
              decoration: const InputDecoration(labelText: 'Deliver to', prefixIcon: Icon(Icons.location_on_outlined)),
              items: [for (final l in campusLocations) DropdownMenuItem(value: l, child: Text(l))],
              onChanged: (v) => setState(() => _drop = v),
            ),
            if (needsRoom(_drop)) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _room,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Room number',
                  prefixIcon: Icon(Icons.door_front_door_outlined),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone for the runner',
                prefixText: '+91 ',
                prefixIcon: Icon(Icons.call_outlined),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note for runner (landmark, floor)'),
            ),
            if (balance > 0) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                value: _useWallet,
                onChanged: (v) => setState(() => _useWallet = v),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.brand),
                title: Text('Use wallet (${rupees(balance)})'),
                subtitle: Text(
                  'Earnings from your deliveries',
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _BillRow('Item total', rupees(cart.itemsTotal)),
                    _BillRow('Delivery (goes to your runner)', rupees(deliveryFee)),
                    _BillRow('Convenience fee', rupees(convenience)),
                    if (fromWallet > 0) _BillRow('Paid from wallet', '−${rupees(fromWallet)}', accent: true),
                    const Divider(height: 24),
                    _BillRow('To pay', rupees(toPay), bold: true),
                  ],
                ),
              ),
            ),
            if (cart.comboSavings > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'You save ${rupees(cart.comboSavings)} with combos',
                  textAlign: TextAlign.center,
                  style: text.labelLarge?.copyWith(color: AppColors.veg),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: !_ready || _placing ? null : _placeOrder,
              child: _placing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onBrand),
                    )
                  : Text(toPay == 0 ? 'Place order' : 'Pay ${rupees(toPay)}'),
            ),
            const SizedBox(height: 8),
            Text(
              'Test mode — no real payment is taken.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.qty, required this.onAdd, required this.onRemove});

  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.outline),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(visualDensity: VisualDensity.compact, onPressed: onRemove, icon: const Icon(Icons.remove, size: 16)),
        Text('$qty'),
        IconButton(visualDensity: VisualDensity.compact, onPressed: onAdd, icon: const Icon(Icons.add, size: 16)),
      ],
    ),
  );
}

class _BillRow extends StatelessWidget {
  const _BillRow(this.label, this.value, {this.bold = false, this.accent = false});

  final String label;
  final String value;
  final bool bold;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = bold
        ? text.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : text.bodyMedium?.copyWith(color: accent ? AppColors.veg : AppColors.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
