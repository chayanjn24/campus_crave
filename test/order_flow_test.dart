import 'package:campus_crave/data/in_memory_repository.dart';
import 'package:campus_crave/data/seed.dart';
import 'package:campus_crave/models/models.dart';
import 'package:campus_crave/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const student = AppUser(id: 's1', name: 'Aarav', role: UserRole.student, location: 'Hostel 4', room: '212');
const runner = AppUser(id: 's2', name: 'Priya', role: UserRole.student, phone: '9876500000', isRunner: true);

void main() {
  group('order lifecycle', () {
    late InMemoryRepository repo;
    late Order order;

    setUp(() async {
      repo = InMemoryRepository();
      order = await repo.placeOrder(
        student: student,
        outlet: seedOutlets.first,
        lines: const [OrderLine(itemId: 'x', name: 'Veg Fried Rice', price: 60, qty: 2)],
        dropLocation: dropLabel('Hostel 4', '212'),
        contactPhone: '9876543210',
      );
    });

    test('totals include delivery and convenience fees', () {
      expect(order.itemsTotal, 120);
      expect(order.convenienceFee, 4);
      expect(order.total, 120 + deliveryFee + 4);
      expect(order.dropLocation, 'Hostel 4, Room 212');
      expect(order.status, OrderStatus.placed);
    });

    test('runner earns the delivery fee into their wallet and can spend it', () async {
      await repo.updateStatus(order.id, OrderStatus.accepted);
      await repo.claimDelivery(order.id, runner);
      expect((await repo.watchOrder(order.id).first)!.runnerPhone, runner.phone);
      for (final s in [OrderStatus.preparing, OrderStatus.ready, OrderStatus.pickedUp, OrderStatus.delivered]) {
        await repo.updateStatus(order.id, s);
      }
      expect(await repo.watchWallet(runner.id).first, deliveryFee);
      expect(() => repo.updateStatus(order.id, OrderStatus.delivered), throwsStateError);

      final own = await repo.placeOrder(
        student: runner,
        outlet: seedOutlets.first,
        lines: const [OrderLine(itemId: 'y', name: 'Chai', price: 10, qty: 1)],
        dropLocation: 'Library',
        contactPhone: runner.phone!,
        useWallet: true,
      );
      expect(own.walletUsed, deliveryFee);
      expect(own.paidOnline, own.total - deliveryFee);
      expect(await repo.watchWallet(runner.id).first, 0);

      await repo.updateStatus(own.id, OrderStatus.cancelled);
      expect(await repo.watchWallet(runner.id).first, deliveryFee);
    });

    test('order is only open to runners once the vendor accepts it', () async {
      expect(await repo.watchOpenDeliveries(runner.id).first, isEmpty);
      await repo.updateStatus(order.id, OrderStatus.accepted);
      expect((await repo.watchOpenDeliveries(runner.id).first).single.id, order.id);
    });

    test('students never see their own order as a delivery', () async {
      await repo.updateStatus(order.id, OrderStatus.accepted);
      expect(await repo.watchOpenDeliveries(student.id).first, isEmpty);
    });

    test('runs end to end and records every status time', () async {
      await repo.updateStatus(order.id, OrderStatus.accepted);
      await repo.claimDelivery(order.id, runner);
      for (final s in [OrderStatus.preparing, OrderStatus.ready, OrderStatus.pickedUp, OrderStatus.delivered]) {
        await repo.updateStatus(order.id, s);
      }
      final done = (await repo.watchOrder(order.id).first)!;
      expect(done.status, OrderStatus.delivered);
      expect(done.runnerName, 'Priya');
      expect(done.statusTimes.keys, containsAll(OrderStatus.values.where((s) => s != OrderStatus.cancelled)));
      expect(await repo.watchOpenDeliveries('someone-else').first, isEmpty);
    });

    test('a delivery can only be claimed once', () async {
      await repo.updateStatus(order.id, OrderStatus.accepted);
      await repo.claimDelivery(order.id, runner);
      const other = AppUser(id: 's3', name: 'Rahul', role: UserRole.student, isRunner: true);
      expect(() => repo.claimDelivery(order.id, other), throwsStateError);
    });
  });

  test('convenience fee scales from 3 to 5 rupees', () {
    expect(convenienceFeeFor(60), 3);
    expect(convenienceFeeFor(150), 4);
    expect(convenienceFeeFor(400), 5);
  });

  test('only hostels need a room number', () {
    expect(needsRoom('Hostel 9B'), isTrue);
    expect(needsRoom('Library'), isFalse);
    expect(dropLabel('Library', '12'), 'Library');
  });

  test('combos are cheaper than their parts', () {
    final combos = seedMenu.where((m) => m.isCombo).toList();
    expect(combos, isNotEmpty);
    expect(combos.every((m) => m.saving > 0), isTrue);
  });

  test('hostel canteens share a common menu at their own prices', () {
    final canteens = seedOutlets.where((o) => o.kind == OutletKind.canteen).toList();
    final canteenIds = canteens.map((o) => o.id).toSet();
    final eggMaggi = seedMenu.where((m) => m.name == 'Egg Maggi' && canteenIds.contains(m.outletId)).toList();
    expect(canteens.length, greaterThan(1));
    expect(eggMaggi.map((m) => m.outletId).toSet(), canteenIds);
    expect(eggMaggi.map((m) => m.price).toSet().length, greaterThan(1));
    expect(seedMenu.map((m) => m.id).toSet().length, seedMenu.length);
  });

  group('cart', () {
    test('holds items from one outlet at a time', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartProvider.notifier);
      final [bh1, bh3, ...] = seedOutlets;
      final roll = seedMenu.firstWhere((m) => m.outletId == bh1.id);
      final maggi = seedMenu.firstWhere((m) => m.outletId == bh3.id);

      expect(cart.add(bh1, roll), isTrue);
      expect(cart.add(bh1, roll), isTrue);
      expect(cart.add(bh3, maggi), isFalse);
      expect(container.read(cartProvider).count, 2);
      expect(container.read(cartProvider).itemsTotal, roll.price * 2);

      cart.replaceWith(bh3, maggi);
      expect(container.read(cartProvider).outlet, bh3);
      expect(container.read(cartProvider).count, 1);

      cart.remove(maggi);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });
  });
}
