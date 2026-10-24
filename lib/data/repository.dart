import '../models/models.dart';

/// Everything the UI needs from the backend. [InMemoryRepository] backs the
/// app until Firebase is configured; a Firestore implementation will follow.
abstract class Repository {
  Stream<List<Outlet>> watchOutlets();
  Stream<List<MenuItem>> watchMenu(String outletId);

  /// Every menu item across outlets, for dish search.
  Stream<List<MenuItem>> watchAllMenu();
  Future<void> upsertMenuItem(MenuItem item);
  Future<void> setOutletOpen(String outletId, bool isOpen);

  Future<Order> placeOrder({
    required AppUser student,
    required Outlet outlet,
    required List<OrderLine> lines,
    required String dropLocation,
    required String contactPhone,
    bool useWallet,
    String note,
  });
  Stream<Order?> watchOrder(String orderId);
  Stream<List<Order>> watchStudentOrders(String studentId);
  Stream<List<Order>> watchOutletOrders(String outletId);

  /// Orders a runner can claim: accepted by the vendor, no runner yet,
  /// and not placed by the runner themselves.
  Stream<List<Order>> watchOpenDeliveries(String runnerId);
  Stream<List<Order>> watchRunnerOrders(String runnerId);

  /// Moving to delivered credits the delivery fee to the runner's wallet;
  /// cancelling refunds any wallet money the student spent.
  Future<void> updateStatus(String orderId, OrderStatus status);
  Future<void> claimDelivery(String orderId, AppUser runner);

  /// Wallet balance in rupees. Runners earn into it; anyone can spend it at checkout.
  Stream<int> watchWallet(String userId);
}
