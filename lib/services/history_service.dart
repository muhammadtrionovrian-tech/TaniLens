import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';

class HistoryService {
  static const String _historyKey = 'tani_lens_history_v1';
  static final HistoryService _instance = HistoryService._internal();

  factory HistoryService() {
    return _instance;
  }

  HistoryService._internal();

  // Load analysis history from SharedPreferences
  Future<List<AnalysisResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey);

    if (jsonString == null) {
      // First launch: Start with a clean empty list
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => AnalysisResult.fromJson(item)).toList();
    } catch (e) {
      // If parsing fails, fall back to an empty list
      return [];
    }
  }

  // Save a single analysis result to history
  Future<void> saveResult(AnalysisResult result) async {
    final list = await getHistory();
    // Prepend the new scan to the top of the history list
    list.insert(0, result);
    await saveHistoryList(list);
  }

  // Delete a result by its ID
  Future<void> deleteResult(String id) async {
    final list = await getHistory();
    list.removeWhere((item) => item.id == id);
    await saveHistoryList(list);
  }

  // Save the entire list of results
  Future<void> saveHistoryList(List<AnalysisResult> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
