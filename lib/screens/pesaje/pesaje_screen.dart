import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../state/cart_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class PesajeScreen extends StatefulWidget {
  const PesajeScreen({super.key});

  @override
  State<PesajeScreen> createState() => _PesajeScreenState();
}

class _PesajeScreenState extends State<PesajeScreen> {
  Producto? _seleccionado;
  int _gramos = 0;

  double get _precio => _seleccionado == null ? 0 : _seleccionado!.price * _gramos / 1000;

  void _agregar(int delta) => setState(() => _gramos = (_gramos + delta).clamp(0, 1 << 30));

  @override
  Widget build(BuildContext context) {
    final fraccionables = context.watch<ProductosController>().productos.where((p) => p.fraccionable).toList();

    if (fraccionables.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.scale, size: 56, color: Colors.white24),
              const SizedBox(height: 12),
              const Text('No hay productos marcados como fraccionables.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 4),
              const Text('Actívalo al editar un producto en Inventario.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final stockInsuficiente = _seleccionado != null && _gramos > _seleccionado!.stock;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Producto', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Producto>(
            initialValue: _seleccionado,
            dropdownColor: AppColors.surfaceLight,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Seleccionar producto'),
            items: [
              for (final p in fraccionables)
                DropdownMenuItem(value: p, child: Text('${p.desc} — \$${p.price.toStringAsFixed(2)}/kg')),
            ],
            onChanged: (p) => setState(() {
              _seleccionado = p;
              _gramos = 0;
            }),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text('$_gramos g', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                if (_seleccionado != null)
                  Text('Stock disponible: ${_seleccionado!.stock} g', style: TextStyle(color: stockInsuficiente ? Colors.redAccent : Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final g in [50, 100, 250, 500, 1000])
                OutlinedButton(
                  onPressed: _seleccionado == null ? null : () => _agregar(g),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent)),
                  child: Text('+${g}g'),
                ),
              OutlinedButton(
                onPressed: _seleccionado == null || _gramos == 0 ? null : () => setState(() => _gramos = 0),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                child: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Precio calculado', style: TextStyle(color: Colors.white70)),
                Text('\$${_precio.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_seleccionado == null || _gramos <= 0 || stockInsuficiente)
                ? null
                : () {
                    context.read<CartController>().agregarPesaje(producto: _seleccionado!, gramos: _gramos, precio: _precio);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Agregado al carrito: \$${_precio.toStringAsFixed(2)}'), backgroundColor: Colors.green.shade700),
                    );
                    setState(() => _gramos = 0);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              stockInsuficiente ? 'Stock insuficiente' : 'Agregar al carrito',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
