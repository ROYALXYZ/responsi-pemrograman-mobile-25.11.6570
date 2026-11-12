/// Validasi dan sanitasi seluruh input pengguna.
///
/// Semua fungsi bersifat murni (tanpa efek samping) sehingga mudah diuji.
class Validators {
  Validators._();

  /// Panjang minimal judul catatan.
  static const int titleMinLength = 3;

  /// Panjang maksimal judul catatan.
  static const int titleMaxLength = 50;

  /// Panjang minimal isi catatan.
  static const int contentMinLength = 10;

  /// Panjang maksimal isi catatan.
  static const int contentMaxLength = 1000;

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _nimPattern = RegExp(r'^[0-9A-Za-z.]{4,20}$');

  /// Karakter berbahaya beserta penggantinya.
  static const Map<String, String> _escapes = <String, String>{
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  };

  /// Memvalidasi judul catatan: wajib, 3–50 karakter.
  static String? validateTitle(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Judul catatan wajib diisi';
    }
    if (text.length < titleMinLength) {
      return 'Judul minimal $titleMinLength karakter';
    }
    if (text.length > titleMaxLength) {
      return 'Judul maksimal $titleMaxLength karakter';
    }
    return null;
  }

  /// Memvalidasi isi catatan: wajib, 10–1000 karakter.
  static String? validateContent(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Isi catatan wajib diisi';
    }
    if (text.length < contentMinLength) {
      return 'Isi catatan minimal $contentMinLength karakter';
    }
    if (text.length > contentMaxLength) {
      return 'Isi catatan maksimal $contentMaxLength karakter';
    }
    return null;
  }

  /// Memvalidasi nama pada profil: wajib, 3–60 karakter.
  static String? validateName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Nama wajib diisi';
    }
    if (text.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (text.length > 60) {
      return 'Nama maksimal 60 karakter';
    }
    return null;
  }

  /// Memvalidasi NIM: wajib, 4–20 karakter alfanumerik.
  static String? validateNim(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'NIM wajib diisi';
    }
    if (!_nimPattern.hasMatch(text)) {
      return 'NIM harus 4–20 karakter angka/huruf';
    }
    return null;
  }

  /// Memvalidasi program studi: wajib diisi.
  static String? validateProgramStudi(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Program studi wajib diisi';
    }
    if (text.length > 60) {
      return 'Program studi maksimal 60 karakter';
    }
    return null;
  }

  /// Memvalidasi email: wajib dan berformat `nama@domain.tld`.
  static String? validateEmail(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Email wajib diisi';
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Membersihkan karakter berbahaya (`&`, `<`, `>`, `"`, `'`) dengan
  /// meng-escape-nya agar aman ditampilkan kembali.
  static String sanitize(String input) {
    String output = input;
    _escapes.forEach((String character, String replacement) {
      output = output.replaceAll(character, replacement);
    });
    return output.trim();
  }
}
