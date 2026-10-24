import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider);
    if (user == null) return const SizedBox.shrink();
    final session = ref.read(sessionProvider.notifier);
    final isStudent = user.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: text.headlineMedium?.copyWith(color: AppColors.onBrand),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: text.titleLarge),
                        Text(
                          isStudent ? 'Student${user.isRunner ? ' · Runner' : ''}' : 'Vendor',
                          style: text.bodyMedium?.copyWith(color: AppColors.muted),
                        ),
                        if (user.phone != null)
                          Text('+91 ${user.phone}', style: text.bodySmall?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (isStudent) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.brand),
                    title: const Text('Wallet'),
                    subtitle: Text(
                      'Delivery earnings. Applied automatically at checkout.',
                      style: text.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    trailing: Text(rupees(ref.watch(walletProvider).value ?? 0), style: text.titleLarge),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: user.location,
                  decoration: const InputDecoration(
                    labelText: 'Default drop point',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: [for (final l in campusLocations) DropdownMenuItem(value: l, child: Text(l))],
                  onChanged: (v) => session.update(user.copyWith(location: v)),
                ),
                if (needsRoom(user.location)) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: user.room,
                    decoration: const InputDecoration(
                      labelText: 'Room number',
                      prefixIcon: Icon(Icons.door_front_door_outlined),
                    ),
                    onChanged: (v) => session.update(user.copyWith(room: v.trim())),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    value: user.isRunner,
                    onChanged: (v) => session.update(user.copyWith(isRunner: v)),
                    title: const Text('Runner mode'),
                    subtitle: Text(
                      'Deliver orders for others and earn ₹$deliveryFee each into your wallet',
                      style: text.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: session.signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
