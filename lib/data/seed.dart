import '../models/models.dart';

// Menus and prices are placeholders until confirmed with the outlets.

typedef _Dish = ({String slug, String name, int price, String category, bool isVeg});

/// Hostels with a canteen. They share a common menu; each shifts prices a little.
const _canteens = [
  (hostel: 'Hostel 1', priceShift: 0, prep: 12, special: (name: 'Chilli Paneer', price: 90, isVeg: true)),
  (hostel: 'Hostel 2', priceShift: 5, prep: 15, special: (name: 'Egg Kathi Roll', price: 50, isVeg: false)),
  (hostel: 'Hostel 3', priceShift: 0, prep: 10, special: (name: 'Schezwan Maggi', price: 45, isVeg: true)),
  (hostel: 'Hostel 4', priceShift: -5, prep: 10, special: (name: 'Chicken Momos (8)', price: 80, isVeg: false)),
  (hostel: 'Hostel 6', priceShift: 5, prep: 15, special: (name: 'Paneer Paratha', price: 50, isVeg: true)),
  (hostel: 'Hostel 7', priceShift: 0, prep: 12, special: (name: 'Chicken Chowmein', price: 80, isVeg: false)),
  (hostel: 'Hostel 8', priceShift: -5, prep: 12, special: (name: 'Veg Manchurian', price: 70, isVeg: true)),
];

const List<_Dish> _commonMenu = [
  (slug: 'maggi', name: 'Plain Maggi', price: 30, category: 'Maggi', isVeg: true),
  (slug: 'cheese-maggi', name: 'Cheese Maggi', price: 50, category: 'Maggi', isVeg: true),
  (slug: 'egg-maggi', name: 'Egg Maggi', price: 45, category: 'Maggi', isVeg: false),
  (slug: 'veg-chowmein', name: 'Veg Chowmein', price: 50, category: 'Chinese', isVeg: true),
  (slug: 'egg-chowmein', name: 'Egg Chowmein', price: 60, category: 'Chinese', isVeg: false),
  (slug: 'veg-fried-rice', name: 'Veg Fried Rice', price: 60, category: 'Chinese', isVeg: true),
  (slug: 'chicken-fried-rice', name: 'Chicken Fried Rice', price: 90, category: 'Chinese', isVeg: false),
  (slug: 'aloo-paratha', name: 'Aloo Paratha', price: 35, category: 'Breakfast', isVeg: true),
  (slug: 'masala-omelette', name: 'Masala Omelette', price: 35, category: 'Breakfast', isVeg: false),
  (slug: 'bread-omelette', name: 'Bread Omelette', price: 45, category: 'Breakfast', isVeg: false),
  (slug: 'chai', name: 'Chai', price: 10, category: 'Drinks', isVeg: true),
  (slug: 'cold-coffee', name: 'Cold Coffee', price: 45, category: 'Drinks', isVeg: true),
];

/// Sold at MRP everywhere, so prices do not shift between outlets.
const List<_Dish> _coldDrinks = [
  (slug: 'coke', name: 'Coca-Cola (250 ml)', price: 20, category: 'Cold drinks', isVeg: true),
  (slug: 'thums-up', name: 'Thums Up (250 ml)', price: 20, category: 'Cold drinks', isVeg: true),
  (slug: 'sprite', name: 'Sprite (250 ml)', price: 20, category: 'Cold drinks', isVeg: true),
  (slug: 'maaza', name: 'Maaza (250 ml)', price: 20, category: 'Cold drinks', isVeg: true),
  (slug: 'frooti', name: 'Frooti', price: 15, category: 'Cold drinks', isVeg: true),
  (slug: 'big-coke', name: 'Coca-Cola (750 ml)', price: 40, category: 'Cold drinks', isVeg: true),
];

/// Canteen combos: name, the common-menu slugs inside, and the discount.
const _canteenCombos = [
  (slug: 'combo-maggi-chai', name: 'Maggi + Chai', parts: ['maggi', 'chai'], off: 5),
  (slug: 'combo-rice-coke', name: 'Fried Rice + Coke', parts: ['veg-fried-rice', 'coke'], off: 10),
  (
    slug: 'combo-breakfast',
    name: 'Paratha + Omelette + Chai',
    parts: ['aloo-paratha', 'masala-omelette', 'chai'],
    off: 10,
  ),
];

String _canteenId(String hostel) => 'canteen-${hostel.toLowerCase().replaceAll(' ', '-')}';

