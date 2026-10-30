# Course Explorer v2

Aplikasi Flutter untuk menjelajahi daftar course, dikembangkan pada
Pertemuan 6 Pemrograman Mobile: State Management dan Architecture.

| | |
| --- | --- |
| Nama | Kadek Nova Krisna Putra |
| NIM | 2415051117 |
| Kelas | PTI 5C |

## Fitur

- Home, Courses, Favorites, dan Profile dengan navigasi responsif
  (NavigationBar di bawah 840 px, NavigationRail di layar lebar).
- Daftar course dimuat lewat Provider, Repository, dan Service dengan
  tampilan loading, error (tombol coba lagi), dan data.
- Favorite konsisten di Home, Courses, Favorites, dan halaman detail.
- Form feedback dengan validasi, dialog konfirmasi, dan SnackBar.

## Arah dependency

```
Screen / Widget  ->  Provider  ->  Repository  ->  Service / Data Source
```

Layer di sebelah kiri boleh memakai layer di sebelah kanannya, tetapi tidak
sebaliknya. UI tidak memanggil `rootBundle` atau `jsonDecode` secara langsung,
dan layer data tidak mengenal widget maupun `BuildContext`.

## Tanggung jawab tiap folder (`lib/`)

| Folder / file | Tanggung jawab |
| --- | --- |
| `main.dart` | Titik masuk: memasang `ChangeNotifierProvider` dan menjalankan app. |
| `app.dart` | `MaterialApp`, tema, dan halaman awal. |
| `models/` | Bentuk data. `Course` dan parsing JSON lewat `Course.fromJson`. |
| `services/` | Akses sumber data (saat ini file JSON di assets). Hanya `CourseService` yang memakai `rootBundle` dan `jsonDecode`. |
| `repositories/` | Perantara antara provider dan service. Menyembunyikan asal data, sehingga sumber data bisa diganti tanpa mengubah UI. |
| `providers/` | State aplikasi: data course (loading, error, data) dan favorites, dengan `notifyListeners()`. Tidak menyimpan `BuildContext`. |
| `screens/` | Halaman penuh: shell navigasi, Home, Courses, Favorites, detail, Profile, dan halaman debugging. |
| `widgets/` | Komponen yang dipakai ulang: `CourseCard`, `CourseStateGate`, `SummaryCard`, `FeedbackForm`. |
| `constants/` | Identitas mahasiswa yang dipakai di UI dan kode. |
| `utils/` | Helper murni tanpa state, misalnya ikon, warna, dan label status course. |
| `experiments/` | Demo per tahap (setState, lifting state up, ValueNotifier, ChangeNotifier, model, service, repository, async state). Berdiri sendiri, punya `main()` sendiri, dan tidak diimpor oleh aplikasi utama. |

## Local state dan shared state

- Local state (`setState`): tab aktif di `ResponsiveShell`, `isLoading` di
  `FeedbackForm`, `showDetail` di halaman detail.
- Shared state (`CourseProvider`): daftar course dan favorites.

## Menjalankan

```bash
flutter pub get
flutter run -d chrome
flutter test
```

Menjalankan salah satu demo:

```bash
flutter run -d chrome -t lib/experiments/async_state_experiment.dart
```
## Endpoint REST (Pertemuan 7)

Disusun oleh: Kadek Nova Krisna Putra (2415051117)

| | |
| --- | --- |
| Base URL | https://course-api-pearl.vercel.app |
| Endpoint | GET /courses |
| Status code | 200 OK |
| Resource | courses |

Contoh satu item response:

```json
{
  "id": 5,
  "code": "MOB05",
  "title": "REST API & Database",
  "credits": 3,
  "status": "done",
  "created_at": "2026-10-21T03:28:09.790592Z"
}
```

Field: `id` (int), `code` (String), `title` (String), `credits` (int),
`status` (String: planned, active, atau done), `created_at` (String, waktu
pembuatan format ISO 8601).

Endpoint lain: `GET /courses/{id}`, `POST /courses`, `PUT /courses/{id}`,
`PATCH /courses/{id}`, `DELETE /courses/{id}`.