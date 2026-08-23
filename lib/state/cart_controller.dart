import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/cart_item.dart';
import '../models/fiado.dart';
import '../models/producto.dart';
import '../models/venta.dart';

/// Estado del carrito y checkout — equivalente a `cart` + posCheckout() de
/// zync-electronics-app/index.html.
class CartController extends ChangeNotifier {
  final List<CartItem> items = [];
  String clienteNombre = 'CLIENTE GENÉRICO';
  String? clienteId;
  int _ticketCounter = 1;
  final List<Venta> historialVentas = [];
  final List<Fiado> fiados = [];

  Future<void> cargar() async {
    await AppDatabase.init();
    _ticketCounter = AppDatabase.getInt('ticketCounter') ?? 1;
    final ventasJson = AppDatabase.getJson('sales') as List?;
    if (ventasJson != null) {
      historialVentas
        ..clear()
        ..addAll(ventasJson.map((v) => Venta.fromJson(v)));
    }
    final fiadosJson = AppDatabase.getJson('fiados') as List?;
    if (fiadosJson != null) {
      fiados
        ..clear()
        ..addAll(fiadosJson.map((f) => Fiado.fromJson(f)));
    }
    notifyListeners();
  }

  int get ticketNumero => _ticketCounter;

  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);
  double get ivaTotal => items.fold(0, (sum, i) => sum + i.ivaMonto);
  double get total => subtotal + ivaTotal;

  void agregarProducto(Producto p) {
    final existente = items.indexWhere((i) => i.id == p.id);
    if (existente >= 0) {
      items[existente] = items[existente].copyWith(qty: items[existente].qty + 1);
    } else {
      items.add(CartItem(id: p.id, sku: p.sku, desc: p.desc, price: p.price, iva: p.iva));
    }
    notifyListeners();
  }

  /// Agrega una línea de Pesaje: producto fraccionable vendido por gramos/ml
  /// en vez de por unidad. `gramos` es la cantidad exacta a descontar del
  /// stock del producto (que para fraccionables se guarda en gramos).
  void agregarPesaje({required Producto producto, required int gramos, required double precio}) {
    final unidad = gramos >= 1000 ? '${(gramos / 1000).toStringAsFixed(3)}kg' : '${gramos}g';
    items.add(CartItem(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      sku: producto.sku,
      desc: '${producto.desc} · $unidad',
      price: precio,
      iva: producto.iva,
      sourceProductId: producto.id,
      stockQty: gramos,
    ));
    notifyListeners();
  }

  void cambiarCantidad(int index, int delta) {
    final nuevaQty = items[index].qty + delta;
    if (nuevaQty <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(qty: nuevaQty);
    }
    notifyListeners();
  }

  void quitar(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void setCliente(String nombre, {String? id}) {
    clienteNombre = nombre.trim().isEmpty ? 'CLIENTE GENÉRICO' : nombre.trim();
    clienteId = id;
    notifyListeners();
  }

  void vaciar() {
    items.clear();
    clienteNombre = 'CLIENTE GENÉRICO';
    clienteId = null;
    notifyListeners();
  }

  /// Registra la venta: guarda el ticket, y si es a crédito crea el fiado.
  /// El descuento de stock lo hace la pantalla llamando a
  /// ProductosController.descontarStock() por cada item — igual que en
  /// BarberFlow, para mantener los controladores desacoplados.
  Future<Venta> confirmarVenta({
    required String metodo,
    required GrupoPago grupoPago,
    required double recibido,
  }) async {
    if (grupoPago == GrupoPago.credito && clienteNombre == 'CLIENTE GENÉRICO') {
      throw StateError('Para fiado/crédito debes colocar el nombre del cliente');
    }

    final venta = Venta(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      ticketNum: _ticketCounter,
      cliente: clienteNombre,
      clienteId: clienteId,
      items: List.of(items),
      subtotal: subtotal,
      iva: ivaTotal,
      total: total,
      metodo: metodo,
      grupoPago: grupoPago,
      recibido: grupoPago == GrupoPago.credito ? total : recibido,
      estadoPago: grupoPago == GrupoPago.credito ? EstadoPago.pendiente : EstadoPago.pagado,
      fecha: DateTime.now(),
    );

    historialVentas.add(venta);
    _ticketCounter++;
    await AppDatabase.setJson('sales', historialVentas.map((v) => v.toJson()).toList());
    await AppDatabase.setInt('ticketCounter', _ticketCounter);

    if (grupoPago == GrupoPago.credito) {
      final fiado = Fiado(
        id: 'sale_${venta.id}',
        saleId: venta.id,
        ticketNum: venta.ticketNum,
        nombre: venta.cliente,
        ci: venta.clienteId,
        monto: venta.total,
        desc: 'Venta a crédito ticket #${venta.ticketNum}',
        fecha: DateTime.now(),
      );
      fiados.add(fiado);
      await AppDatabase.setJson('fiados', fiados.map((f) => f.toJson()).toList());
    }

    vaciar();
    notifyListeners();
    return venta;
  }
}
