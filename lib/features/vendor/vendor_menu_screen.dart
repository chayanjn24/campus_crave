import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

class VendorMenuScreen extends ConsumerWidget {
  const VendorMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final outletId = ref.watch(sessionProvider)!.outletId!;
    final menu = ref.watch(menuProvider(outletId)).value ?? const [];
    final repo = ref.read(repositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.onBrand,
        onPressed: () => _edit(context, ref, outletId, null),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: Constrained(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
          children: [
            for (final item in menu)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.outline)),
                ),
                child: Row(
                  children: [
                    VegDot(isVeg: item.isVeg),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _edit(context, ref, outletId, item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: text.titleMedium),
                            Text(
                              '${item.category} · ${rupees(item.price)}',
                              style: text.bodySmall?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      item.isAvailable ? 'In stock' : 'Sold out',
                      style: text.labelMedium?.copyWith(color: item.isAvailable ? AppColors.brand : AppColors.amber),
                    ),
                    Switch(
                      value: item.isAvailable,
                      onChanged: (v) => repo.upsertMenuItem(item.copyWith(isAvailable: v)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, String outletId, MenuItem? item) async {
    final name = TextEditingController(text: item?.name);
    final price = TextEditingController(text: item?.price.toString());
    final category = TextEditingController(text: item?.category);
    var isVeg = item?.isVeg ?? true;

    final saved = await showModalBottomSheet<MenuItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(item == null ? 'New item' : 'Edit item', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Price', prefixText: '₹ '),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vegetarian'),
                value: isVeg,
                onChanged: (v) => setState(() => isVeg = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  final p = int.tryParse(price.text);
                  if (name.text.trim().isEmpty || p == null || category.text.trim().isEmpty) return;
                  Navigator.pop(
                    ctx,
                    item?.copyWith(name: name.text.trim(), price: p, category: category.text.trim(), isVeg: isVeg) ??
                        MenuItem(
                          id: 'm${DateTime.now().microsecondsSinceEpoch}',
                          outletId: outletId,
                          name: name.text.trim(),
                          price: p,
                          category: category.text.trim(),
                          isVeg: isVeg,
                        ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
    if (saved != null) await ref.read(repositoryProvider).upsertMenuItem(saved);
  }
}
