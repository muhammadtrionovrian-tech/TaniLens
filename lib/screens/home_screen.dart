import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToScan;
  final VoidCallback onNavigateToHistory;

  const HomeScreen({
    super.key,
    required this.onNavigateToScan,
    required this.onNavigateToHistory,
  });

  @override
  Widget build(BuildContext context) {
    // Grab samples to display in the disease study gallery
    final samples = AnalysisResult.staticSamples;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome greeting
              const Text(
                'Halo, Selamat Datang!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Deteksi Penyakit Tanaman Tomat Secara Cepat Menggunakan AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // Tomato disease study library slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Katalog Tanaman Tomat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showFullKatalogDialog(context, samples),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Horizontal list of tomato diseases for study
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: samples.length,
                  itemBuilder: (context, index) {
                    final item = samples[index];
                    return GestureDetector(
                      onTap: () => _showDiseaseDetailDialog(context, item),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentDark,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Leaf Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: item.imageUrl.startsWith('assets/')
                                    ? Image.asset(
                                        item.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.accent,
                                          child: const Icon(Icons.image, color: AppColors.primary),
                                        ),
                                      )
                                    : Image.network(
                                        item.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.accent,
                                          child: const Icon(Icons.broken_image, color: AppColors.primary),
                                        ),
                                      ),
                              ),
                            ),
                            // Disease label
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.diseaseName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Pintasan Cepat (Quick shortcuts)
              const Text(
                'Pintasan Cepat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),

              // Shortcut 1: Deteksi Penyakit
              _buildShortcutCard(
                icon: Icons.camera_alt_outlined,
                title: 'Deteksi Penyakit',
                subtitle: 'Ambil atau unggah gambar daun tanaman tomat',
                onTap: onNavigateToScan,
              ),
              const SizedBox(height: 12),

              // Shortcut 2: Riwayat Analisis
              _buildShortcutCard(
                icon: Icons.history_toggle_off_outlined,
                title: 'Riwayat Analisis',
                subtitle: 'Lihat riwayat hasil analisis penyakit tomat anda',
                onTap: onNavigateToHistory,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentDark.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Styled rounded container for shortcut icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right Arrow
            const Icon(
              Icons.chevron_right,
              color: AppColors.primaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Educational popup to read details about the selected plant/disease card
  void _showDiseaseDetailDialog(BuildContext context, AnalysisResult item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.eco, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.diseaseName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textBlack),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          item.imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            width: double.infinity,
                            color: AppColors.accent,
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Image.network(
                          item.imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            width: double.infinity,
                            color: AppColors.accent,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi Penyakit:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rekomendasi Tindakan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                ...item.recommendations.map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Show a comprehensive dialog displaying all preloaded katalog cards
  void _showFullKatalogDialog(BuildContext context, List<AnalysisResult> items) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Katalog Lengkap',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (listContext, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      color: AppColors.accent.withValues(alpha: 0.2),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.accent,
                                    child: const Icon(
                                      Icons.image,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : Image.network(
                                  item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.accent,
                                    child: const Icon(
                                      Icons.broken_image_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                        ),
                        title: Text(
                          item.diseaseName,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        subtitle: Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showDiseaseDetailDialog(context, item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
