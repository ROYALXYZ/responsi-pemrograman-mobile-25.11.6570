# Laporan Responsi Pemrograman Mobile

## Identitas

- Nama: **[Nama Mahasiswa]**
- NIM: **[NIM]**
- Kelas: **[Kelas]**
- Mata Kuliah: Pemrograman Mobile (ST407) — Praktikum
- Program Studi: S1 Informatika, Universitas Amikom Yogyakarta

## 1. Deskripsi Aplikasi

Aplikasi **Profil Mahasiswa dengan Catatan Kuliah** dibangun dengan Flutter dan
memiliki dua fitur utama:

1. **Profil Mahasiswa** — menampilkan nama, NIM, program studi, dan email pada
   `ProfileCard`, dengan avatar `CircleAvatar` berisi inisial nama. Data dapat
   diubah melalui formulir edit profil yang tervalidasi dan tersimpan lokal.
2. **Catatan Kuliah** — menambah, melihat detail, dan menghapus catatan. Judul
   dan isi catatan divalidasi serta disanitasi sebelum disimpan. Metadata
   catatan (id, judul, tanggal) disimpan di `SharedPreferences`, sedangkan isi
   catatan disimpan terenkripsi di `flutter_secure_storage`.

Sebagai pelengkap, aplikasi menyediakan tab **Info Kampus** yang mengambil data
`posts` dari API publik (`https://jsonplaceholder.typicode.com`) menggunakan
`package:http`, lengkap dengan state loading, error, dan aksi coba lagi.

## 2. Arsitektur Aplikasi

```
        UI Layer
  HomeScreen / ProfileScreen / NoteFormScreen
  ProfileCard / NoteCard / EmptyState
                │
                │ AppProvider.of(context)
                ▼
        Provider Layer
  AppProvider (InheritedWidget)
  AppProviderWrapper (StatefulWidget, sumber state)
                │
                ▼
        Repository Layer
  NoteRepository            PostRepository
                │                 │
                ▼                 ▼
        Storage Layer
  SharedPreferences  → metadata catatan + profil mahasiswa
  flutter_secure_storage → isi catatan (note_content_<id>)
  package:http       → API publik (BASE_URL dari .env)
```

Alur data satu arah: UI membaca state dari `AppProvider` dan memanggil aksi
(`addNote`, `deleteNote`, `updateStudent`); wrapper memanggil repository;
repository menyentuh storage; hasilnya dikembalikan ke state sehingga UI
dirender ulang.

## 3. Penerapan Sub-CPMK

### 3.1 sub.cpmk.ST407.CPMK051.1 — Instalasi, Struktur Proyek, dan Git

- Proyek dibuat dengan `flutter create --project-name responsi_profil_mahasiswa`.
- Struktur direktori mengikuti spesifikasi (`config/`, `models/`, `repositories/`,
  `providers/`, `screens/`, `services/`, `utils/`, `widgets/`).
- Git digunakan dengan **lebih dari 10 commit** dan **2 branch fitur**:

```bash
$ git log --graph --oneline --all
* 44ec558 feat(ui): tambah HomeScreen bertab, navigasi, HTTP info kampus, dan tema terpusat
*   4e5f15a merge: integrasikan fitur catatan ke main
|\
| * 437f152 feat(catatan): tambah form catatan tervalidasi beserta NoteCard dan EmptyState
| * 2ef6b5b feat(catatan): tambah SecureStorageService dan NoteRepository
|/
*   c7b3e38 merge: integrasikan fitur profil ke main
|\
| * a67f30a feat(profil): tambah AppProvider dan layar profil mahasiswa
|/
* 325c6ff feat(model): tambah model Student/Note, validators, dan konfigurasi .env
* 6f2a720 chore(init): scaffold proyek Flutter dan tambahkan dependency
```

> **[Screenshot `git log --graph --oneline --all`]**

- `.gitignore` mengabaikan `.env`, `build/`, dan `.dart_tool/` (`.env.example`
  tetap di-commit sebagai template).

### 3.2 sub.cpmk.ST407.CPMK051.2 — Widget Modular dan Separation of Concerns

- Model `Student` (`name`, `nim`, `programStudi`, `email`) dilengkapi
  `copyWith`, `toJson`/`fromJson`, dan getter `initials` untuk avatar.
- `ProfileScreen` hanya mengatur komposisi layout; tampilan kartu dipisahkan ke
  `ProfileCard` yang dipakai ulang pada header `HomeScreen` (mode `compact`).
- Layout memakai `Row`, `Column`, `Container`/`Card`, dan `EdgeInsets` secara
  konsisten (`EdgeInsets.all`, `fromLTRB`, `only`).
