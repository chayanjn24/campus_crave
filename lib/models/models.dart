enum UserRole { student, vendor }

enum OrderStatus {
  placed('Placed'),
  accepted('Accepted'),
  preparing('Preparing'),
  ready('Ready for pickup'),
  pickedUp('On the way'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;

  bool get isActive => this != delivered && this != cancelled;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.location,
    this.room,
    this.outletId,
    this.isRunner = false,
  });

  final String id;
  final String name;
  final UserRole role;
  final String? phone;

  /// Default delivery spot for students (hostel / building).
  final String? location;

  /// Room number, for students who live in a hostel.
  final String? room;

  /// The outlet a vendor manages.
  final String? outletId;

  /// Students who opted in to deliver orders for others.
  final bool isRunner;

  AppUser copyWith({String? name, String? phone, String? location, String? room, bool? isRunner}) => AppUser(
    id: id,
    name: name ?? this.name,
    role: role,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    room: room ?? this.room,
    outletId: outletId,
    isRunner: isRunner ?? this.isRunner,
  );
}

enum OutletKind {
  canteen('Hostel canteens'),
  cafe('Cafés & stalls');

  const OutletKind(this.label);
  final String label;
}

class Outlet {
  const Outlet({
    required this.id,
    required this.name,
    required this.tagline,
    required this.emoji,
    required this.cuisine,
    required this.prepMinutes,
    required this.kind,
    required this.location,
    required this.hours,
    this.isOpen = true,
  });

  final String id;
  final String name;
  final String tagline;
  final String emoji;
  final String cuisine;
  final int prepMinutes;
  final OutletKind kind;

  /// Where the outlet is, e.g. the hostel a canteen belongs to.
  final String location;
  final String hours;
  final bool isOpen;

  Outlet copyWith({bool? isOpen}) => Outlet(
    id: id,
    name: name,
    tagline: tagline,
    emoji: emoji,
    cuisine: cuisine,
    prepMinutes: prepMinutes,
    kind: kind,
    location: location,
    hours: hours,
    isOpen: isOpen ?? this.isOpen,
  );
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.outletId,
    required this.name,
    required this.price,
    required this.category,
    this.description = '',
    this.isVeg = true,
    this.isAvailable = true,
    this.originalPrice,
  });

  final String id;
  final String outletId;
  final String name;
  final int price;
  final String category;
  final String description;
  final bool isVeg;
  final bool isAvailable;

  /// For combos: what the items would cost bought separately.
  final int? originalPrice;

  bool get isCombo => originalPrice != null;
  int get saving => (originalPrice ?? price) - price;

  MenuItem copyWith({String? name, int? price, String? category, bool? isVeg, bool? isAvailable}) => MenuItem(
    id: id,
    outletId: outletId,
    name: name ?? this.name,
    price: price ?? this.price,
    category: category ?? this.category,
    description: description,
    isVeg: isVeg ?? this.isVeg,
    isAvailable: isAvailable ?? this.isAvailable,
    originalPrice: originalPrice,
  );
}

class OrderLine {
  const OrderLine({required this.itemId, required this.name, required this.price, required this.qty});

  final String itemId;
  final String name;
  final int price;
  final int qty;

  int get total => price * qty;
}

class Order {
  const Order({
    required this.id,
    required this.outletId,
    required this.outletName,
    required this.studentId,
    required this.studentName,
    required this.lines,
    required this.deliveryFee,
    required this.convenienceFee,
    required this.dropLocation,
    required this.contactPhone,
    required this.status,
    required this.createdAt,
    this.walletUsed = 0,
    this.note = '',
    this.runnerId,
    this.runnerName,
    this.runnerPhone,
    this.statusTimes = const {},
  });

  final String id;
  final String outletId;
  final String outletName;
  final String studentId;
  final String studentName;
  final List<OrderLine> lines;
  final int deliveryFee;
  final int convenienceFee;

  /// Includes the room number for hostel drops.
  final String dropLocation;

  /// So the runner can call the student.
  final String contactPhone;

  /// Paid from the student's wallet; the rest was paid online.
  final int walletUsed;
  final String note;
  final OrderStatus status;
  final DateTime createdAt;
  final String? runnerId;
  final String? runnerName;
  final String? runnerPhone;

  /// When each status was reached — drives the tracking timeline.
  final Map<OrderStatus, DateTime> statusTimes;

  int get itemsTotal => lines.fold(0, (sum, l) => sum + l.total);
  int get total => itemsTotal + deliveryFee + convenienceFee;
  int get paidOnline => total - walletUsed;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.qty);
  String get itemsLabel => '$itemCount item${itemCount == 1 ? '' : 's'}';
  String get shortId => '#${id.substring(id.length - 4).toUpperCase()}';

  Order copyWith({OrderStatus? status, String? runnerId, String? runnerName, String? runnerPhone}) {
    final next = status ?? this.status;
    return Order(
      id: id,
      outletId: outletId,
      outletName: outletName,
      studentId: studentId,
      studentName: studentName,
      lines: lines,
      deliveryFee: deliveryFee,
      convenienceFee: convenienceFee,
      dropLocation: dropLocation,
      contactPhone: contactPhone,
      walletUsed: walletUsed,
      note: note,
      status: next,
      createdAt: createdAt,
      runnerId: runnerId ?? this.runnerId,
      runnerName: runnerName ?? this.runnerName,
      runnerPhone: runnerPhone ?? this.runnerPhone,
      statusTimes: status == null ? statusTimes : {...statusTimes, next: DateTime.now()},
    );
  }
}

/// NIT Silchar hostels. Drops here need a room number.
const hostels = [
  'Aryabhatta Hostel',
  'Hostel 1',
  'Hostel 2',
  'Hostel 3',
  'Hostel 4',
  'Hostel 6',
  'Hostel 7',
  'Hostel 8',
  'Hostel 9A',
  'Hostel 9B',
  'Hostel 9C',
  'Hostel 9D',
  'Girls Hostel 1',
  'Girls Hostel 2',
  'Girls Hostel 3',
  'Girls Hostel 4',
];

/// Common spots on campus; no room number needed.
const campusSpots = ['Student Activity Centre (SAC)', 'Library', 'Computer Centre (CS Dept)', 'Auditorium'];

const campusLocations = [...hostels, ...campusSpots];

bool needsRoom(String? location) => hostels.contains(location);

String dropLabel(String location, String? room) =>
    needsRoom(location) && room != null && room.isNotEmpty ? '$location, Room $room' : location;

/// Flat fee per order; all of it goes to the runner's wallet.
const deliveryFee = 15;

/// Small platform fee that scales with the order: ₹3, ₹4 or ₹5.
int convenienceFeeFor(int itemsTotal) => itemsTotal < 100 ? 3 : (itemsTotal < 250 ? 4 : 5);

bool isValidPhone(String phone) => RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
