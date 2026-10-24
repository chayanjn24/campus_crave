import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/seed.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Welcome_page.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33131110), Color(0xCC131110), AppColors.bg],
                stops: [0, 0.55, 0.85],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(99)),
                        child: Text(
                          'NIT SILCHAR',
                          style: text.labelMedium?.copyWith(
                            color: AppColors.onBrand,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'campus\ncrave.',
                        style: text.displayLarge?.copyWith(fontWeight: FontWeight.w700, height: 0.9, letterSpacing: -3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Every canteen on campus, delivered to your hostel by fellow students. Order in, or earn by running.',
                        style: text.bodyLarge?.copyWith(color: AppColors.muted, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _Stat(value: '${seedOutlets.length}', label: 'outlets'),
                          _Stat(value: '${campusLocations.length}', label: 'drop points'),
                          _Stat(value: rupees(deliveryFee), label: 'per run'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.push('/sign-in'),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Start ordering'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: text.headlineSmall?.copyWith(color: AppColors.brand)),
          Text(label, style: text.bodySmall?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}
