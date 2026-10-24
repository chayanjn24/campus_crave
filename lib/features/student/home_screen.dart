import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import 'cart_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';
  OutletKind? _kind;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Late-night cravings';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider)!;
    final outlets = ref.watch(outletsProvider);
    final active = ref.watch(myOrdersProvider).value?.where((o) => o.status.isActive).toList() ?? const [];

    return Scaffold(
      bottomNavigationBar: const CartBar(),
      body: SafeArea(
        child: Constrained(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.brand),
                          const SizedBox(width: 4),
                          Text(user.location ?? 'Campus', style: text.labelLarge?.copyWith(color: AppColors.brand)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${_greeting()},\n${user.name.split(' ').first} 👋', style: text.headlineLarge),
                    ],
                  ),
                ),
              ),
              if (active.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _ActiveOrderBanner(order: active.first),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: 'Search a dish or canteen',
                      prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    ),
                  ),
                ),
              ),
              ...outlets.when(
                loading: () => [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
                error: (e, _) => [SliverFillRemaining(child: Center(child: Text('$e')))],
                data: (list) => _query.isEmpty ? _browse(list, user.location) : _search(list),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  /// Outlets grouped into sections, with the student's own hostel canteen first.
  List<Widget> _browse(List<Outlet> outlets, String? home) {
    final mine = outlets.where((o) => o.kind == OutletKind.canteen && o.location == home).toList();
    final sections = [
      if (_kind != OutletKind.cafe && mine.isNotEmpty) ('Your hostel', mine),
      for (final kind in OutletKind.values)
        if (_kind == null || _kind == kind)
          (kind.label, outlets.where((o) => o.kind == kind && !mine.contains(o)).toList()),
    ];
    return [
      SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            spacing: 8,
            children: [
              for (final kind in [null, ...OutletKind.values])
                ChoiceChip(
                  label: Text(kind?.label ?? 'All'),
                  selected: _kind == kind,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
        ),
      ),
      for (final (title, list) in sections)
        if (list.isNotEmpty) ...[SliverToBoxAdapter(child: SectionTitle(title)), _OutletGrid(outlets: list)],
    ];
  }

  /// Dishes matching the query, each listing the outlets that sell it, cheapest first.
  List<Widget> _search(List<Outlet> outlets) {
    final byId = {for (final o in outlets) o.id: o};
    final menu = ref.watch(allMenuProvider).value ?? const <MenuItem>[];
    final dishes = <String, List<MenuItem>>{};
    for (final m in menu) {
      if (m.isAvailable && byId.containsKey(m.outletId) && m.name.toLowerCase().contains(_query)) {
        dishes.putIfAbsent(m.name, () => []).add(m);
      }
    }
    for (final offers in dishes.values) {
      offers.sort((a, b) => a.price.compareTo(b.price));
    }
    final matchingOutlets = outlets
        .where((o) => o.name.toLowerCase().contains(_query) || o.location.toLowerCase().contains(_query))
        .toList();

    if (dishes.isEmpty && matchingOutlets.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(emoji: '🔍', title: 'Nothing found', message: 'No dish or outlet matches "$_query".'),
        ),
      ];
    }
    return [
      if (matchingOutlets.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SectionTitle('Outlets')),
        _OutletGrid(outlets: matchingOutlets),
      ],
      if (dishes.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SectionTitle('Dishes')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: dishes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final entry = dishes.entries.elementAt(i);
              return _DishCard(name: entry.key, offers: entry.value, outlets: byId);
            },
          ),
        ),
      ],
    ];
  }
}

class _OutletGrid extends StatelessWidget {
  const _OutletGrid({required this.outlets});

  final List<Outlet> outlets;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 132,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate((_, i) => _OutletCard(outlet: outlets[i]), childCount: outlets.length),
    ),
  );
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.name, required this.offers, required this.outlets});

  final String name;
  final List<MenuItem> offers;
  final Map<String, Outlet> outlets;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  VegDot(isVeg: offers.first.isVeg),
                  const SizedBox(width: 8),
                  Expanded(child: Text(name, style: text.titleMedium)),
                  Text(
                    offers.length == 1 ? '1 place' : '${offers.length} places',
                    style: text.labelMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            for (final m in offers)
              ListTile(
                dense: true,
                enabled: outlets[m.outletId]!.isOpen,
                onTap: () => context.push('/outlet/${m.outletId}'),
                title: Text(outlets[m.outletId]!.name),
                subtitle: Text(outlets[m.outletId]!.isOpen ? outlets[m.outletId]!.location : 'Closed'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (m.price == offers.first.price && offers.last.price > m.price)
                      Text('Cheapest', style: text.labelSmall?.copyWith(color: AppColors.veg)),
                    Text(rupees(m.price), style: text.titleMedium),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/order/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.delivery_dining, color: AppColors.onBrand, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.status.label,
                      style: text.titleMedium?.copyWith(color: AppColors.onBrand, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${order.outletName} · ${order.shortId}',
                      style: text.bodySmall?.copyWith(color: AppColors.onBrand),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onBrand),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutletCard extends StatelessWidget {
  const _OutletCard({required this.outlet});

  final Outlet outlet;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Opacity(
      opacity: outlet.isOpen ? 1 : 0.45,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/outlet/${outlet.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(14)),
                  child: Text(outlet.emoji, style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outlet.name, style: text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        '${outlet.location}  ·  ${outlet.hours}',
                        style: text.bodySmall?.copyWith(color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              outlet.cuisine,
                              style: text.labelSmall?.copyWith(color: AppColors.muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            outlet.isOpen ? '${outlet.prepMinutes}–${outlet.prepMinutes + 15} min' : 'Closed',
                            style: text.labelMedium?.copyWith(color: outlet.isOpen ? AppColors.brand : AppColors.amber),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
