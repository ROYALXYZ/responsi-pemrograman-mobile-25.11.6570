/// Model satu catatan kuliah.
///
/// Metadata ([id], [title], [createdAt]) disimpan di `SharedPreferences`,
/// sedangkan [content] disimpan terenkripsi di `flutter_secure_storage`
/// sehingga tidak pernah ikut terserialisasi ke preferensi biasa.
class Note {
  /// Membuat catatan kuliah.
  const Note({
    required this.id,
    required this.title,
    required this.createdAt,
    this.content = '',
  });

  /// Membuat catatan baru beserta id unik berbasis waktu.
  factory Note.create({
    required String title,
    required String content,
    DateTime? createdAt,
  }) {
    final DateTime timestamp = createdAt ?? DateTime.now();
    return Note(
      id: timestamp.microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: timestamp,
      content: content,
    );
  }

  /// Identitas unik catatan.
  final String id;

  /// Judul catatan (sudah tersanitasi).
  final String title;

  /// Waktu catatan dibuat.
  final DateTime createdAt;

  /// Isi catatan (sudah tersanitasi), disimpan terenkripsi.
  final String content;

  /// Menyalin catatan dengan sebagian field diganti.
  Note copyWith({String? title, String? content, DateTime? createdAt}) {
    return Note(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
    );
  }

  /// Metadata saja — [content] sengaja tidak disertakan.
  Map<String, dynamic> toMetadata() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Membaca metadata catatan; [content] diisi belakangan oleh repository.
  factory Note.fromMetadata(Map<String, dynamic> json) {
    return Note(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, content);

  @override
  String toString() => 'Note(id: $id)';
}
