import 'dart:async';

import '../models/models.dart';
import 'repository.dart';
import 'seed.dart';

class InMemoryRepository implements Repository {
  InMemoryRepository() {
    for (final o in seedOutlets) {
      _outlets[o.id] = o;
    }
    for (final m in seedMenu) {
      _menu[m.id] = m;
    }
  }

  final _outlets = <String, Outlet>{};
  final _menu = <String, MenuItem>{};
  final _orders = <String, Order>{};
  final _wallets = <String, int>{};
  final _changes = StreamController<void>.broadcast();
  var _seq = 0;

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  void _notify() => _changes.add(null);

  List<Order> _ordersWhere(bool Function(Order) test) =>
      _orders.values.where(test).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<Outlet>> watchOutlets() => _watch(() => _outlets.values.toList());

  @override
  Stream<List<MenuItem>> watchMenu(String outletId) =>
      _watch(() => _menu.values.where((m) => m.outletId == outletId).toList());

  @override
  Stream<List<MenuItem>> watchAllMenu() => _watch(() => _menu.values.toList());

  @override
  Future<void> upsertMenuItem(MenuItem item) async {
    _menu[item.id] = item;
    _notify();
  }

  @override
  Future<void> setOutletOpen(String outletId, bool isOpen) async {
    _outlets[outletId] = _outlets[outletId]!.copyWith(isOpen: isOpen);
    _notify();
  }

  @override
  Future<Order> placeOrder({
    required AppUser student,
    required Outlet outlet,
    required List<OrderLine> lines,
    required String dropLocation,
    required String contactPhone,
    bool useWallet = false,
    String note = '',
  }) async {
    final now = DateTime.now();
    final itemsTotal = lines.fold(0, (sum, l) => sum + l.total);
    final total = itemsTotal + deliveryFee + convenienceFeeFor(itemsTotal);
    final balance = _wallets[student.id] ?? 0;
    final walletUsed = useWallet ? (balance < total ? balance : total) : 0;
    _wallets[student.id] = balance - walletUsed;
    final order = Order(
      id: 'ord${now.millisecondsSinceEpoch}${_seq++}',
      outletId: outlet.id,
      outletName: outlet.name,
      studentId: student.id,
      studentName: student.name,
      lines: lines,
      deliveryFee: deliveryFee,
      convenienceFee: convenienceFeeFor(itemsTotal),
      dropLocation: dropLocation,
      contactPhone: contactPhone,
      walletUsed: walletUsed,
      note: note,
      status: OrderStatus.placed,
      createdAt: now,
      statusTimes: {OrderStatus.placed: now},
    );
    _orders[order.id] = order;
    _notify();
    return order;
  }

  @override
  Stream<Order?> watchOrder(String orderId) => _watch(() => _orders[orderId]);

  @override
  Stream<List<Order>> watchStudentOrders(String studentId) =>
      _watch(() => _ordersWhere((o) => o.studentId == studentId));

  @override
  Stream<List<Order>> watchOutletOrders(String outletId) => _watch(() => _ordersWhere((o) => o.outletId == outletId));

  @override
  Stream<List<Order>> watchOpenDeliveries(String runnerId) => _watch(
    () => _ordersWhere(
      (o) =>
          o.runnerId == null &&
          o.studentId != runnerId &&
          (o.status == OrderStatus.accepted || o.status == OrderStatus.preparing || o.status == OrderStatus.ready),
    ),
  );

  @override
  Stream<List<Order>> watchRunnerOrders(String runnerId) => _watch(() => _ordersWhere((o) => o.runnerId == runnerId));

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final order = _orders[orderId]!;
    if (!order.status.isActive) throw StateError('Order is already ${order.status.label.toLowerCase()}');
    if (status == OrderStatus.delivered && order.runnerId != null) {
      _credit(order.runnerId!, order.deliveryFee);
    } else if (status == OrderStatus.cancelled) {
      _credit(order.studentId, order.walletUsed);
    }
    _orders[orderId] = order.copyWith(status: status);
    _notify();
  }

  void _credit(String userId, int amount) => _wallets[userId] = (_wallets[userId] ?? 0) + amount;

  @override
  Stream<int> watchWallet(String userId) => _watch(() => _wallets[userId] ?? 0);

  @override
  Future<void> claimDelivery(String orderId, AppUser runner) async {
    final order = _orders[orderId]!;
    if (order.runnerId != null) throw StateError('Another runner already took this order');
    _orders[orderId] = order.copyWith(runnerId: runner.id, runnerName: runner.name, runnerPhone: runner.phone);
    _notify();
  }
}
