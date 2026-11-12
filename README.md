# Responsi Pemrograman Mobile — Profil Mahasiswa dengan Catatan Kuliah

Aplikasi Flutter untuk menampilkan profil mahasiswa dan mengelola catatan kuliah
dengan validasi input, penyimpanan lokal aman, serta pengambilan data dari API
publik.

## Fitur

1. **Profil Mahasiswa** — nama, NIM, program studi, email, avatar inisial, dan
   formulir edit profil yang tervalidasi.
2. **Catatan Kuliah** — tambah, lihat detail, dan hapus catatan dengan dialog
   konfirmasi.
3. **Info Kampus** — daftar `posts` dari API publik beserta state loading,
   error, dan retry.

## Struktur Proyek

```
lib/
├── main.dart                 # entry point + tema terpusat
├── config/app_config.dart    # pembacaan .env (BASE_URL, API_KEY)
├── models/                   # Student, Note
├── repositories/            # NoteRepository, PostRepository
├── providers/app_provider.dart  # InheritedWidget + AppProviderWrapper
├── screens/                 # HomeScreen, ProfileScreen, NoteFormScreen
├── services/                # SecureStorageService
├── utils/validators.dart    # validasi + sanitasi input
└── widgets/                 # ProfileCard, NoteCard, EmptyState
```

## Arsitektur

```
UI (screens/widgets)
      │  AppProvider.of(context)
      ▼
Provider (AppProviderWrapper / InheritedWidget)
      │
      ▼
Repository (NoteRepository, PostRepository)
      │
      ├── SharedPreferences  → metadata catatan (id, judul, tanggal) + profil
      ├── SecureStorage      → isi catatan terenkripsi (note_content_<id>)
      └── HTTP (package:http) → API publik dari BASE_URL
```

## Setup

```bash
flutter pub get
cp .env.example .env     # Windows: copy .env.example .env
flutter run
```

`.env` berisi konfigurasi runtime dan **tidak** di-commit:

```
BASE_URL=https://jsonplaceholder.typicode.com
API_KEY=dummy-api-key-123
```

> Build akan gagal bila `.env` belum dibuat, karena berkas ini didaftarkan
> sebagai asset di `pubspec.yaml` (dibaca oleh `flutter_dotenv`).

## Keamanan

- Isi catatan disimpan terenkripsi di `flutter_secure_storage`, bukan di
  `SharedPreferences`.
- Metadata di `SharedPreferences` hanya berisi `id`, `title`, `createdAt`.
- Tidak ada kredensial hardcoded; API key dibaca dari `.env`.
- Log hanya mencatat endpoint, status HTTP, dan jenis error — tidak pernah isi
  catatan, token, atau data sensitif.
- Seluruh input divalidasi (`Validators`) dan disanitasi sebelum disimpan.
- `AndroidManifest.xml`: `INTERNET` permission dan `android:allowBackup="false"`.

## Pengujian

```bash
flutter analyze
flutter test
```

## Git

Riwayat dikerjakan dengan dua branch fitur yang di-merge ke `main`:

```bash
git log --graph --oneline --all
```

## Repositori

`https://github.com/<username>/responsi-pemrograman-mobile-<NIM>`
