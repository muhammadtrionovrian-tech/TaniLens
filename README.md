# Sistem Pendeteksi Penyakit Tanaman Tomat Berbasis Convolutional Neural Network Pada Android

Aplikasi pendeteksi penyakit tanaman tomat berbasis Android yang dirancang untuk berjalan sepenuhnya secara offline (*on-device inference*) menggunakan teknologi kecerdasan buatan (AI) berbasis visi komputer.

---

## 👨‍🎓 Identitas Mahasiswa
*   **Nama Mahasiswa:** Muhammad Trio Novrian
*   **Kampus:** Politeknik Negeri Sriwijaya
*   **Jurusan:** Teknik Komputer

---

## 📝 Deskripsi Singkat Project
**LeafScan Tomat** adalah aplikasi mobile berbasis Android yang dikembangkan untuk membantu petani, praktisi pertanian, maupun akademisi dalam mendeteksi dan mengklasifikasikan 9 jenis kondisi/penyakit pada daun dan buah tanaman tomat secara instan. 

Aplikasi ini menggunakan kamera ponsel atau unggahan foto dari galeri untuk mendeteksi tanda-tanda patologis pada tanaman. Proses inferensi dilakukan secara lokal di dalam perangkat tanpa membutuhkan koneksi internet, menjamin kecepatan deteksi serta privasi data pengguna.

---

## 🧠 Model yang Digunakan
Aplikasi ini mendukung arsitektur *dual-model* fleksibel untuk perbandingan kinerja model visi komputer secara offline:
*   **Pilihan Arsitektur Model (Bisa Diatur Lewat Konfigurasi Kompilasi):**
    1.  **MobileNetV2** (`Best_Trio_MobileNetV2_adam.tflite`) - Arsitektur ringan yang sangat efisien untuk perangkat mobile dengan ukuran model kecil.
    2.  **ResNet50** (`Best_Trio_ResNet50_adam.tflite`) - Arsitektur dengan koneksi sisa (*residual connection*) yang mendalam untuk akurasi tinggi.
*   **Jumlah Kelas Klasifikasi:** 9 Kelas patologis/kondisi tanaman tomat:
    1.  `Early Blight Leaf` (Daun Bercak Kering Awal)
    2.  `Healthy Fruit` (Buah Tomat Sehat)
    3.  `Healthy Leaf` (Daun Tomat Sehat)
    4.  `Healthy Stem` (Batang Tomat Sehat)
    5.  `Late Blight Leaf` (Daun Bercak Kering Akhir)
    6.  `Mold Leaf` (Daun Kapang / Leaf Mold)
    7.  `Septoria Leaf Spot` (Bercak Daun Septoria)
    8.  `Symptomatic Stem` (Batang Tomat Bergejala)
    9.  `Target Spot Fruit` (Buah dengan Bercak Sasaran)

---

## 📐 Metode Rescale yang Digunakan
Sebelum gambar dimasukkan ke model untuk dilakukan inferensi, gambar melalui tahapan pra-pemrosesan sebagai berikut:
1.  **Center Cropping**: Gambar dipotong secara simetris ke rasio aspek 1:1 (persegi) berdasarkan dimensi terpendek untuk menghindari distorsi/penyusutan gambar (squishing).
2.  **Resizing**: Gambar persegi diubah dimensinya menjadi ukuran target input model yaitu **$224 \times 224$ piksel**.
3.  **Model-Specific Scalers (Pra-pemrosesan Warna)**:
    *   **MobileNetV2**: Nilai piksel diurutkan dalam format **RGB** dan dinormalisasi secara sekuensial ke rentang **`[-1.0, 1.0]`** (sesuai standard `tf.keras.applications.mobilenet_v2.preprocess_input`) menggunakan rumus:
        $$f(\text{pixel}) = \frac{\text{pixel} - 127.5}{127.5}$$
    *   **ResNet50**: Nilai piksel diurutkan dalam format **BGR** (Blue, Green, Red) dengan menerapkan pengurangan rata-rata warna ImageNet (*ImageNet mean subtraction*) tanpa pembagian:
        *   Saluran Biru (Blue) = $\text{pixel.b} - 103.939$
        *   Saluran Hijau (Green) = $\text{pixel.g} - 116.779$
        *   Saluran Merah (Red) = $\text{pixel.r} - 123.680$

---

## 📚 Library yang Digunakan
Aplikasi ini dibangun menggunakan framework **Flutter** dengan pustaka-pustaka pendukung berikut:
*   `tflite_flutter` (v0.12.1): Pustaka utama sebagai interpreter model TensorFlow Lite di dalam aplikasi Flutter untuk mengeksekusi inferensi AI secara lokal di perangkat Android.
*   `image` (v4.8.0): Digunakan untuk melakukan operasi manipulasi citra digital seperti decoding byte, pemotongan simetris (crop), resizing, dan ekstraksi nilai warna piksel.
*   `image_picker` (v1.1.2): Pustaka untuk menjembatani akses kamera hardware perangkat Android atau membuka file picker galeri foto.
*   `shared_preferences` (v2.2.3): Digunakan untuk menyimpan riwayat hasil pemindaian penyakit tanaman tomat secara lokal dalam format Key-Value.
*   `youtube_player_iframe` (v6.0.2): Pustaka interaktif untuk memutar video edukasi mitigasi dan solusi penanganan penyakit tomat langsung di dalam aplikasi.

