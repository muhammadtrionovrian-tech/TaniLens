class AnalysisResult {
  final String id;
  final String diseaseName;
  final double confidence;
  final String imageUrl;
  final bool isLocalFile;
  final DateTime date;
  final String description;
  final List<String> recommendations;
  final String category; // 'Healthy Leaf', 'Healthy Fruit', 'Target Spot Fruit', 'Late Blight Leaf'
  final String videoUrl; // Treatment video YouTube URL
  final int? inferenceTime; // in milliseconds
  final String? modelName; // MobileNetV2, ResNet50, etc.

  AnalysisResult({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.imageUrl,
    required this.isLocalFile,
    required this.date,
    required this.description,
    required this.recommendations,
    required this.category,
    required this.videoUrl,
    this.inferenceTime,
    this.modelName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'isLocalFile': isLocalFile,
        'date': date.toIso8601String(),
        'description': description,
        'recommendations': recommendations,
        'category': category,
        'videoUrl': videoUrl,
        'inferenceTime': inferenceTime,
        'modelName': modelName,
      };

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        id: json['id'] as String,
        diseaseName: json['diseaseName'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        isLocalFile: json['isLocalFile'] as bool? ?? false,
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
        recommendations: List<String>.from(json['recommendations'] as List),
        category: json['category'] as String,
        videoUrl: json['videoUrl'] as String? ?? 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        inferenceTime: json['inferenceTime'] as int?,
        modelName: json['modelName'] as String?,
      );

  // Factory constructor to dynamically populate an AnalysisResult from TFLite prediction scores
  factory AnalysisResult.fromClassification(
    String className,
    double confidence, {
    String? imagePath,
    bool isLocal = true,
    int? inferenceTime,
    String? modelName,
  }) {
    // Find matching template profile (case-insensitive)
    final template = staticSamples.firstWhere(
      (element) => element.diseaseName.replaceAll(' ', '').toLowerCase() == className.replaceAll(' ', '').replaceAll('_', '').toLowerCase(),
      orElse: () => staticSamples.firstWhere((e) => e.diseaseName == 'Healthy Leaf'),
    );

    return AnalysisResult(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      diseaseName: template.diseaseName,
      confidence: confidence,
      imageUrl: imagePath ?? template.imageUrl,
      isLocalFile: isLocal,
      date: DateTime.now(),
      category: template.category,
      description: template.description,
      recommendations: template.recommendations,
      videoUrl: template.videoUrl,
      inferenceTime: inferenceTime,
      modelName: modelName,
    );
  }

  // The 9 comprehensive plant pathology classes supported by the MobileNetV2 TFLite model
  static List<AnalysisResult> get staticSamples => [
        AnalysisResult(
          id: 'sample_healthy_leaf',
          diseaseName: 'Healthy Leaf',
          confidence: 99.4,
          imageUrl: 'assets/placeholders/Healthy_Leaf.webp',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Healthy Leaf',
          description: 'Daun tomat berada dalam kondisi sangat sehat dan prima. Sel-sel klorofil berfungsi optimal untuk proses fotosintesis, dan tidak ada tanda-tanda serangan hama, kutu daun, jamur, maupun infeksi bakteri/virus lainnya.',
          recommendations: [
            'Pertahankan jadwal penyiraman yang teratur dan konsisten (pagi hari adalah waktu terbaik).',
            'Berikan pupuk organik dan pupuk NPK secara berimbang untuk mendukung pertumbuhan vegetatif.',
            'Lakukan inspeksi mingguan untuk mendeteksi tanda-tanda hama/penyakit sedini mungkin.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_healthy_fruits',
          diseaseName: 'Healthy Fruit',
          confidence: 98.9,
          imageUrl: 'assets/placeholders/Healthy_Fruits.jpg',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Healthy Fruit',
          description: 'Buah tomat dalam kondisi matang sempurna dan sangat sehat. Kulit luar mulus, berwarna merah merata berkat sintesis likopen yang maksimal, serta tidak memiliki cacat fisik maupun gejala penyakit busuk buah.',
          recommendations: [
            'Berikan pupuk kalsium tambahan untuk mencegah blossom-end rot (busuk pantat buah) selama pembentukan buah berikutnya.',
            'Jaga stabilitas kelembapan tanah agar buah tidak pecah akibat lonjakan volume air.',
            'Panen buah dengan hati-hati menggunakan gunting stek untuk menghindari luka pada tangkai tanaman.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_healthy_stem',
          diseaseName: 'Healthy Stem',
          confidence: 97.5,
          imageUrl: 'assets/placeholders/Healthy_Stem.jpg',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Healthy Stem',
          description: 'Batang tanaman tomat dalam kondisi sangat kokoh, tegak, dan sehat. Pembuluh vaskular berfungsi optimal menyalurkan nutrisi dan air dari akar ke daun/buah tanpa ada sumbatan jamur maupun luka fisik.',
          recommendations: [
            'Pasang ajir atau lanjaran kayu yang kokoh untuk menopang beban buah dan menjaga tanaman tetap tegak.',
            'Lakukan perempelan tunas air (suckers) secara berkala agar sirkulasi udara di sekitar batang tetap terjaga.',
            'Jaga pangkal batang agar tidak tergenang air yang berpotensi memicu pembusukan leher batang.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_early_blight_leaf',
          diseaseName: 'Early Blight Leaf',
          confidence: 91.2,
          imageUrl: 'assets/placeholders/Early_Blight_Leaf.jpg',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 4)),
          category: 'Early Blight Leaf',
          description: 'Penyakit bercak kering (Early Blight) disebabkan oleh jamur Alternaria solani. Menyerang daun tua terlebih dahulu dengan munculnya bercak cokelat lingkaran konsentris menyerupai cincin tahunan pohon. Dapat menyebar ke buah dan batang.',
          recommendations: [
            'Pangkas daun bagian bawah yang dekat dengan tanah untuk mencegah spora jamur memantul dari tanah ke daun.',
            'Lakukan pergiliran tanaman (rotasi tanaman) non-solanaceae selama minimal 2-3 tahun.',
            'Semprotkan fungisida berbahan aktif mankozeb atau tembaga hidroksida secara berkala sesuai dosis.',
            'Siram tanaman di bagian tanah, hindari membasahi daun secara berlebihan.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_late_blight_leaf',
          diseaseName: 'Late Blight Leaf',
          confidence: 88.7,
          imageUrl: 'assets/placeholders/Late_Blight_Leaf.webp',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Late Blight Leaf',
          description: 'Penyakit Busuk Daun (Late Blight) disebabkan oleh oomycete Phytophthora infestans. Jamur ini sangat agresif dan dapat menghancurkan seluruh tanaman dalam hitungan hari. Gejala dimulai dengan bercak basah hijau kelabu gelap pada ujung daun yang kemudian menyebar cepat.',
          recommendations: [
            'Gunakan benih atau bibit varietas unggul yang terbukti tahan terhadap penyakit busuk daun.',
            'Atur jarak tanam agar sirkulasi udara lancar dan sinar matahari dapat menembus seluruh bagian kanopi.',
            'Aplikasikan fungisida sistemik berbahan aktif mankozeb atau metalaksil secara berkala terutama saat musim hujan.',
            'Segera cabut dan bakar tanaman yang menunjukkan gejala awal agar dipastikan infeksi tidak menular ke tanaman sehat.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_mold_leaf',
          diseaseName: 'Mold Leaf',
          confidence: 85.6,
          imageUrl: 'assets/placeholders/Mold_Leaf.jpg',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 6)),
          category: 'Mold Leaf',
          description: 'Penyakit kapang daun (Leaf Mold) disebabkan oleh jamur Passalora fulva. Gejala awalnya berupa bercak hijau pucat atau kekuningan di permukaan atas daun, sementara di permukaan bawah daun muncul lapisan beludru berwarna zaitun-abu-abu hingga ungu.',
          recommendations: [
            'Kurangi kelembapan rumah kaca atau area tanam dengan meningkatkan ventilasi udara.',
            'Hindari penyiraman dari atas daun (overhead irrigation); siram langsung ke pangkal tanah.',
            'Lakukan penjarangan daun bagian bawah yang sudah tua untuk memperbaiki sirkulasi.',
            'Aplikasikan fungisida berbahan aktif tembaga atau klorotalonil jika serangan meluas.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_septoria_leaf_spot',
          diseaseName: 'Septoria Leaf Spot',
          confidence: 89.4,
          imageUrl: 'assets/placeholders/Septoria_Leaf_Spot.jpg',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 7)),
          category: 'Septoria Leaf Spot',
          description: 'Penyakit bercak daun Septoria disebabkan oleh jamur Septoria lycopersici. Gejala berupa bercak-bercak melingkar kecil berwarna kelabu dengan pinggiran cokelat gelap di daun bagian bawah, seringkali dengan titik-titik hitam kecil di tengahnya.',
          recommendations: [
            'Lakukan sanitasi kebun dengan membersihkan semua sisa tanaman yang sakit setelah panen.',
            'Hindari bekerja di kebun saat daun tanaman tomat dalam kondisi basah untuk mencegah penyebaran spora.',
            'Gunakan mulsa tanah untuk menghalangi spora jamur memantul dari tanah akibat tetesan air penyiraman.',
            'Semprotkan fungisida protektif secara berkala sesuai dosis petunjuk.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_target_spot_fruit',
          diseaseName: 'Target Spot Fruit',
          confidence: 95.2,
          imageUrl: 'assets/placeholders/Target_Spot_Fruit.webp',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 8)),
          category: 'Target Spot Fruit',
          description: 'Penyakit bercak sasaran (Target Spot) pada buah tomat disebabkan oleh infeksi jamur Corynespora cassiicola. Infeksi ini memicu munculnya bercak melingkar cekung menyerupai papan panahan (target). Penyakit berkembang pesat dalam kondisi suhu hangat dan kelembapan udara yang tinggi.',
          recommendations: [
            'Kurangi kelembapan di sekitar tajuk tanaman dengan melakukan pemangkasan teratur.',
            'Hindari pengairan overhead (penyiraman dari atas) yang membasahi buah dan daun. Gunakan sistem irigasi tetes.',
            'Semprotkan fungisida berbahan aktif tembaga hidroksida atau klorotalonil sesuai dosis anjuran.',
            'Bersihkan dan musnahkan sisa-sisa tanaman yang terinfeksi setelah masa panen selesai.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
        AnalysisResult(
          id: 'sample_symptomatic_stem',
          diseaseName: 'Symptomatic Stem',
          confidence: 84.1,
          imageUrl: 'assets/placeholders/Symptomatic_Stem.jpg',
          isLocalFile: false,
          date: DateTime.now().subtract(const Duration(days: 9)),
          category: 'Symptomatic Stem',
          description: 'Batang tanaman tomat menunjukkan gejala infeksi patogen (seperti layu bakteri, busuk batang basah, atau kanker batang). Gejala berupa bercak cokelat kehitaman memanjang, pembengkakan, atau keluarnya lendir bakteri saat dipotong. Dapat menyebabkan tanaman layu mendadak.',
          recommendations: [
            'Hindari melakukan pemangkasan daun saat cuaca basah/hujan untuk meminimalkan luka terbuka penularan spora/bakteri.',
            'Lakukan sanitasi lahan dengan membersihkan tanaman liar di sekitar area penanaman.',
            'Semprotkan bakterisida berbahan aktif streptomisin sulfat atau fungisida tembaga pada batang bergejala awal.',
            'Jika infeksi layu bakteri sistemik telah parah, segera cabut tanaman beserta tanah sekitarnya agar tidak menular ke tanaman lain.'
          ],
          videoUrl: 'https://youtu.be/KLuTLF3x9sA?si=h6G-ainYZAZVlQcG',
        ),
      ];
}
