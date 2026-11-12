import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/app_config.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

/// Titik masuk aplikasi Profil Mahasiswa dengan Catatan Kuliah.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format tanggal berbahasa Indonesia untuk NoteCard.
  await initializeDateFormatting('id_ID');

  // Konfigurasi dibaca dari .env, bukan hardcoded di kode sumber.
  await AppConfig.load();

  runApp(const ResponsiApp());
}

/// Root widget aplikasi.
class ResponsiApp extends StatelessWidget {
  /// Membuat aplikasi.
  const ResponsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviderWrapper(
      child: MaterialApp(
        title: 'Profil Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

/// Tema terpusat agar seluruh layar konsisten.
ThemeData _buildTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1B5E20),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: false,
      elevation: 0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: scheme.primary,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
  );
}
