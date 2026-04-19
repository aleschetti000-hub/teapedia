import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/tea.dart';

class TeasRepository {
  static List<Tea>? _cachedTeas;

  Future<List<Tea>> loadTeas() async {
    if (_cachedTeas != null) return _cachedTeas!;

    final jsonString =
        await rootBundle.loadString('assets/data/teas.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    _cachedTeas = jsonList.map((json) => Tea.fromJson(json)).toList();
    return _cachedTeas!;
  }

  Future<List<Tea>> loadTeasByCategory(String category) async {
    final teas = await loadTeas();
    return teas.where((tea) => tea.category == category).toList();
  }

  Future<Tea?> getTeaById(String id) async {
    final teas = await loadTeas();
    try {
      return teas.firstWhere((tea) => tea.id == id);
    } catch (e) {
      return null;
    }
  }
}
