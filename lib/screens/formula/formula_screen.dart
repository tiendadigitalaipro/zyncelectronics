import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/cart_controller.dart';
import '../../state/formula_controller.dart';
import '../../theme/app_theme.dart';

class FormulaScreen extends StatefulWidget {
  const FormulaScreen({super.key});

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}

class _FormulaScreenState extends State<FormulaScreen> {
  final _totalCtrl = TextEditingController();

  double get _total => double.tryParse(_totalCtrl.text.replaceAll(',', '.')) ?? 0;

  void _cargarVentasHoy() {
    final ventas = context.read<CartController>().historialVentas;
    final hoy = DateTime.now();
    final totalHoy = ventas
        .where((v) => v.fecha.year == hoy.year && v.fecha.month == hoy.month && v.fecha.day == hoy.day)
        .fold(0.0, (s, v) => s + v.total);
    setState(() => _totalCtrl.text = totalHoy.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historial = context.watch<FormulaController>().historial.reversed.take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribuye tus ingresos: 50% necesidades, 30% deseos, 20% ahorro.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _totalCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: const InputDecoration(labelText: 'Monto total a distribuir (\$)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _cargarVentasHoy,
            icon: const Icon(Icons.today, size: 16),
            label: const Text('Usar ventas de hoy'),
          ),
          const SizedBox(height: 16),
          _FranjaFormula('50% · Necesidades', _total * 0.5, Colors.lightBlueAccent),
          const SizedBox(height: 10),
          _FranjaFormula('30% · Deseos', _total * 0.3, AppColors.accent),
          const SizedBox(height: 10),
          _FranjaFormula('20% · Ahorro', _total * 0.2, Colors.greenAccent),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _total <= 0
                ? null
                : () {
                    context.read<FormulaController>().guardar(_total);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Análisis guardado')),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Guardar análisis', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (historial.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Historial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...historial.map((r) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.calculate, color: AppColors.accent),
                    title: Text('\$${r.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${r.fecha.day}/${r.fecha.month}/${r.fecha.year}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _FranjaFormula extends StatelessWidget {
  final String label;
  final double monto;
  final Color color;

  const _FranjaFormula(this.label, this.monto, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text('\$${monto.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
