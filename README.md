# Seleksi Magang PT. TATI Indonesia - Soal 3 dan 4

Proyek ini berisi solusi untuk soal 3 dan 4 dalam proses seleksi magang PT. TATI Indonesia. Kode ditulis menggunakan bahasa pemrograman PHP dan terdiri dari dua file utama: `helloworld.php` dan `predikat_kerja.php`.

## Daftar Isi
- [Soal 3: Hello World Logic](#soal-3-hello-world-logic)
- [Soal 4: Evaluasi Kinerja](#soal-4-evaluasi-kinerja)
- [Cara Menjalankan](#cara-menjalankan)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)

## Soal 3: Hello World Logic

### Deskripsi
Kelas `LogicTest` dengan method `helloworld($n)` yang menghasilkan string berdasarkan aturan berikut:
- Jika angka kelipatan 4, tambahkan "hello"
- Jika angka kelipatan 5, tambahkan "world"
- Jika kelipatan 4 dan 5 (20, dll.), gabungkan menjadi "helloworld"
- Jika tidak memenuhi kondisi di atas, gunakan angka itu sendiri
- Hasil akhir adalah string dengan elemen dipisahkan spasi.

### Cara Kerja
1. Inisialisasi array kosong untuk menyimpan hasil.
2. Loop dari 1 hingga n.
3. Untuk setiap i, cek kelipatan 4 dan 5, bangun string teks.
4. Jika teks kosong, gunakan i.
5. Tambahkan ke array.
6. Gabungkan array menjadi string dengan spasi.

### Test Case
```php
$tes = new LogicTest();
echo $tes->helloworld(6);
```

### Output
```
1 2 3 hello world 6
```

![Output Soal 3](output_soal3.png)  
*(Gambar output saat menjalankan kode. Jika tidak ada gambar, silakan jalankan kode di terminal.)*

## Soal 4: Evaluasi Kinerja

### Deskripsi
Kelas `PerformanceEvaluator` dengan method `predikat_kinerja($hasil_kerja, $perilaku)` yang menentukan predikat kinerja berdasarkan matriks logika:
- Input: string untuk hasil kerja dan perilaku (e.g., "diatas ekspektasi", "sesuai ekspektasi", "dibawah ekspektasi")
- Output: predikat seperti "Sangat Baik", "Baik", dll.

### Cara Kerja
1. Normalisasi input string menjadi indeks (0, 1, 2).
2. Gunakan matriks 3x3 untuk menentukan predikat berdasarkan kombinasi indeks.
3. Kembalikan predikat atau "Invalid Input" jika error.

### Test Case
```php
$evaluator = new PerformanceEvaluator();
$hasil1 = 'diatas ekspektasi';
$perilaku1 = 'diatas ekspektasi';
echo "Test : " . $evaluator->predikat_kinerja($hasil1, $perilaku1) . "\n";
```

### Output
```
Test : Sangat Baik
```

![Output Soal 4](output_soal4.png)  
*(Gambar output saat menjalankan kode. Jika tidak ada gambar, silakan jalankan kode di terminal.)*

## Cara Menjalankan
1. Pastikan PHP terinstall di sistem Anda.
2. Clone atau download repo ini.
3. Jalankan perintah di terminal:
   - Untuk Soal 3: `php helloworld.php`
   - Untuk Soal 4: `php predikat_kerja.php`

## Teknologi yang Digunakan
- **Bahasa Pemrograman**: PHP
- **Versi PHP**: Minimal 7.0 (untuk fitur seperti `str_contains`)
- **IDE/Editor**: VS Code atau editor PHP lainnya

---

*Dibuat oleh Khoerunnisa Utami dengan ❤*  
*Untuk seleksi magang PT. TATI Indonesia*