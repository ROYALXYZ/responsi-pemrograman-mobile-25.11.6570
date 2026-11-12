/// Model data profil mahasiswa.
class Student {
  /// Membuat data profil mahasiswa.
  const Student({
    this.name = '',
    this.nim = '',
    this.programStudi = '',
    this.email = '',
  });

  /// Profil kosong yang dipakai sebelum pengguna mengisi data.
  static const Student empty = Student();

  /// Nama lengkap mahasiswa.
  final String name;

  /// Nomor Induk Mahasiswa.
  final String nim;

  /// Program studi mahasiswa.
  final String programStudi;

  /// Alamat email mahasiswa.
  final String email;

  /// Menyalin profil dengan sebagian field diganti.
  Student copyWith({
    String? name,
    String? nim,
    String? programStudi,
    String? email,
  }) {
    return Student(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
    );
  }

  /// Membaca profil dari representasi JSON.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: (json['name'] as String?) ?? '',
      nim: (json['nim'] as String?) ?? '',
      programStudi: (json['programStudi'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }

  /// Mengubah profil menjadi representasi JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'nim': nim,
      'programStudi': programStudi,
      'email': email,
    };
  }

  /// Inisial nama untuk ditampilkan pada `CircleAvatar` (maksimal dua huruf).
  String get initials {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return 'M';
    }
    final String first = words.first.substring(0, 1);
    if (words.length == 1) {
      return first.toUpperCase();
    }
    final String second = words[1].substring(0, 1);
    return '$first$second'.toUpperCase();
  }

  /// `true` bila nama dan NIM sudah diisi.
  bool get isComplete => name.trim().isNotEmpty && nim.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is Student &&
        other.name == name &&
        other.nim == nim &&
        other.programStudi == programStudi &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(name, nim, programStudi, email);

  @override
  String toString() => 'Student(nim: $nim)';
}
