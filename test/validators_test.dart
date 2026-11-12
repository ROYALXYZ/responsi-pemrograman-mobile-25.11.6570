import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_profil_mahasiswa/utils/validators.dart';

void main() {
  group('Validators', () {
    test('judul: batas 3-50 karakter', () {
      expect(Validators.validateTitle(''), isNotNull);
      expect(Validators.validateTitle('ab'), isNotNull);
      expect(Validators.validateTitle('abc'), isNull);
      expect(Validators.validateTitle('a' * 50), isNull);
      expect(Validators.validateTitle('a' * 51), isNotNull);
    });

    test('isi: batas 10-1000 karakter', () {
      expect(Validators.validateContent('123456789'), isNotNull);
      expect(Validators.validateContent('1234567890'), isNull);
      expect(Validators.validateContent('a' * 1000), isNull);
      expect(Validators.validateContent('a' * 1001), isNotNull);
    });

    test('sanitize membuang karakter berbahaya', () {
      final String clean = Validators.sanitize('<b>"x"</b> & \'y\'');
      expect(clean.contains('<'), isFalse);
      expect(clean.contains('>'), isFalse);
      expect(clean.contains('"'), isFalse);
      expect(clean.contains("'"), isFalse);
      expect(clean.contains('&lt;b&gt;'), isTrue);
    });

    test('email dan NIM', () {
      expect(Validators.validateEmail('a@b.com'), isNull);
      expect(Validators.validateEmail('bukan-email'), isNotNull);
      expect(Validators.validateNim('21.11.4499'), isNull);
      expect(Validators.validateNim('a'), isNotNull);
    });
  });
}
