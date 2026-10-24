# Campus Crave

Campus food delivery for NIT Silchar, built with Flutter (web first).

Students order from campus outlets and get food delivered to their hostel or building. Delivery is peer-to-peer: any student can switch on **runner mode**, pick up open orders and earn the delivery fee. Vendors get a live order board and manage their own menu.

## Features

**Students**
- Browse hostel canteens and cafés; your own hostel's canteen is pinned first
- Search a dish to compare its price across every canteen that sells it
- Menus with veg filter and categories
- Combo deals and cold drinks on every menu
- One-outlet cart; hostel drops need a room number; phone number required so the runner can call
- Bill: items + ₹15 delivery (to the runner) + ₹3–5 convenience fee; wallet balance applied automatically
- Live order tracking: placed → accepted → preparing → ready → on the way → delivered
- Cancel while the order is still waiting for the outlet

**Runners** (students who opt in)
- Feed of orders the outlet has accepted, excluding your own
- Claim a delivery, mark it picked up and delivered; the ₹15 fee lands in their wallet to spend on their own orders

**Vendors**
- Order board (new / in the kitchen / ready) — columns on desktop, stacked on mobile
- Accept or decline, move orders through prep, open/close the outlet
- Add and edit menu items, mark items sold out

## Stack

- Flutter 3 (Material 3), web first
- Riverpod for state, go_router for navigation with role-based redirects
- Firebase (Auth: Google + phone OTP, Firestore, Hosting) — being wired in
- Razorpay test mode for checkout — planned

## Project layout

```
lib/
  app/         theme and router
  models/      User, Outlet, MenuItem, Order
  data/        Repository interface, in-memory implementation, seed data
  state/       Riverpod providers (session, catalogue, orders, cart)
  features/    welcome, auth, student, runner, vendor, profile screens
  widgets/     shared UI pieces
```

All data access goes through `Repository`, so the UI does not change when the backend moves from the in-memory implementation to Firestore.

## Run locally

```sh
flutter pub get
flutter run -d chrome
flutter test
```

Until Firebase is connected, sign-in is simulated (any 6-digit OTP works) and data lives in memory for the session.
