import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class ProductoFormSheet extends StatefulWidget {
  final Producto? producto;

  const ProductoFormSheet({super.key, this.producto});

  @override
  State<ProductoFormSheet> createState() => _ProductoFormSheetState();
}

class _ProductoFormSheetState extends State<ProductoFormSheet> {
  late final _skuCtrl = TextEditingController(text: widget.producto?.sku ?? '');
  late final _catCtrl = TextEditingController(text: widget.producto?.cat ?? '');
  late final _descCtrl = TextEditingController(text: widget.producto?.desc ?? '');
  late final _costCtrl = TextEditingController(text: widget.producto?.cost.toString() ?? '0');
  late final _priceCtrl = TextEditingController(text: widget.producto?.price.toString() ?? '');
  late final _ivaCtrl = TextEditingController(text: widget.producto?.iva.toString() ?? '0');
  late final _stockCtrl = TextEditingController(text: widget.producto?.stock.toString() ?? '0');
  late final _minCtrl = TextEditingController(text: widget.producto?.min.toString() ?? '0');
  late final _bulkCostCtrl = TextEditingController(text: widget.producto?.bulkCost?.toString() ?? '');
  late final _bulkUnitsCtrl = TextEditingController(text: widget.producto?.bulkUnits?.toString() ?? '');
  late final _marginCtrl = TextEditingController(
    text: widget.producto != null && widget.producto!.cost > 0
        ? (((widget.producto!.price - widget.producto!.cost) / widget.producto!.cost) * 100).toStringAsFixed(0)
        : '',
  );
  late bool _fraccionable = widget.producto?.fraccionable ?? false;
  late String? _photo = widget.producto?.photo;

  @override
  void dispose() {
    _skuCtrl.dispose();
    _catCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    _priceCtrl.dispose();
    _ivaCtrl.dispose();
    _stockCtrl.dispose();
    _minCtrl.dispose();
    _bulkCostCtrl.dispose();
    _bulkUnitsCtrl.dispose();
    _marginCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    final archivo = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (archivo == null) return;
    final bytes = await File(archivo.path).readAsBytes();
    setState(() => _photo = base64Encode(bytes));
  }

  void _quitarFoto() => setState(() => _photo = null);

  /// Igual que mpCalcPrice() del original: si hay costo por bulto, deriva
  /// el costo unitario; si hay margen deseado, calcula el precio de venta.
  void _calcularPrecio() {
    final bulkCost = double.tryParse(_bulkCostCtrl.text) ?? 0;
    final bulkUnits = int.tryParse(_bulkUnitsCtrl.text) ?? 0;
    final margin = double.tryParse(_marginCtrl.text);

    double cost;
    if (bulkCost > 0 && bulkUnits > 1) {
      cost = bulkCost / bulkUnits;
      _costCtrl.text = cost.toStringAsFixed(4);
    } else {
      cost = double.tryParse(_costCtrl.text) ?? 0;
    }

    if (cost > 0 && margin != null && margin >= 0) {
      final price = cost * (1 + margin / 100);
      _priceCtrl.text = price.toStringAsFixed(2);
    }
    setState(() {});
  }

  double get _costoUnitario {
    final bulkCost = double.tryParse(_bulkCostCtrl.text) ?? 0;
    final bulkUnits = int.tryParse(_bulkUnitsCtrl.text) ?? 0;
    if (bulkCost > 0 && bulkUnits > 1) return bulkCost / bulkUnits;
    return double.tryParse(_costCtrl.text) ?? 0;
  }

  double get _gananciaPorUnidad => (double.tryParse(_priceCtrl.text) ?? 0) - _costoUnitario;

  void _guardar() {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción es obligatoria'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    final producto = Producto(
      id: widget.producto?.id ?? 'p${DateTime.now().millisecondsSinceEpoch}',
      sku: _skuCtrl.text.trim().toUpperCase().isEmpty ? 'S/C' : _skuCtrl.text.trim().toUpperCase(),
      cat: _catCtrl.text.trim(),
      desc: _descCtrl.text.trim(),
      bulkCost: double.tryParse(_bulkCostCtrl.text),
      bulkUnits: int.tryParse(_bulkUnitsCtrl.text),
      cost: double.tryParse(_costCtrl.text) ?? 0,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      iva: int.tryParse(_ivaCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      min: int.tryParse(_minCtrl.text) ?? 0,
      fraccionable: _fraccionable,
      photo: _photo,
    );
    context.read<ProductosController>().guardar(producto);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.producto != null;
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
              Text(
                editando ? 'Editar producto' : 'Nuevo producto',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Center(child: _FotoPicker(base64: _photo, onTap: _elegirFoto, onQuitar: _photo != null ? _quitarFoto : null)),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Descripción *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skuCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _catCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Costo', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Costo unitario'),
                      onChanged: (_) => _calcularPrecio(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _bulkCostCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Costo del bulto'),
                      onChanged: (_) => _calcularPrecio(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _bulkUnitsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Uds. del bulto'),
                      onChanged: (_) => _calcularPrecio(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _marginCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: '% ganancia deseado', hintText: 'ej: 30'),
                      onChanged: (_) => _calcularPrecio(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Precio venta *'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_costoUnitario > 0 && (double.tryParse(_priceCtrl.text) ?? 0) > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Ganancia: \$${_gananciaPorUnidad.toStringAsFixed(2)} por unidad'
                    '${_marginCtrl.text.isNotEmpty ? ' · Margen ${_marginCtrl.text}%' : ''}',
                    style: const TextStyle(color: AppColors.accent, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Stock mínimo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ivaCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'IVA %'),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fraccionable (se vende por peso/volumen)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                value: _fraccionable,
                activeThumbColor: AppColors.accent,
                onChanged: (v) => setState(() => _fraccionable = v),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(editando ? 'Guardar cambios' : 'Agregar producto', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FotoPicker extends StatelessWidget {
  final String? base64;
  final VoidCallback onTap;
  final VoidCallback? onQuitar;

  const _FotoPicker({required this.base64, required this.onTap, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: base64 != null ? AppColors.accent.withValues(alpha: 0.5) : Colors.white24),
            ),
            child: base64 != null
                ? Image.memory(base64Decode(base64!), fit: BoxFit.cover)
                : const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate, color: Colors.white38, size: 26),
                        SizedBox(height: 2),
                        Text('Foto', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
          ),
        ),
        if (onQuitar != null)
          TextButton(
            onPressed: onQuitar,
            style: TextButton.styleFrom(minimumSize: const Size(0, 30), padding: EdgeInsets.zero),
            child: const Text('Quitar', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
