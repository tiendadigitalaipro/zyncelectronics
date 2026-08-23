import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fiado.dart';
import '../../state/fiados_controller.dart';
import '../../theme/app_theme.dart';

class FiadosScreen extends StatelessWidget {
  const FiadosScreen({super.key});

  void _abrirNuevoFiado(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final ciCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nuevo fiado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre del cliente *')),
              const SizedBox(height: 12),
              TextField(controller: ciCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Cédula / teléfono (opcional)')),
              const SizedBox(height: 12),
              TextField(controller: montoCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto \$ *')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Motivo / descripción')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final nombre = nombreCtrl.text.trim();
                  final monto = double.tryParse(montoCtrl.text) ?? 0;
                  if (nombre.isEmpty || monto <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Nombre y monto son obligatorios'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }
                  context.read<FiadosController>().agregar(
                        nombre: nombre,
                        ci: ciCtrl.text.trim().isEmpty ? null : ciCtrl.text.trim(),
                        monto: monto,
                        desc: descCtrl.text.trim().isEmpty ? 'Fiado manual' : descCtrl.text.trim(),
                      );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Registrar fiado', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abonar(BuildContext context, Fiado f) {
    final montoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Abonar a ${f.nombre}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo pendiente: \$${f.saldo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: montoCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Monto a abonar \$'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final monto = double.tryParse(montoCtrl.text) ?? 0;
              if (monto > 0) context.read<FiadosController>().abonar(f.id, monto);
              Navigator.pop(ctx);
            },
            child: const Text('Abonar', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FiadosController>();
    final pendientes = controller.pendientes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fiados_fab',
        onPressed: () => _abrirNuevoFiado(context),
        tooltip: 'Nuevo fiado',
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
                const Text('Total pendiente', style: TextStyle(color: Colors.white70)),
                Text('\$${controller.totalPendiente.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: pendientes.isEmpty
                ? Center(
                    child: Text('No hay fiados pendientes', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: pendientes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final f = pendientes[i];
                      return Card(
                        child: ListTile(
                          onTap: () => _abonar(context, f),
                          leading: const CircleAvatar(backgroundColor: Color(0x33FFA726), child: Icon(Icons.event_note, color: Colors.orangeAccent, size: 20)),
                          title: Text(f.nombre, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(f.desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${f.saldo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                              if (f.abonado > 0)
                                Text('abonado \$${f.abonado.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
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
