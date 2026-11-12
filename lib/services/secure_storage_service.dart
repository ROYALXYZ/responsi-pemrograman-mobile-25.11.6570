import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Layanan penyimpanan isi catatan secara terenkripsi.
///
/// Setiap isi catatan disimpan dengan kunci `note_content_<id>` sehingga
/// metadata di `SharedPreferences` tidak pernah berisi teks catatan.
class SecureStorageService {
  /// Membuat layanan; [storage] dapat diganti saat pengujian.
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _contentPrefix = 'note_content_';

  final FlutterSecureStorage _storage;

  String _key(String noteId) => '$_contentPrefix$noteId';

  /// Menyimpan isi catatan terenkripsi untuk [noteId].
  Future<void> saveContent(String noteId, String content) {
    return _storage.write(key: _key(noteId), value: content);
  }

  /// Membaca isi catatan milik [noteId], `null` bila belum ada.
  Future<String?> getContent(String noteId) {
    return _storage.read(key: _key(noteId));
  }

  /// Menghapus isi catatan milik [noteId].
  Future<void> deleteContent(String noteId) {
    return _storage.delete(key: _key(noteId));
  }
}
