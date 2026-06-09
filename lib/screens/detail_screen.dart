import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../theme/app_colors.dart';
import 'video_player_screen.dart';

class DetailScreen extends StatelessWidget {
  final AnalysisResult result;

  const DetailScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    const accentRed = Color(0xFFC62828); // Deep red for video button

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Penyakit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large high-res image with rounded borders
              Center(
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: result.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            result.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.accent,
                              child: const Icon(Icons.image, size: 50, color: AppColors.primary),
                            ),
                          )
                        : result.isLocalFile
                            ? Image.file(
                                File(result.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.accent,
                                  child: const Icon(Icons.image, size: 50, color: AppColors.primary),
                                ),
                              )
                            : Image.network(
                                result.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.accent,
                                  child: const Icon(Icons.broken_image, size: 50, color: AppColors.primary),
                                ),
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and Confidence score
              Center(
                child: Column(
                  children: [
                    Text(
                      result.diseaseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Skor Keyakinan : ${result.confidence}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (result.inferenceTime != null && result.modelName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Inferensi model AI: ${result.inferenceTime} ms (${result.modelName})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // "Penjelasan Video" interactive button card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(result: result),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: accentRed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentRed.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // White circular glowing play button
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: accentRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Penjelasan Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // "Deskripsi Penyakit" section
              const Text(
                'Deskripsi Penyakit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // "Rekomendasi Penanganan" section
              const Text(
                'Rekomendasi Penanganan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 10),
              
              // Bullet points for recommendations
              ...result.recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leaf icon bullet
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        child: const Icon(
                          Icons.eco,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Text
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
