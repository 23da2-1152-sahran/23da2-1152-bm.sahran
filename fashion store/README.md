# SENIOR — The Editorial Boutique
### Flutter App from Figma Design

A luxury editorial fashion e-commerce app built from your Figma design.

---

## Screens Included

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Animated brand intro with fade-in |
| Login | `/login` | Sign in with email/password + social |
| Register | `/register` | Create account form |
| Home | `/main` (tab 0) | Hero banner, categories, trending grid, newsletter |
| Product Listing | `/main` (tab 1) | Asymmetric grid, filter chips |
| Product Detail | (pushed) | Gallery, size/color picker, add to cart |
| Cart | `/main` (tab 2) | Line items, quantity control, order summary |
| Checkout | (pushed from Cart) | Shipping form, payment, order confirmation |
| Profile | `/main` (tab 3) | User info, order history, saved items |

---

## Design System

- **Brand colors:** `#2D3435` (primary), `#745C00` (gold accent), `#F9F9F9` (background)
- **Typography:** Plus Jakarta Sans (headings/display) + Inter (body/labels)
- **Language:** Dart / Flutter
- **State management:** Provider

---

## Prerequisites

1. Flutter SDK ≥ 3.0.0 — https://flutter.dev/docs/get-started/install
2. VS Code + Flutter extension (or Android Studio)
3. A connected device or emulator

---

## Getting Started

```bash
# 1. Open VS Code and navigate to this folder
cd senior_fashion

# 2. Get dependencies
flutter pub get

# 3. Run on your connected device or emulator
flutter run

# Or build a release APK
flutter build apk --release
```

---

## Project Structure

```
lib/
├── main.dart               # App entry point & routing
├── app_state.dart          # Global state (cart, saved, nav)
├── theme/
│   └── app_theme.dart      # Colors, typography, theme data
├── models/
│   └── product.dart        # Product model & demo data
├── widgets/
│   └── shared_widgets.dart # AppBar, BottomNav, ProductCard
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── main_shell.dart         # Bottom nav shell
    ├── home_screen.dart
    ├── product_listing_screen.dart
    ├── product_detail_screen.dart
    ├── cart_screen.dart
    ├── checkout_screen.dart
    └── profile_screen.dart
```

---

## Notes

- Product images are loaded from Unsplash (internet connection required)
- Cart state is in-memory (resets on restart — extend with `shared_preferences` for persistence)
- Fonts loaded via `google_fonts` package (requires internet on first run, then cached)
