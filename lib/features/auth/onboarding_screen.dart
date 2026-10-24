import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';

/// First-run profile: who you are and where food should reach you.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.phone});

  final String? phone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  late final _phone = TextEditingController(text: widget.phone);
  final _room = TextEditingController();
  var _role = UserRole.student;
  String? _location;
  String? _outletId;
  var _isRunner = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _room.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      isValidPhone(_phone.text.trim()) &&
      (_role == UserRole.student
          ? _location != null && (!needsRoom(_location) || _room.text.trim().isNotEmpty)
          : _outletId != null);

  void _finish() {
    ref
        .read(sessionProvider.notifier)
        .signIn(
          AppUser(
            id: 'u${DateTime.now().microsecondsSinceEpoch}',
            name: _name.text.trim(),
            role: _role,
            phone: _phone.text.trim(),
            location: _role == UserRole.student ? _location : null,
            room: _role == UserRole.student && needsRoom(_location) ? _room.text.trim() : null,
            outletId: _role == UserRole.vendor ? _outletId : null,
            isRunner: _role == UserRole.student && _isRunner,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final outlets = ref.watch(outletsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Set up your profile', style: text.headlineMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _name,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Your name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixText: '+91 ',
                    helperText: 'Runners and outlets call this if they need you',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                Text('I am a', style: text.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _RoleCard(
                      emoji: '🎓',
                      title: 'Student',
                      subtitle: 'Order food, or run deliveries',
                      selected: _role == UserRole.student,
                      onTap: () => setState(() => _role = UserRole.student),
                    ),
                    const SizedBox(width: 12),
                    _RoleCard(
                      emoji: '👨‍🍳',
                      title: 'Vendor',
                      subtitle: 'Run a campus outlet',
                      selected: _role == UserRole.vendor,
                      onTap: () => setState(() => _role = UserRole.vendor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_role == UserRole.student) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _location,
                    decoration: const InputDecoration(labelText: 'Where do you stay?'),
                    items: [for (final l in campusLocations) DropdownMenuItem(value: l, child: Text(l))],
                    onChanged: (v) => setState(() => _location = v),
                  ),
                  if (needsRoom(_location)) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _room,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(labelText: 'Room number'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isRunner,
                    onChanged: (v) => setState(() => _isRunner = v),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Also deliver for others'),
                    subtitle: Text(
                      'Earn ₹$deliveryFee per delivery into your wallet. You can change this anytime.',
                      style: text.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ),
                ] else
                  DropdownButtonFormField<String>(
                    initialValue: _outletId,
                    decoration: const InputDecoration(labelText: 'Which outlet do you run?'),
                    items: [
                      for (final o in outlets) DropdownMenuItem(value: o.id, child: Text('${o.emoji}  ${o.name}')),
                    ],
                    onChanged: (v) => setState(() => _outletId = v),
                  ),
                const SizedBox(height: 32),
                FilledButton(onPressed: _valid ? _finish : null, child: const Text('Let\'s go')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.brand : AppColors.outline, width: selected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(title, style: text.titleMedium),
              Text(subtitle, style: text.bodySmall?.copyWith(color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
