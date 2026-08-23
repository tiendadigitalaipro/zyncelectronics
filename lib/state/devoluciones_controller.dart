import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/devolucion.dart';

class DevolucionesController extends ChangeNotifier {
  final List<Devolucion> devoluciones = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('returns') as List?;
    devoluciones
      ..clear()
      ..addAll((json ?? []).map((d) => Devolucion.fromJson(d)));
    notifyListeners();
  }

  Future<void> registrar(Devolucion devolucion) async {
    devoluciones.insert(0, devolucion);
    await AppDatabase.setJson('returns', devoluciones.map((d) => d.toJson()).toList());
    notifyListeners();
  }
}
