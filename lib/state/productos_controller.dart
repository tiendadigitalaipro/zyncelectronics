import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/producto.dart';
import '../services/analytics_service.dart';

class ProductosController extends ChangeNotifier {
  final List<Producto> productos = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    final json = AppDatabase.getJson('products') as List?;
    productos
      ..clear()
      ..addAll((json ?? []).map((p) => Producto.fromJson(p)));
    notifyListeners();
  }

  Future<void> _guardar() async {
    await AppDatabase.setJson(
      'products',
      productos.map((p) => p.toJson()).toList(),
    );
  }

  List<String> get categorias =>
      productos.map((p) => p.cat).where((c) => c.isNotEmpty).toSet().toList()..sort();

  Future<void> guardar(Producto producto) async {
    final i = productos.indexWhere((p) => p.id == producto.id);
    if (i >= 0) {
      productos[i] = producto;
    } else {
      productos.add(producto);
      AnalyticsService.track('producto_agregado', {'es_primer_producto': productos.length == 1});
    }
    await _guardar();
    notifyListeners();
  }

  Future<void> eliminar(String id) async {
    productos.removeWhere((p) => p.id == id);
    await _guardar();
    notifyListeners();
  }

  Future<void> descontarStock(String id, int cantidad) async {
    final i = productos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final nuevoStock = (productos[i].stock - cantidad).clamp(0, 1 << 30);
    productos[i] = productos[i].copyWith(stock: nuevoStock);
    await _guardar();
    notifyListeners();
  }

  Future<void> ajustarStock(String id, int nuevoStock) async {
    final i = productos.indexWhere((p) => p.id == id);
    if (i < 0) return;
    productos[i] = productos[i].copyWith(stock: nuevoStock.clamp(0, 1 << 30));
    await _guardar();
    notifyListeners();
  }
}
