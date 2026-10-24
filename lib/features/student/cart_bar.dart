import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

/// Floating "view cart" bar shown while the cart has items.
class CartBar extends ConsumerWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final text = Theme.of(context).textTheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) => SizeTransition(sizeFactor: anim, child: child),
      child: cart.isEmpty
          ? const SizedBox.shrink()
          : SafeArea(
              child: Constrained(
                maxWidth: 600,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Material(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/cart'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              '${cart.count} item${cart.count == 1 ? '' : 's'} · ${rupees(cart.itemsTotal)}',
                              style: text.titleMedium?.copyWith(color: AppColors.onBrand, fontWeight: FontWeight.w800),
                            ),
                            const Spacer(),
                            Text(
                              'View cart',
                              style: text.titleMedium?.copyWith(color: AppColors.onBrand, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, color: AppColors.onBrand),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