int _price(_Dish d, int shift) => d.category == 'Cold drinks' ? d.price : d.price + shift;

final seedOutlets = [
  for (final c in _canteens)
    Outlet(
      id: _canteenId(c.hostel),
      name: '${c.hostel} Canteen',
      tagline: 'Your hostel canteen, after hours',
      emoji: '🏠',
      cuisine: 'Maggi · Chinese · Eggs · Cold drinks',
      prepMinutes: c.prep,
      kind: OutletKind.canteen,
      location: c.hostel,
      hours: '7 AM – 1 AM',
    ),
  const Outlet(
    id: 'tapri',
    name: 'Tapri',
    tagline: 'Chai, Maggi and late-night gossip',
    emoji: '☕',
    cuisine: 'Chai · Maggi · Bun · Cold drinks',
    prepMinutes: 8,
    kind: OutletKind.cafe,
    location: 'Outside Hostel 9',
    hours: '6 AM – 2 AM',
  ),
  const Outlet(
    id: 'sharma-snacks',
    name: 'Sharma Snacks',
    tagline: 'Hot samosas, every hour',
    emoji: '🥟',
    cuisine: 'Samosa · Pattice · Bread pakoda',
    prepMinutes: 5,
    kind: OutletKind.cafe,
    location: 'Near SAC',
    hours: '8 AM – 9 PM',
  ),
  const Outlet(
    id: 'kolkata-puchka',
    name: 'Kolkata Puchka',
    tagline: 'Teekha, as it should be',
    emoji: '🫓',
    cuisine: 'Puchka · Chaat',
    prepMinutes: 5,
    kind: OutletKind.cafe,
    location: 'Near Library',
    hours: '4 PM – 9 PM',
  ),
  const Outlet(
    id: 'babloo-fps',
    name: 'Babloo FPS',
    tagline: 'Between-class fuel',
    emoji: '🍞',
    cuisine: 'Pattice · Bread pakoda · Samosa',
    prepMinutes: 5,
    kind: OutletKind.cafe,
    location: 'Near Computer Centre',
    hours: '9 AM – 6 PM',
  ),
];

MenuItem _item(String outletId, _Dish d, {int shift = 0}) => MenuItem(
  id: '$outletId-${d.slug}',
  outletId: outletId,
  name: d.name,
  price: _price(d, shift),
  category: d.category,
  isVeg: d.isVeg,
);

List<MenuItem> _canteenMenu(
  ({String hostel, int priceShift, int prep, ({String name, int price, bool isVeg}) special}) c,
) {
  final id = _canteenId(c.hostel);
  final bySlug = {
    for (final d in [..._commonMenu, ..._coldDrinks]) d.slug: d,
  };
  return [
    for (final d in [..._commonMenu, ..._coldDrinks]) _item(id, d, shift: c.priceShift),
    for (final combo in _canteenCombos)
      () {
        final full = combo.parts.fold(0, (sum, p) => sum + _price(bySlug[p]!, c.priceShift));
        return MenuItem(
          id: '$id-${combo.slug}',
          outletId: id,
          name: combo.name,
          price: full - combo.off,
          originalPrice: full,
          category: 'Combos',
          isVeg: combo.parts.every((p) => bySlug[p]!.isVeg),
        );
      }(),
    MenuItem(
      id: '$id-special',
      outletId: id,
      name: c.special.name,
      price: c.special.price,
      category: 'House special',
      isVeg: c.special.isVeg,
    ),
  ];
}

