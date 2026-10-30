# Course Explorer

Aplikasi Flutter untuk mengelola daftar course (Course Data Manager) dengan
backend Supabase. Dikembangkan bertahap pada Pemrograman Mobile, dari
state management (Pertemuan 6) sampai REST API, backend, dan database
(Pertemuan 7).

| | |
| --- | --- |
| Nama | Kadek Nova Krisna Putra |
| NIM | 2415051117 |
| Kelas | PTI 5C |
| Repository | https://github.com/kadeknova761-beep/flutter_course_explorer |

## Deskripsi dan fitur

- Home, Courses, Favorites, dan Profile dengan navigasi responsif
  (NavigationBar di bawah 840 px, NavigationRail di layar lebar).
- CRUD course terintegrasi dengan Supabase: lihat daftar, tambah, ubah
  (field `code` read-only saat edit), dan hapus dengan dialog konfirmasi.
- State loading, empty, success, dan error (dengan tombol Retry), serta
  SnackBar untuk hasil aksi.
- Favorites memakai `code` sebagai kunci dan konsisten di semua halaman.
- Pesan error yang informatif untuk kegagalan jaringan, RLS, constraint,
  dan tabel tidak ditemukan.

## Backend yang digunakan

- **Supabase** (PostgreSQL) sebagai sumber data aplikasi final.
- Tabel `public.courses`: `id` (bigint identity, PK), `code`, `title`,
  `credits` (int, > 0), `status` (CHECK: planned/active/done), `created_at`.
- Row Level Security aktif dengan 4 policy permisif untuk anon
  (`lab_select`, `lab_insert`, `lab_update`, `lab_delete`). Ini hanya untuk
  laboratorium, bukan pola produksi. SQL lengkap ada di `docs/schema.sql`.
- REST API dosen (`https://course-api-pearl.vercel.app`, resource `/courses`)
  dipakai pada Tahap 1-9 dan tetap tersedia sebagai `CourseApiService`,
  tetapi tidak lagi menjadi sumber data sejak Tahap 12.

## Arsitektur singkat

```
Screen / Widget  ->  Provider  ->  Repository  ->  CourseDataSource (abstract)
                                                     |-- CourseSupabaseService (aktif)
                                                     |-- CourseApiService (REST, cadangan)
```

Layer di sebelah kiri boleh memakai layer di sebelah kanannya, tetapi tidak
sebaliknya. UI tidak mengakses Supabase atau HTTP secara langsung. Sumber data
bisa diganti dengan mengubah perakitan di `main.dart`
(`CourseSupabaseService -> CourseRepository -> CourseProvider`).

| Folder / file (`lib/`) | Tanggung jawab |
| --- | --- |
| `main.dart` | Inisialisasi Supabase dan perakitan Provider. |
| `app.dart` | `MaterialApp`, tema, dan halaman awal. |
| `models/` | Model `Course` dan parsing JSON. |
| `services/` | `CourseDataSource` (abstract), `CourseSupabaseService`, `CourseApiService`. |
| `repositories/` | Perantara provider dan data source. |
| `providers/` | State course (loading, error, data) dan favorites. |
| `screens/` | Halaman: shell navigasi, Courses, detail, form, Favorites, Profile. |
| `widgets/` | Komponen reusable: `CourseCard`, `CourseStateGate`, `ErrorView`, dll. |
| `constants/` | `api_config`, `supabase_config`, `student_identity`. |
| `utils/` | Helper murni, misalnya ikon dan label status course. |

## Cara menjalankan

Persyaratan: Flutter 3.47.3 (Dart 3.13.3), akun dan project Supabase milik
sendiri dengan tabel `courses` (jalankan `docs/schema.sql` di SQL Editor).

1. Salin `env.example.json` menjadi `env.json`, lalu isi `SUPABASE_URL` dan
   `SUPABASE_ANON_KEY` dengan URL project dan key **publishable** dari
   Supabase (Project Settings > API Keys). `env.json` sudah ada di
   `.gitignore` dan tidak boleh di-commit.
2. Jalankan:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

Perubahan di `main()` atau `dart-define` butuh stop lalu run ulang penuh.
Perubahan di file service atau UI cukup Hot Restart (tekan `R` di terminal).

## Keamanan

- Key `service_role` tidak dipakai dan tidak boleh ada di aplikasi maupun Git.
- Hanya key publishable yang dipakai, dibaca dari `env.json` lewat
  `--dart-define-from-file`. Yang di-commit hanya `env.example.json`
  berisi placeholder.
- RLS adalah lapisan keamanan di backend. Validasi di UI tidak menggantikan
  validasi dan otorisasi di backend.

## Status Tahap 17: error handling

`CourseSupabaseService` memakai helper `_guard` yang menerjemahkan error
menjadi pesan yang mudah dipahami: kode 42501 (RLS), 23514 (constraint),
PGRST205 (tabel tidak ditemukan), gangguan jaringan, dan error lain.

Temuan pengujian:
- RLS tidak melempar error pada update/delete tanpa policy (0 baris terkena).
- Kolom `code` belum UNIQUE sehingga kode kembar bisa masuk.
- Id identity loncat setelah insert gagal (perilaku normal).

## Known issues dan rencana perbaikan

- `main.dart`: import `constants/api_config.dart` tidak terpakai.
- `main.dart`: parameter `anonKey` pada `Supabase.initialize` sudah
  deprecated, rencana diganti `publishableKey`.
- Tambahkan constraint UNIQUE pada kolom `code`.
- Policy permisif perlu diganti dengan autentikasi sebelum dipakai produksi.

Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C