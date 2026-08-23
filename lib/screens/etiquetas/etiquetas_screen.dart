import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class EtiquetasScreen extends StatefulWidget {
  const EtiquetasScreen({super.key});

  @override
  State<EtiquetasScreen> createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  final Set<String> _seleccionados = {};

  void _copiarEtiquetas(BuildContext context) {
    final productos = context.read<ProductosController>().productos.where((p) => _seleccionados.contains(p.id));
    final texto = productos
        .map((p) => '${p.desc}\nSKU: ${p.sku}\n\$${p.price.toStringAsFixed(2)}\n${'-' * 24}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_seleccionados.length} etiquetas copiadas — pégalas en tu app de impresión'), backgroundColor: Colors.green.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductosController>().productos;

    if (productos.isEmpty) {
      return Center(
        child: Text('No hay productos en inventario todavía.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _seleccionados.isEmpty
          ? null
          : FloatingActionButton.extended(
              heroTag: 'etiquetas_fab',
              onPressed: () => _copiarEtiquetas(context),
              icon: const Icon(Icons.copy),
              label: Text('Copiar ${_seleccionados.length} etiqueta${_seleccionados.length == 1 ? '' : 's'}'),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text('${_seleccionados.length} seleccionados', style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    if (_seleccionados.length == productos.length) {
                      _seleccionados.clear();
                    } else {
                      _seleccionados
                        ..clear()
                        ..addAll(productos.map((p) => p.id));
                    }
                  }),
                  child: Text(_seleccionados.length == productos.length ? 'Deseleccionar todo' : 'Seleccionar todo'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              itemCount: productos.length,
              itemBuilder: (context, i) {
                final p = productos[i];
                final activo = _seleccionados.contains(p.id);
                return Card(
                  child: CheckboxListTile(
                    value: activo,
                    activeColor: AppColors.accent,
                    onChanged: (_) => setState(() {
                      if (activo) {
                        _seleccionados.remove(p.id);
                      } else {
                        _seleccionados.add(p.id);
                      }
                    }),
                    title: Text(p.desc, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${p.sku} · \$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
