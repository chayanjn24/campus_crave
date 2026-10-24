import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_repository.dart';
import '../data/repository.dart';
import '../models/models.dart';

final repositoryProvider = Provider<Repository>((ref) => InMemoryRepository());

// ---------- Session ----------

/// The signed-in user. Firebase Auth will drive this once configured;
/// for now sign-in is simulated on this device.
class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void signIn(AppUser user) => state = user;
  void signOut() => state = null;
  void update(AppUser user) => state = user;
}

final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);

// ---------- Catalogue ----------

final outletsProvider = StreamProvider<List<Outlet>>((ref) => ref.watch(repositoryProvider).watchOutlets());

final outletProvider = Provider.family<Outlet?, String>((ref, id) {
  final outlets = ref.watch(outletsProvider).value ?? const [];
  for (final o in outlets) {
    if (o.id == id) return o;
  }
  return null;
});

final menuProvider = StreamProvider.family<List<MenuItem>, String>(
  (ref, outletId) => ref.watch(repositoryProvider).watchMenu(outletId),
);

final allMenuProvider = StreamProvider<List<MenuItem>>((ref) => ref.watch(repositoryProvider).watchAllMenu());

// ---------- Orders ----------

final orderProvider = StreamProvider.family<Order?, String>((ref, id) => ref.watch(repositoryProvider).watchOrder(id));

final myOrdersProvider = StreamProvider<List<Order>>((ref) {
  final user = ref.watch(sessionProvider);
  if (user == null) return Stream.value(const []);
  return ref.watch(repositoryProvider).watchStudentOrders(user.id);
});

final outletOrdersProvider = StreamProvider<List<Order>>((ref) {
  final outletId = ref.watch(sessionProvider.select((u) => u?.outletId));
  if (outletId == null) return Stream.value(const []);
  return ref.watch(repositoryProvider).watchOutletOrders(outletId);
});

final openDeliveriesProvider = StreamProvider<List<Order>>((ref) {
  final userId = ref.watch(sessionProvider.select((u) => u?.id));
  if (userId == null) return Stream.value(const []);
  return ref.watch(repositoryProvider).watchOpenDeliveries(userId);
});

final myDeliveriesProvider = StreamProvider<List<Order>>((ref) {
  final userId = ref.watch(sessionProvider.select((u) => u?.id));
  if (userId == null) return Stream.value(const []);
  return ref.watch(repositoryProvider).watchRunnerOrders(userId);
});

final walletProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(sessionProvider.select((u) => u?.id));
  if (userId == null) return Stream.value(0);
  return ref.watch(repositoryProvider).watchWallet(userId);
});

// ---------- Cart ----------

class Cart {
  const Cart({this.outlet, this.items = const {}, this.qty = const {}});

  /// A cart holds items from one outlet at a time.
  final Outlet? outlet;
  final Map<String, MenuItem> items;
  final Map<String, int> qty;

  bool get isEmpty => qty.isEmpty;
  int get count => qty.values.fold(0, (a, b) => a + b);
  int get itemsTotal => qty.entries.fold(0, (sum, e) => sum + items[e.key]!.price * e.value);
  int get comboSavings => qty.entries.fold(0, (sum, e) => sum + items[e.key]!.saving * e.value);
  int quantityOf(String itemId) => qty[itemId] ?? 0;

  List<OrderLine> get lines => [
    for (final e in qty.entries)
      OrderLine(itemId: e.key, name: items[e.key]!.name, price: items[e.key]!.price, qty: e.value),
  ];
}

class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() => const Cart();

  /// Returns false when the item belongs to a different outlet than the cart.
  bool add(Outlet outlet, MenuItem item) {
    if (state.outlet != null && state.outlet!.id != outlet.id) return false;
    state = Cart(
      outlet: outlet,
      items: {...state.items, item.id: item},
      qty: {...state.qty, item.id: state.quantityOf(item.id) + 1},
    );
    return true;
  }

  void remove(MenuItem item) {
    final next = state.quantityOf(item.id) - 1;
    final qty = {...state.qty};
    if (next <= 0) {
      qty.remove(item.id);
    } else {
      qty[item.id] = next;
    }
    state = qty.isEmpty ? const Cart() : Cart(outlet: state.outlet, items: state.items, qty: qty);
  }

  void clear() => state = const Cart();

  void replaceWith(Outlet outlet, MenuItem item) {
    clear();
    add(outlet, item);
  }
}

final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);
