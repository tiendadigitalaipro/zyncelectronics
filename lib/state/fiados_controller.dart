import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/fiado.dart';

class FiadosController extends ChangeNotifier {
  final List<Fiado> fiados = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('fiados') as List?;
    fiados
      ..clear()
      ..addAll((json ?? []).map((f) => Fiado.fromJson(f)));
    notifyListeners();
  }

  Future<void> _guardar() async {
    await AppDatabase.setJson('fiados', fiados.map((f) => f.toJson()).toList());
  }

  List<Fiado> get pendientes => fiados.where((f) => !f.saldado).toList();

  double get totalPendiente => pendientes.fold(0, (sum, f) => sum + f.saldo);

  Future<void> agregar({
    required String nombre,
    String? ci,
    required double monto,
    required String desc,
  }) async {
    fiados.add(Fiado(
      id: 'f${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      ci: ci,
      monto: monto,
      desc: desc,
      fecha: DateTime.now(),
    ));
    await _guardar();
    notifyListeners();
  }

  Future<void> abonar(String id, double monto) async {
    final i = fiados.indexWhere((f) => f.id == id);
    if (i < 0) return;
    final nuevoAbonado = (fiados[i].abonado + monto).clamp(0, fiados[i].monto).toDouble();
    fiados[i] = fiados[i].copyWith(abonado: nuevoAbonado);
    await _guardar();
    notifyListeners();
  }

  Future<void> eliminar(String id) async {
    fiados.removeWhere((f) => f.id == id);
    await _guardar();
    notifyListeners();
  }
}
