import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../models/student.dart';
import '../repositories/note_repository.dart';

/// Menyediakan state global aplikasi ke seluruh subtree widget.
///
/// Turunan [InheritedWidget]: widget anak hanya bergantung pada data yang
/// benar-benar dipakainya lewat [AppProvider.of].
class AppProvider extends InheritedWidget {
  /// Membuat provider dengan state dan aksi yang dikelola [AppProviderWrapper].
  const AppProvider({
    super.key,
    required this.student,
    required this.notes,
    required this.isLoading,
    required this.updateStudent,
    required this.addNote,
    required this.deleteNote,
    required super.child,
  });

  /// Profil mahasiswa aktif.
  final Student student;

  /// Seluruh catatan kuliah, terbaru lebih dahulu.
  final List<Note> notes;

  /// `true` selama data awal masih dimuat.
  final bool isLoading;

  /// Memperbarui profil mahasiswa dan menyimpannya secara lokal.
  final Future<void> Function(Student) updateStudent;

  /// Menambahkan catatan baru.
  final Future<void> Function(Note) addNote;

  /// Menghapus catatan berdasarkan [Note.id].
  final Future<void> Function(String) deleteNote;

  /// Mengambil provider terdekat di atas [context].
  static AppProvider of(BuildContext context) {
    final AppProvider? provider = context
        .dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan pada context ini.');
    return provider!;
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return oldWidget.student != student ||
        oldWidget.notes != notes ||
        oldWidget.isLoading != isLoading;
  }
}

/// Mengelola state aplikasi dan menyediakan [AppProvider] ke subtree.
class AppProviderWrapper extends StatefulWidget {
  /// Membuat wrapper yang membungkus [child].
  const AppProviderWrapper({super.key, required this.child});

  /// Subtree yang akan menerima state.
  final Widget child;

  /// Kunci penyimpanan profil pada `SharedPreferences`.
  static const String studentKey = 'student_profile';

  @override
  State<AppProviderWrapper> createState() => _AppProviderWrapperState();
}

class _AppProviderWrapperState extends State<AppProviderWrapper> {
  static const Student _defaultStudent = Student(
    name: 'Mahasiswa Amikom',
    programStudi: 'S1 Informatika',
  );

  final NoteRepository _noteRepository = NoteRepository();

  Student _student = _defaultStudent;
  List<Note> _notes = <Note>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    Student student = _defaultStudent;
    List<Note> notes = <Note>[];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawStudent = prefs.getString(
      AppProviderWrapper.studentKey,
    );
    if (rawStudent != null && rawStudent.isNotEmpty) {
      try {
        student = Student.fromJson(
          jsonDecode(rawStudent) as Map<String, dynamic>,
        );
      } on FormatException {
        debugPrint('Profil tersimpan rusak, memakai profil bawaan.');
      }
    }

    try {
      notes = await _noteRepository.fetchNotes();
    } on Exception catch (error) {
      // Hanya jenis kesalahan yang dicatat, bukan isi catatan.
      debugPrint('Gagal memuat catatan: ${error.runtimeType}');
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _student = student;
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _updateStudent(Student student) async {
    setState(() => _student = student);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppProviderWrapper.studentKey,
      jsonEncode(student.toJson()),
    );
  }

  Future<void> _addNote(Note note) async {
    await _noteRepository.saveNote(note);
    final List<Note> notes = await _noteRepository.fetchNotes();
    if (!mounted) {
      return;
    }
    setState(() => _notes = notes);
  }

  Future<void> _deleteNote(String noteId) async {
    await _noteRepository.deleteNote(noteId);
    final List<Note> notes = await _noteRepository.fetchNotes();
    if (!mounted) {
      return;
    }
    setState(() => _notes = notes);
  }

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      student: _student,
      notes: _notes,
      isLoading: _isLoading,
      updateStudent: _updateStudent,
      addNote: _addNote,
      deleteNote: _deleteNote,
      child: widget.child,
    );
  }
}
