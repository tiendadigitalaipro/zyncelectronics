import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/formula_record.dart';

class FormulaController extends ChangeNotifier {
  final List<FormulaRecord> historial = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('fmlHistory') as List?;
    historial
      ..clear()
      ..addAll((json ?? []).map((r) => FormulaRecord.fromJson(r)));
    notifyListeners();
  }

  Future<void> guardar(double total) async {
    historial.add(FormulaRecord(id: '${DateTime.now().millisecondsSinceEpoch}', total: total, fecha: DateTime.now()));
    await AppDatabase.setJson('fmlHistory', historial.map((r) => r.toJson()).toList());
    notifyListeners();
  }
}
