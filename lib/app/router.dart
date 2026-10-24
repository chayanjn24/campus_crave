import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/onboarding_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/runner/runner_screen.dart';
import '../features/student/cart_screen.dart';
import '../features/student/home_screen.dart';
import '../features/student/order_detail_screen.dart';
import '../features/student/orders_screen.dart';
import '../features/student/outlet_screen.dart';
import '../features/vendor/vendor_menu_screen.dart';
import '../features/vendor/vendor_orders_screen.dart';
import '../features/welcome/welcome_screen.dart';
import '../models/models.dart';
import '../state/providers.dart';

const _publicPaths = {'/', '/sign-in', '/onboarding'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(sessionProvider);
      final path = state.matchedLocation;
      final isPublic = _publicPaths.contains(path);
      if (user == null) return isPublic ? null : '/';
      final home = user.role == UserRole.vendor ? '/vendor' : '/home';
      if (isPublic) return home;
      if (user.role == UserRole.vendor && !path.startsWith('/vendor') && !path.startsWith('/order/')) return home;
      if (user.role == UserRole.student && path.startsWith('/vendor')) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, s) => OnboardingScreen(phone: s.uri.queryParameters['phone']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _StudentShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/run', builder: (_, _) => const RunnerScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _VendorShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/vendor', builder: (_, _) => const VendorOrdersScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/vendor/menu', builder: (_, _) => const VendorMenuScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/vendor/profile', builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/outlet/:id',
        builder: (_, s) => OutletScreen(outletId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(
        path: '/order/:id',
        builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!),
      ),
    ],
  );
});

class _StudentShell extends ConsumerWidget {
  const _StudentShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(myOrdersProvider).value?.where((o) => o.status.isActive).length ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: active > 0,
              label: Text('$active'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: active > 0,
              label: Text('$active'),
              child: const Icon(Icons.receipt_long),
            ),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.directions_run_outlined),
            selectedIcon: Icon(Icons.directions_run),
            label: 'Run',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _VendorShell extends ConsumerWidget {
  const _VendorShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incoming = ref.watch(outletOrdersProvider).value?.where((o) => o.status == OrderStatus.placed).length ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: incoming > 0,
              label: Text('$incoming'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: Badge(isLabelVisible: incoming > 0, label: Text('$incoming'), child: const Icon(Icons.inbox)),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
