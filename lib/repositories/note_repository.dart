import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../services/secure_storage_service.dart';

/// Repository yang mengelola seluruh akses data catatan kuliah.
///
/// Pembagian penyimpanan:
/// * metadata (`id`, `title`, `createdAt`) → `SharedPreferences` (JSON list),
/// * isi catatan (`content`) → [SecureStorageService] (terenkripsi).
class NoteRepository {
  /// Membuat repository; [secureStorage] dapat diganti saat pengujian.
  NoteRepository({SecureStorageService? secureStorage})
    : _secureStorage = secureStorage ?? SecureStorageService();

  static const String _metadataKey = 'notes_metadata';

  final SecureStorageService _secureStorage;

  /// Mengambil seluruh catatan, terbaru lebih dahulu.
  Future<List<Note>> fetchNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> metadata = _decodeMetadata(
      prefs.getString(_metadataKey),
    );

    final List<Note> notes = <Note>[];
    for (final Map<String, dynamic> item in metadata) {
      final Note note = Note.fromMetadata(item);
      final String? content = await _secureStorage.getContent(note.id);
      notes.add(note.copyWith(content: content ?? ''));
    }

    notes.sort((Note a, Note b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  /// Menyimpan catatan baru atau memperbarui catatan yang sudah ada.
  Future<void> saveNote(Note note) async {
    await _secureStorage.saveContent(note.id, note.content);

    final List<Note> notes = await fetchNotes();
    final int index = notes.indexWhere((Note item) => item.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    notes.sort((Note a, Note b) => b.createdAt.compareTo(a.createdAt));

    await _writeMetadata(notes);
    debugPrint('Catatan disimpan (id=${note.id}).');
  }

  /// Menghapus catatan beserta isi terenkripsinya.
  Future<void> deleteNote(String noteId) async {
    await _secureStorage.deleteContent(noteId);

    final List<Note> notes = await fetchNotes();
    notes.removeWhere((Note item) => item.id == noteId);
    await _writeMetadata(notes);
    debugPrint('Catatan dihapus (id=$noteId).');
  }

  Future<void> _writeMetadata(List<Note> notes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> metadata = notes
        .map((Note note) => note.toMetadata())
        .toList();
    await prefs.setString(_metadataKey, jsonEncode(metadata));
  }

  List<Map<String, dynamic>> _decodeMetadata(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }
      return decoded.whereType<Map<String, dynamic>>().toList();
    } on FormatException {
      debugPrint('Metadata catatan rusak, data diabaikan.');
      return <Map<String, dynamic>>[];
    }
  }
}
