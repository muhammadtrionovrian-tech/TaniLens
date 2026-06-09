import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  
  List<AnalysisResult> _historyList = [];
  List<AnalysisResult> _filteredList = [];
  bool _isLoading = true;
  bool _isEditing = false;
  
  String _selectedCategory = 'Semua';
  
  // List of categories matching the filter chips
  final List<String> _categories = [
    'Semua',
    'Healthy Leaf',
    'Healthy Fruit',
    'Target Spot Fruit',
    'Late Blight Leaf'
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Load history from SharedPreferences
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _historyService.getHistory();
    setState(() {
      _historyList = history;
      _isLoading = false;
      _applyFilter();
    });
  }

  // Apply chip category filter
  void _applyFilter() {
    if (_selectedCategory == 'Semua') {
      _filteredList = List.from(_historyList);
    } else {
      _filteredList = _historyList
          .where((item) => item.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase())
          .toList();
    }
  }

  // Select category chip and re-filter
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilter();
    });
  }

  // Delete history item
  Future<void> _deleteItem(String id) async {
    await _historyService.deleteResult(id);
    final updatedList = await _historyService.getHistory();
    setState(() {
      _historyList = updatedList;
      _applyFilter();
    });
  }

  // Delete all history
  Future<void> _deleteAllHistory() async {
    await _historyService.clearHistory();
    setState(() {
      _historyList = [];
      _filteredList = [];
      _isEditing = false;
    });
  }

  // Show customized warning confirm dialog for deleting single item
  void _showDeleteConfirmDialog(BuildContext context, AnalysisResult item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning triangle icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD2D2), width: 1),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD32F2F),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Confirm Title
                const Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Confirm Message
                const Text(
                  'Apakah anda yakin ingin menghapus riwayat analisis?\nAksi ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Action Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Delete button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteItem(item.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show customized warning confirm dialog for deleting all items
  void _showDeleteAllConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning sweep icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD2D2), width: 1),
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Color(0xFFD32F2F),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Confirm Title
                const Text(
                  'Hapus Semua Riwayat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Confirm Message
                const Text(
                  'Apakah anda yakin ingin menghapus SELURUH riwayat analisis?\nAksi ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Action Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Delete button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteAllHistory();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Hapus Semua',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Format Date to "21 April 2026"
  String _formatIndonesianDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header + Edit Toggle button "Kelola Riwayat"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Riwayat Analisis',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hapus Semua button
                    if (_isEditing && _historyList.isNotEmpty) ...[
                      InkWell(
                        onTap: () => _showDeleteAllConfirmDialog(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_sweep,
                                size: 14,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Bersihkan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Kelola Riwayat button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isEditing ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accentDark,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isEditing ? Icons.check : Icons.mode_edit_outline_outlined,
                              size: 14,
                              color: _isEditing ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isEditing ? 'Selesai' : 'Kelola',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isEditing ? Colors.white : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categories horizontal filter chips scroll area
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                          ],
                          Text(cat),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => _onCategorySelected(cat),
                      selectedColor: AppColors.textDark, // Charcoal black selected
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : AppColors.accentDark,
                        ),
                      ),
                      elevation: 0,
                      pressElevation: 0,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // History list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                size: 50,
                                color: AppColors.textMuted.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada riwayat analisis',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: AppColors.primary,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              final item = _filteredList[index];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.accentDark.withValues(alpha: 0.7),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.01),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 55,
                                      height: 55,
                                      child: item.imageUrl.startsWith('assets/')
                                          ? Image.asset(
                                              item.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppColors.accent,
                                                child: const Icon(Icons.image, color: AppColors.primary),
                                              ),
                                            )
                                          : item.isLocalFile
                                              ? Image.file(
                                                  File(item.imageUrl),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: AppColors.accent,
                                                    child: const Icon(Icons.image, color: AppColors.primary),
                                                  ),
                                                )
                                              : Image.network(
                                                  item.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: AppColors.accent,
                                                    child: const Icon(Icons.broken_image, color: AppColors.primary),
                                                  ),
                                                ),
                                    ),
                                  ),
                                  title: Text(
                                    item.diseaseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          children: [
                                            const TextSpan(text: 'Akurasi: '),
                                            TextSpan(
                                              text: '${item.confidence}%',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatIndonesianDate(item.date),
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  trailing: _isEditing
                                      ? InkWell(
                                          onTap: () => _showDeleteConfirmDialog(context, item),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0F0),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFFFFD2D2), width: 0.8),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Color(0xFFD32F2F),
                                              size: 18,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                          color: AppColors.primaryLight,
                                        ),
                                  onTap: _isEditing
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailScreen(result: item),
                                            ),
                                          );
                                        },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