- Logika data tidak berada di widget: seluruh akses data melewati
  `AppProvider` → `NoteRepository` → storage.

> **[Screenshot `lib/screens/profile_screen.dart` dan tampilan profil]**

### 3.3 sub.cpmk.ST407.CPMK051.3 — State Management dan Validasi Input

- `AppProvider` adalah turunan `InheritedWidget` yang menyediakan `student`,
  `notes`, `updateStudent`, `addNote`, dan `deleteNote`.
- `AppProviderWrapper` (turunan `StatefulWidget`) memegang state sebenarnya dan
  menyediakan `AppProvider` ke seluruh subtree (`updateShouldNotify` hanya
  memberi tahu bila data berubah).
- `NoteFormScreen` memakai `Form` + `TextFormField` dengan `GlobalKey<FormState>`
  dan validator terpusat di `Validators`:

| Validator | Aturan |
|---|---|
| `validateTitle` | wajib, 3–50 karakter |
| `validateContent` | wajib, 10–1000 karakter |
| `sanitize` | meng-escape `&`, `<`, `>`, `"`, `'` |

- Prinsip *least privilege*: setiap layar hanya memanggil aksi provider yang
  dibutuhkannya, dan `NoteFormScreen` hanya mengubah daftar catatan — tidak
  pernah menyentuh state profil.

> **[Screenshot form catatan dengan pesan error validasi]**

### 3.4 sub.cpmk.ST407.CPMK051.4 — Penyimpanan Lokal, Keamanan, dan HTTP

- `SecureStorageService` menyediakan `saveContent`, `getContent`, dan
  `deleteContent` dengan kunci `note_content_<id>` pada
  `flutter_secure_storage`.
- `NoteRepository` menyimpan metadata sebagai JSON list di
  `SharedPreferences` (`notes_metadata`); isi catatan tidak pernah ikut
  terserialisasi ke preferensi (`Note.toMetadata` sengaja tanpa `content`).
- `AppConfig` memuat `BASE_URL` dan `API_KEY` dari `.env` melalui
  `flutter_dotenv`; tidak ada kredensial hardcoded dan `.env` di-ignore Git.
- `PostRepository` melakukan `GET {BASE_URL}/posts` dengan `timeout` 10 detik
  dan penanganan `SocketException`, `TimeoutException`, `ClientException`,
  serta `FormatException` yang dikonversi menjadi pesan ramah pengguna.
- Logging aman: hanya `GET /posts -> 200` dan jenis error yang dicetak; isi
  catatan, API key, dan data sensitif tidak pernah masuk log.
- `AndroidManifest.xml`: `<uses-permission android:name="android.permission.INTERNET"/>`
  dan `android:allowBackup="false"`.
- Seluruh fungsi publik didokumentasikan dengan komentar `///` (dartdoc).

> **[Screenshot kode `SecureStorageService`, `NoteRepository`, dan `.env`]**

## 4. Screenshot Aplikasi

| Layar | Keterangan |
|---|---|
| **[Screenshot beranda — daftar catatan]** | `HomeScreen`: profil singkat, `ListView.builder` + `NoteCard` |
| **[Screenshot empty state]** | `EmptyState` saat belum ada catatan |
| **[Screenshot form catatan]** | `NoteFormScreen` dengan pesan validasi |
| **[Screenshot dialog hapus]** | `AlertDialog` konfirmasi sebelum menghapus |
| **[Screenshot profil]** | `ProfileCard` lengkap pada `ProfileScreen` |
| **[Screenshot info kampus]** | Data API pada `ListView` + state error/retry |

## 5. Kendala dan Solusi

| Kendala | Solusi |
|---|---|
| `.env` di-ignore Git sehingga berkas asset hilang saat proyek di-clone | Menyediakan `.env.example` dan mendokumentasikan `copy .env.example .env` pada README |
| `flutter_secure_storage` tidak tersedia pada sebagian platform desktop | Aplikasi ditargetkan ke Android/iOS; storage diakses lewat abstraksi `SecureStorageService` sehingga mudah diganti saat pengujian |
| Isi catatan berisiko bocor ke `SharedPreferences` | Metadata dan isi dipisah: `Note.toMetadata()` tidak menyertakan `content`, isi hanya ditulis ke secure storage |
| `BuildContext` dipakai setelah `await` (peringatan `use_build_context_synchronously`) | Provider dan `ScaffoldMessenger` diambil sebelum `await`, lalu dijaga dengan pengecekan `mounted` |
| Tanggal berbahasa Indonesia memicu `LocaleDataException` | `initializeDateFormatting('id_ID')` dipanggil sekali pada `main()` |

## 6. Link Repositori

`https://github.com/<username>/responsi-pemrograman-mobile-<NIM>`
