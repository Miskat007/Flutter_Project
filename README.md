# NOVA Store — Flutter Product Catalogue

A Flutter assignment project demonstrating REST API integration, JSON parsing, CRUD, local persistence, pagination, search, state management, responsive UI, and error handling.

## API used

**DummyJSON Products API:** https://dummyjson.com/docs/products

Endpoints used:

| Purpose | Endpoint |
|---|---|
| List products | `GET /products?limit=20&skip=0` |
| Search | `GET /products/search?q=phone&limit=20&skip=0` |
| Product detail data | `GET /products/{id}` (list response includes detail fields) |
| Create simulation | `POST /products/add` |
| Update simulation | `PUT /products/{id}` |
| Delete simulation | `DELETE /products/{id}` |

**Important API limitation:** DummyJSON documents that add, update, and delete requests return simulated responses and do not permanently change the server dataset. This project calls the write endpoints for practice and persists the actual app changes in Hive. Thus locally created/edited/deleted products remain consistent on the device and are available offline.

## Features

- Splash screen with automatic navigation
- Responsive product grid (2 columns on phones, 3 on tablets, 4 on wide screens)
- Product cards with image, title, category, price, and rating
- Product detail page with description, brand, stock, and additional images
- Debounced search (350 ms)
- Create, edit, and delete products
- Hive persistence for downloaded products and local CRUD changes
- Offline fallback using previously cached products
- Infinite scroll using DummyJSON `limit` and `skip`
- Pull-to-refresh
- Favorites stored locally
- Light/dark theme toggle
- Loading, empty, image-error, and network-error states
- Provider state management and repository/data-source separation

## Packages

- `dio` — HTTP client
- `provider` — state management
- `hive`, `hive_flutter` — local database/cache
- `cached_network_image` — product image loading and disk caching
- `flutter_lints` — lint rules

## Architecture

```text
lib/
├── data/
│   ├── datasources/
│   │   ├── product_local_data_source.dart
│   │   └── product_remote_data_source.dart
│   ├── models/
│   │   └── product.dart
│   └── repositories/
│       └── product_repository.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── product_form_screen.dart
│   │   └── splash_screen.dart
│   └── widgets/
│       └── product_card.dart
├── providers/
│   └── product_provider.dart
└── main.dart
```

## How to run

1. Install Flutter and Android Studio (or another Flutter-supported IDE).
2. Create a Flutter project folder, or use this folder as the project root.
3. Ensure the `pubspec.yaml` and `lib/` directory from this project are in the root.
4. Run:

   ```bash
   flutter pub get
   flutter analyze
   flutter run
   ```

5. For Android APK:

   ```bash
   flutter build apk --release
   ```

   APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Android internet permission

Flutter's standard Android template normally includes internet permission for debug builds. Confirm that `android/app/src/main/AndroidManifest.xml` contains this line inside the `<manifest>` element:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Offline behavior

On a successful API page fetch, products are stored in Hive. If a later request fails, the app loads saved products from Hive. Local product writes and favorite changes are persisted immediately. Network image files are cached by `cached_network_image` on supported mobile platforms; product metadata and CRUD records are stored separately in Hive.

## Screenshots for submission

Capture these screens on a real device or emulator and add them under `screenshots/`:

- `01_splash.png`
- `02_home.png`
- `03_search.png`
- `04_product_details.png`
- `05_add_product.png`
- `06_edit_product.png`
- `07_favorites.png`
- `08_dark_mode.png`
- `09_offline_mode.png`

Then add them to this README, for example:

```markdown
![Home screen](screenshots/02_home.png)
```

## Suggested Git commit sequence

- `chore: create Flutter project structure`
- `feat: add DummyJSON product data source`
- `feat: add Hive product cache`
- `feat: implement Provider state management`
- `feat: build responsive product catalogue`
- `feat: add product details and local CRUD`
- `feat: add search pagination and favorites`
- `feat: add offline and theme support`
- `docs: write project README`

## Rubric coverage

| Evaluation area | Implementation |
|---|---|
| UI Design (15) | Material 3, responsive grid, splash, details, form |
| API Integration (20) | Dio, DummyJSON products, search, JSON model |
| CRUD (20) | POST/PUT/DELETE calls plus persistent local CRUD |
| Local Cache (15) | Hive product cache and offline fallback |
| Pagination (10) | Infinite scrolling with limit/skip |
| State Management (10) | Provider / ChangeNotifier |
| Code Quality (5) | Models, data sources, repository, provider, screens |
| Documentation (5) | This README |

## Notes

- The first successful launch requires internet access to populate the initial cache.
- The app cannot show products that have never been downloaded while offline.
- DummyJSON is a demo API, not a production backend.
- Test on both a narrow phone emulator and a wider tablet emulator before submission.