---

## 📁 Struktur Folder Project Flutter
Struktur direktori utama kode sumber aplikasi diatur secara modular untuk memisahkan UI dan Logika Bisnis:
```text
trio_project/
├── assets/
│   ├── logo/                # Logo aplikasi (app_logo.png)
│   ├── placeholders/        # Contoh citra penyakit untuk demonstrasi aplikasi
│   └── tflite/              # File model TFLite (MobileNetV2 & ResNet50)
├── lib/
│   ├── models/              # Model data (misal: AnalysisResult)
│   ├── screens/             # UI Halaman Utama (Home, Scan, History, About, VideoPlayer)
│   ├── services/            # Logika Backend (TFLite Service & Local History DB)
│   │   ├── history_service.dart
│   │   └── tflite_service.dart
│   ├── theme/               # Pengaturan warna hijau botani dan typography
│   ├── widgets/             # Komponen UI modular yang dapat digunakan kembali
│   └── main.dart            # Entry point inisialisasi aplikasi Flutter
└── pubspec.yaml             # Manajemen dependensi dan aset project
```

---

## 🛠️ Catatan Penting: Optimasi Model & Solusi Kendala Flex Delegate

Aplikasi ini menggunakan model TensorFlow Lite yang dikonversi dari Keras (.keras). 

### Tantangan Flex Delegate (SELECT_TF_OPS)
Selama pengembangan, model Keras awalnya dilatih menggunakan **Mixed Precision (`mixed_float16`)** di Python untuk mempercepat pelatihan di GPU. Efek sampingnya, model hasil konversi mengandung operasi casting tipe data yang tidak didukung secara native oleh interpreter TFLite standar di Flutter (`tflite_flutter` / LiteRT), sehingga membutuhkan library native tambahan Flex Delegate (`SELECT_TF_OPS`) yang membuat ukuran APK membengkak (+30MB) dan rentan terjadi crash/gagal memuat model di beberapa arsitektur perangkat.

### Solusi yang Diterapkan (Pure Float32 Conversion via Weight Transfer)
Untuk mengatasi masalah ini secara permanen tanpa mengorbankan akurasi dan ukuran aplikasi, kami menerapkan langkah-langkah optimasi berikut pada file model:
1. **Mematikan Mixed Precision secara Global:** Sebelum mengekspor model di Python, kami menyetel kebijakan mixed precision kembali ke standar:
   ```python
   tf.keras.mixed_precision.set_global_policy('float32')
   ```
2. **Rekonstruksi & Duplikasi Bobot (*Weight Transfer*):** Kami membangun arsitektur model kosong baru bertipe `float32` murni, lalu memindahkan seluruh parameter bobot terlatih dari model `mixed_float16` lama ke model baru menggunakan metode `set_weights()`.
3. **Ekspor Standard TFLite:** Model hasil transfer dideklarasikan dalam presisi `float32` penuh dan diekspor menggunakan operator standar saja:
   ```python
   converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]
   ```

### Hasil Optimasi:
* Model TFLite (`Best_Trio_MobileNetV2_adam.tflite` dan `Best_Trio_v3_ResNet50_adam.tflite`) sekarang **100% menggunakan operator bawaan TFLite (built-in)**.
* Aplikasi Flutter dapat berjalan sepenuhnya secara native tanpa membutuhkan dependency tambahan Flex Delegate atau library `select-tf-ops` di Gradle, menjamin ukuran APK tetap ringan, kompatibilitas tinggi, serta performa inferensi yang sangat cepat.

---

## ⚙️ Penjelasan Singkat Kode dan Fungsi Aplikasi
1.  **`main.dart`**: Menginisialisasi rute navigasi, memuat tema aplikasi, dan meluncurkan widget utama aplikasi.
2.  **`tflite_service.dart`**:
    *   Membaca konstanta switch `activeModel` (bertipe `ModelType` dengan nilai: `mobileNetV2` atau `resNet50`) untuk memuat model `.tflite` yang sesuai dari aset.
    *   Melakukan pemrosesan spasial gambar (center crop dan resizing $224 \times 224$ piksel).
    *   Mengonversi piksel gambar ke tipe `Float32` dalam format `List` 4-dimensi `[1, 224, 224, 3]`.
    *   Menerapkan fungsi pra-pemrosesan saluran warna yang dinamis (normalisasi RGB `[-1.0, 1.0]` untuk MobileNetV2, dan BGR pengurangan rata-rata ImageNet untuk ResNet50).
    *   Menjalankan inferensi dan mengembalikan label penyakit tomat beserta persentase tingkat kepercayaan (*confidence score*).
3.  **`history_service.dart`**: Menyediakan fungsi simpan, muat, dan hapus riwayat hasil analisis dengan menyimpannya ke memori penyimpanan lokal menggunakan `SharedPreferences` dalam representasi objek ter-serialize JSON.
4.  **`about_screen.dart`**: Menampilkan informasi tentang aplikasi serta badge dinamis yang menampilkan tipe model AI yang sedang aktif pada build APK tersebut (`TfliteService().activeModelName`).
