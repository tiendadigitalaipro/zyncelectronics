import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';
import 'producto_form_sheet.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  void _abrirFormulario(BuildContext context, {Producto? producto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<ProductosController>(),
        child: ProductoFormSheet(producto: producto),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Producto p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar producto', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${p.desc}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<ProductosController>().eliminar(p.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductosController>().productos;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'inventario_fab',
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
      body: productos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2, size: 56, color: Colors.white24),
                    const SizedBox(height: 12),
                    const Text('Todavía no tienes productos en inventario.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 4),
                    const Text('Toca el botón + para agregar el primero.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: productos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = productos[i];
                return Card(
                  child: ListTile(
                    onTap: () => _abrirFormulario(context, producto: p),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                      child: const Icon(Icons.devices_other, color: AppColors.accent, size: 20),
                    ),
                    title: Text(p.desc, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '${p.sku} · Stock: ${p.stock}${p.cat.isNotEmpty ? ' · ${p.cat}' : ''}',
                      style: TextStyle(color: p.stockBajo ? Colors.orangeAccent : Colors.white54, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white38),
                          onPressed: () => _confirmarEliminar(context, p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
