import 'package:material_ui/material_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/datasources/product_local_data_source.dart';
import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository.dart';
import 'providers/product_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('products');
  await Hive.openBox('favorites');
  await Hive.openBox('app_settings');

  final local = ProductLocalDataSource(
    productsBox: Hive.box('products'),
    favoritesBox: Hive.box('favorites'),
  );
  final remote = ProductRemoteDataSource();
  final repository = ProductRepository(remote: remote, local: local);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(repository)..loadInitial(),
      child: const ProductStoreApp(),
    ),
  );
}

class ProductStoreApp extends StatelessWidget {
  const ProductStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('app_settings');
    return ValueListenableBuilder(
      valueListenable: settings.listenable(keys: ['darkMode']),
      builder: (context, box, _) {
        final isDark = box.get('darkMode', defaultValue: false) as bool;
        return MaterialApp(
          title: 'NOVA Store',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5FEF),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF7F7FB)
          : const Color(0xFF11121A),
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
