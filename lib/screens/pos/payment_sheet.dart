import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/venta.dart';
import '../../services/analytics_service.dart';
import '../../state/cart_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class _Metodo {
  final String nombre;
  final IconData icon;
  final GrupoPago grupo;
  const _Metodo(this.nombre, this.icon, this.grupo);
}

const _metodos = [
  _Metodo('Efectivo \$', Icons.attach_money, GrupoPago.efectivo),
  _Metodo('Pago Móvil', Icons.phone_android, GrupoPago.digital),
  _Metodo('Zelle', Icons.account_balance, GrupoPago.digital),
  _Metodo('Binance / USDT', Icons.currency_bitcoin, GrupoPago.digital),
  _Metodo('Transferencia', Icons.swap_horiz, GrupoPago.digital),
  _Metodo('Fiado / Crédito', Icons.event_note, GrupoPago.credito),
];

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({super.key});

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  _Metodo? _seleccionado;
  final _clienteCtrl = TextEditingController();
  final _recibidoCtrl = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _recibidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final metodo = _seleccionado;
    if (metodo == null) return;
    final cart = context.read<CartController>();
    final productos = context.read<ProductosController>();

    if (metodo.grupo == GrupoPago.credito) {
      cart.setCliente(_clienteCtrl.text);
    }

    setState(() => _procesando = true);
    try {
      final recibido = double.tryParse(_recibidoCtrl.text) ?? cart.total;
      final items = List.of(cart.items);
      final venta = await cart.confirmarVenta(
        metodo: metodo.nombre,
        grupoPago: metodo.grupo,
        recibido: recibido,
      );
      for (final item in items) {
        if (item.sourceProductId != null && item.stockQty != null) {
          await productos.descontarStock(item.sourceProductId!, item.stockQty!);
        } else {
          await productos.descontarStock(item.id, item.qty);
        }
      }
      AnalyticsService.track('venta_registrada', {
        'metodo_pago': metodo.nombre,
        'total_usd': venta.total,
        'cantidad_items': items.length,
        'ticket_num': venta.ticketNum,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Venta registrada — Ticket #${venta.ticketNum.toString().padLeft(4, '0')}'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final requiereCliente = _seleccionado?.grupo == GrupoPago.credito;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Método de pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Total: \$${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.6,
                ),
                itemCount: _metodos.length,
                itemBuilder: (context, i) {
                  final m = _metodos[i];
                  final activo = m == _seleccionado;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _seleccionado = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: activo ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: activo ? AppColors.accent : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(m.icon, color: activo ? AppColors.accent : Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m.nombre,
                              style: TextStyle(color: activo ? Colors.white : Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (requiereCliente) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _clienteCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Nombre del cliente (obligatorio para fiado)'),
                ),
              ],
              if (_seleccionado?.grupo == GrupoPago.efectivo) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _recibidoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Monto recibido (opcional)'),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_seleccionado == null || _procesando) ? null : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _procesando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('✅ Confirmar venta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
