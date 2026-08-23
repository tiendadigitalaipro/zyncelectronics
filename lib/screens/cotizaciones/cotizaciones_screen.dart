import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../../models/cotizacion.dart';
import '../../models/producto.dart';
import '../../state/cart_controller.dart';
import '../../state/cotizaciones_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class CotizacionesScreen extends StatelessWidget {
  const CotizacionesScreen({super.key});

  void _nuevaCotizacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<ProductosController>(),
        child: const _NuevaCotizacionSheet(),
      ),
    );
  }

  void _convertirAVenta(BuildContext context, Cotizacion q) {
    final cart = context.read<CartController>();
    if (cart.items.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vacía el carrito del POS antes de convertir una cotización'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    for (final item in q.items) {
      cart.items.add(item);
    }
    cart.setCliente(q.cliente);
    context.read<CotizacionesController>().marcarConvertida(q.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cotización #${q.numero} cargada al carrito — ve al Punto de Venta para cobrar'), backgroundColor: Colors.green.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cotizaciones = context.watch<CotizacionesController>().cotizaciones;
    final pendientes = cotizaciones.where((q) => q.status == EstadoCotizacion.pendiente).toList();
    final totalPendiente = pendientes.fold(0.0, (s, q) => s + q.total);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'cotizaciones_fab',
        onPressed: () => _nuevaCotizacion(context),
        tooltip: 'Nueva cotización',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pendientes', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${pendientes.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Monto pendiente', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('\$${totalPendiente.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: cotizaciones.isEmpty
                ? Center(child: Text('No hay cotizaciones todavía', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: cotizaciones.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final q = cotizaciones[i];
                      final convertida = q.status == EstadoCotizacion.convertida;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: convertida ? const Color(0x334CAF50) : AppColors.accent.withValues(alpha: 0.15),
                            child: Icon(convertida ? Icons.check : Icons.request_quote, color: convertida ? Colors.greenAccent : AppColors.accent, size: 20),
                          ),
                          title: Text('#${q.numero} — ${q.cliente}', style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${q.items.length} items · ${q.creadaEn.day}/${q.creadaEn.month}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${q.total.toStringAsFixed(2)}', style: TextStyle(color: convertida ? Colors.white38 : AppColors.accent, fontWeight: FontWeight.bold)),
                              if (!convertida)
                                TextButton(
                                  onPressed: () => _convertirAVenta(context, q),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 24)),
                                  child: const Text('Convertir a venta', style: TextStyle(fontSize: 11)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NuevaCotizacionSheet extends StatefulWidget {
  const _NuevaCotizacionSheet();

  @override
  State<_NuevaCotizacionSheet> createState() => _NuevaCotizacionSheetState();
}

class _NuevaCotizacionSheetState extends State<_NuevaCotizacionSheet> {
  final _clienteCtrl = TextEditingController(text: 'CLIENTE GENÉRICO');
  final List<CartItem> _items = [];

  @override
  void dispose() {
    _clienteCtrl.dispose();
    super.dispose();
  }

  void _agregarProducto(Producto p) {
    setState(() {
      final i = _items.indexWhere((it) => it.id == p.id);
      if (i >= 0) {
        _items[i] = _items[i].copyWith(qty: _items[i].qty + 1);
      } else {
        _items.add(CartItem(id: p.id, sku: p.sku, desc: p.desc, price: p.price, iva: p.iva));
      }
    });
  }

  double get _total => _items.fold(0, (s, i) => s + i.total);

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductosController>().productos;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nueva cotización', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _clienteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Cliente'),
              ),
              const SizedBox(height: 12),
              const Text('Toca un producto para agregarlo', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productos.length,
                  itemBuilder: (context, i) {
                    final p = productos[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _agregarProducto(p),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: _items.isEmpty
                    ? Center(child: Text('Sin productos agregados', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          return ListTile(
                            dense: true,
                            title: Text(item.desc, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            subtitle: Text('x${item.qty}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            trailing: Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent)),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.white70)),
                  Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _items.isEmpty
                    ? null
                    : () async {
                        await context.read<CotizacionesController>().crear(
                              cliente: _clienteCtrl.text.trim().isEmpty ? 'CLIENTE GENÉRICO' : _clienteCtrl.text.trim(),
                              items: _items,
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Guardar cotización', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
