import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/cart_item.dart';
import '../models/cotizacion.dart';

class CotizacionesController extends ChangeNotifier {
  final List<Cotizacion> cotizaciones = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('quotes') as List?;
    cotizaciones
      ..clear()
      ..addAll((json ?? []).map((q) => Cotizacion.fromJson(q)));
    notifyListeners();
  }

  Future<void> _guardar() async {
    await AppDatabase.setJson('quotes', cotizaciones.map((q) => q.toJson()).toList());
  }

  Future<Cotizacion> crear({required String cliente, required List<CartItem> items}) async {
    final total = items.fold(0.0, (s, i) => s + i.total);
    final cotizacion = Cotizacion(
      id: 'quote${DateTime.now().millisecondsSinceEpoch}',
      numero: (cotizaciones.length + 1).toString().padLeft(5, '0'),
      cliente: cliente,
      items: items,
      total: total,
      creadaEn: DateTime.now(),
    );
    cotizaciones.insert(0, cotizacion);
    await _guardar();
    notifyListeners();
    return cotizacion;
  }

  Future<void> marcarConvertida(String id) async {
    final i = cotizaciones.indexWhere((q) => q.id == id);
    if (i < 0) return;
    cotizaciones[i] = cotizaciones[i].copyWith(status: EstadoCotizacion.convertida);
    await _guardar();
    notifyListeners();
  }

  Future<void> eliminar(String id) async {
    cotizaciones.removeWhere((q) => q.id == id);
    await _guardar();
    notifyListeners();
  }
}
