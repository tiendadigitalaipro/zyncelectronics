import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/devolucion.dart';
import '../../models/venta.dart';
import '../../state/cart_controller.dart';
import '../../state/devoluciones_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class DevolucionesScreen extends StatelessWidget {
  const DevolucionesScreen({super.key});

  void _nuevaDevolucion(BuildContext context) {
    final ventas = context.read<CartController>().historialVentas.reversed.take(30).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _SeleccionarVentaSheet(ventas: ventas),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devoluciones = context.watch<DevolucionesController>().devoluciones;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'devoluciones_fab',
        onPressed: () => _nuevaDevolucion(context),
        tooltip: 'Nueva devolución',
        child: const Icon(Icons.add),
      ),
      body: devoluciones.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_return, size: 56, color: Colors.white24),
                    const SizedBox(height: 12),
                    const Text('Sin devoluciones registradas.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 4),
                    const Text('Toca + y elige el ticket de la venta a devolver.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: devoluciones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = devoluciones[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0x33FF5252), child: Icon(Icons.assignment_return, color: Colors.redAccent, size: 20)),
                    title: Text('${d.productoDesc} x${d.qty}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'Ticket #${d.ticketNum.toString().padLeft(4, '0')} · ${d.cliente} · ${d.motivo}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: Text('-\$${d.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}

class _SeleccionarVentaSheet extends StatelessWidget {
  final List<Venta> ventas;
  const _SeleccionarVentaSheet({required this.ventas});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Elige el ticket a devolver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: ventas.isEmpty
                  ? Center(child: Text('No hay ventas registradas todavía', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ventas.length,
                      itemBuilder: (context, i) {
                        final v = ventas[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('Ticket #${v.ticketNum.toString().padLeft(4, '0')} — \$${v.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                            subtitle: Text('${v.cliente} · ${v.fecha.day}/${v.fecha.month} · ${v.items.length} items', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            onTap: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.surface,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                builder: (ctx) => _DevolverItemSheet(venta: v),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevolverItemSheet extends StatefulWidget {
  final Venta venta;
  const _DevolverItemSheet({required this.venta});

  @override
  State<_DevolverItemSheet> createState() => _DevolverItemSheetState();
}

class _DevolverItemSheetState extends State<_DevolverItemSheet> {
  int _itemIndex = 0;
  int _qty = 1;
  final _motivoCtrl = TextEditingController();

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.venta.items[_itemIndex];
    final monto = item.price * _qty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Devolver de Ticket #${widget.venta.ticketNum.toString().padLeft(4, '0')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _itemIndex,
              dropdownColor: AppColors.surfaceLight,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Producto'),
              items: [
                for (var i = 0; i < widget.venta.items.length; i++)
                  DropdownMenuItem(value: i, child: Text('${widget.venta.items[i].desc} (x${widget.venta.items[i].qty})')),
              ],
              onChanged: (v) => setState(() {
                _itemIndex = v ?? 0;
                _qty = 1;
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Cantidad a devolver', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                ),
                Text('$_qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                  onPressed: _qty < item.qty ? () => setState(() => _qty++) : null,
                ),
              ],
            ),
            TextField(
              controller: _motivoCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Motivo de la devolución *'),
            ),
            const SizedBox(height: 12),
            Text('Monto a devolver: \$${monto.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_motivoCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El motivo es obligatorio'), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                context.read<DevolucionesController>().registrar(Devolucion(
                      id: 'return${DateTime.now().millisecondsSinceEpoch}',
                      saleId: widget.venta.id,
                      ticketNum: widget.venta.ticketNum,
                      cliente: widget.venta.cliente,
                      productoId: item.id,
                      productoDesc: item.desc,
                      qty: _qty,
                      total: monto,
                      motivo: _motivoCtrl.text.trim(),
                      fecha: DateTime.now(),
                    ));
                final productos = context.read<ProductosController>();
                final producto = productos.productos.where((p) => p.id == item.id).toList();
                if (producto.isNotEmpty) {
                  productos.ajustarStock(item.id, producto.first.stock + _qty);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Devolución registrada: -\$${monto.toStringAsFixed(2)}'), backgroundColor: Colors.green.shade700),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Registrar devolución', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