final seedMenu = [
  for (final c in _canteens) ..._canteenMenu(c),

  // Tapri
  const MenuItem(id: 'tapri-chai', outletId: 'tapri', name: 'Kadak Chai', price: 10, category: 'Chai'),
  const MenuItem(id: 'tapri-ginger-chai', outletId: 'tapri', name: 'Adrak Chai', price: 15, category: 'Chai'),
  const MenuItem(id: 'tapri-maggi', outletId: 'tapri', name: 'Plain Maggi', price: 30, category: 'Maggi'),
  const MenuItem(
    id: 'tapri-egg-maggi',
    outletId: 'tapri',
    name: 'Egg Maggi',
    price: 40,
    category: 'Maggi',
    isVeg: false,
  ),
  const MenuItem(id: 'tapri-bun-maska', outletId: 'tapri', name: 'Bun Maska', price: 20, category: 'Snacks'),
  const MenuItem(id: 'tapri-biscuit', outletId: 'tapri', name: 'Parle-G (2 packs)', price: 10, category: 'Snacks'),
  for (final d in _coldDrinks) _item('tapri', d),
  const MenuItem(
    id: 'tapri-combo-chai-bun',
    outletId: 'tapri',
    name: 'Chai + Bun Maska',
    price: 25,
    originalPrice: 30,
    category: 'Combos',
  ),
  const MenuItem(
    id: 'tapri-combo-maggi-chai',
    outletId: 'tapri',
    name: 'Maggi + Chai',
    price: 35,
    originalPrice: 40,
    category: 'Combos',
  ),

  // Sharma Snacks (FPS)
  const MenuItem(id: 'sharma-samosa', outletId: 'sharma-snacks', name: 'Samosa (2)', price: 20, category: 'Snacks'),
  const MenuItem(id: 'sharma-pattice', outletId: 'sharma-snacks', name: 'Veg Pattice', price: 20, category: 'Snacks'),
  const MenuItem(
    id: 'sharma-egg-pattice',
    outletId: 'sharma-snacks',
    name: 'Egg Pattice',
    price: 25,
    category: 'Snacks',
    isVeg: false,
  ),
  const MenuItem(
    id: 'sharma-bread-pakoda',
    outletId: 'sharma-snacks',
    name: 'Bread Pakoda',
    price: 20,
    category: 'Snacks',
  ),
  const MenuItem(id: 'sharma-chai', outletId: 'sharma-snacks', name: 'Chai', price: 10, category: 'Drinks'),
  for (final d in _coldDrinks.take(4)) _item('sharma-snacks', d),
  const MenuItem(
    id: 'sharma-combo-samosa-chai',
    outletId: 'sharma-snacks',
    name: 'Samosa (2) + Chai',
    price: 25,
    originalPrice: 30,
    category: 'Combos',
  ),
  const MenuItem(
    id: 'sharma-combo-snack-box',
    outletId: 'sharma-snacks',
    name: 'Snack Box: Samosa, Pattice, Bread Pakoda',
    price: 50,
    originalPrice: 60,
    category: 'Combos',
  ),

  // Kolkata Puchka (FPS)
  const MenuItem(id: 'kp-puchka', outletId: 'kolkata-puchka', name: 'Puchka (6)', price: 20, category: 'Puchka'),
  const MenuItem(id: 'kp-puchka-12', outletId: 'kolkata-puchka', name: 'Puchka (12)', price: 35, category: 'Puchka'),
  const MenuItem(
    id: 'kp-dahi-puchka',
    outletId: 'kolkata-puchka',
    name: 'Dahi Puchka (6)',
    price: 40,
    category: 'Puchka',
  ),
  const MenuItem(id: 'kp-aloo-chaat', outletId: 'kolkata-puchka', name: 'Aloo Chaat', price: 30, category: 'Chaat'),
  const MenuItem(id: 'kp-papdi-chaat', outletId: 'kolkata-puchka', name: 'Papdi Chaat', price: 35, category: 'Chaat'),
  const MenuItem(
    id: 'kp-combo-puchka-chaat',
    outletId: 'kolkata-puchka',
    name: 'Puchka (6) + Aloo Chaat',
    price: 45,
    originalPrice: 50,
    category: 'Combos',
  ),

  // Babloo FPS
  const MenuItem(id: 'babloo-pattice', outletId: 'babloo-fps', name: 'Veg Pattice', price: 20, category: 'Snacks'),
  const MenuItem(
    id: 'babloo-chicken-pattice',
    outletId: 'babloo-fps',
    name: 'Chicken Pattice',
    price: 30,
    category: 'Snacks',
    isVeg: false,
  ),
  const MenuItem(
    id: 'babloo-bread-pakoda',
    outletId: 'babloo-fps',
    name: 'Bread Pakoda',
    price: 20,
    category: 'Snacks',
  ),
  const MenuItem(id: 'babloo-samosa', outletId: 'babloo-fps', name: 'Samosa (2)', price: 20, category: 'Snacks'),
  for (final d in _coldDrinks) _item('babloo-fps', d),
  const MenuItem(
    id: 'babloo-combo-pattice-coke',
    outletId: 'babloo-fps',
    name: 'Pattice + Coke',
    price: 35,
    originalPrice: 40,
    category: 'Combos',
  ),
];
