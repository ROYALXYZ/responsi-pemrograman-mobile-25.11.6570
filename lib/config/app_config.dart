import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi aplikasi yang dimuat dari berkas `.env`.
///
/// Seluruh nilai sensitif (mis. [_apiKey]) dibaca saat runtime sehingga tidak
/// ada kredensial yang ditulis langsung di dalam kode sumber.
class AppConfig {
  AppConfig._();

  static const String _envFile = '.env';
  static const String _baseUrlKey = 'BASE_URL';
  static const String _apiKeyKey = 'API_KEY';

  static bool _loaded = false;

  /// Memuat isi berkas `.env` ke dalam memori.
  ///
  /// [load] harus dipanggil sekali sebelum `runApp`.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: _envFile);
      _loaded = true;
    } catch (_) {
      // Tanpa `.env` aplikasi tetap berjalan, fitur HTTP dinonaktifkan.
      _loaded = false;
    }
  }

  /// `true` bila `.env` berhasil dimuat.
  static bool get isLoaded => _loaded;

  /// Alamat dasar API tanpa garis miring di akhir.
  static String get baseUrl {
    final String value = _value(_baseUrlKey);
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  /// API key (nilai dummy untuk latihan).
  ///
  /// Jangan pernah mencetak nilai ini ke log.
  static String get apiKey => _value(_apiKeyKey);

  /// `true` bila `BASE_URL` tersedia pada `.env`.
  static bool get hasBaseUrl => baseUrl.isNotEmpty;

  /// Menyusun [Uri] untuk [path] relatif terhadap [baseUrl].
  static Uri endpoint(String path) {
    final String normalized = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$normalized');
  }

  static String _value(String key) {
    if (!_loaded) {
      return '';
    }
    return (dotenv.env[key] ?? '').trim();
  }
}
