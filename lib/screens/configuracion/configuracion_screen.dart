import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_database.dart';
import '../../state/license_controller.dart';
import '../../theme/app_theme.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _vendedorCtrl = TextEditingController();
  bool _cargado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargado) {
      _cargado = true;
      _cargarValores();
    }
  }

  Future<void> _cargarValores() async {
    await AppDatabase.init();
    final cfg = AppDatabase.getJson('config') as Map<String, dynamic>? ?? {};
    _nombreCtrl.text = cfg['name'] ?? 'ZYNC Electronics';
    _direccionCtrl.text = cfg['address'] ?? '';
    _telefonoCtrl.text = cfg['phone'] ?? '';
    _vendedorCtrl.text = cfg['vendedor'] ?? '';
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _vendedorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    await AppDatabase.setJson('config', {
      'name': _nombreCtrl.text.trim(),
      'address': _direccionCtrl.text.trim(),
      'phone': _telefonoCtrl.text.trim(),
      'vendedor': _vendedorCtrl.text.trim(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración guardada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final licencia = context.watch<LicenseController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  licencia.estado == EstadoLicencia.activa ? Icons.verified : Icons.timer_outlined,
                  color: licencia.estado == EstadoLicencia.activa ? Colors.greenAccent : AppColors.accent,
                ),
                title: Text(
                  licencia.estado == EstadoLicencia.activa ? 'Licencia activa' : 'Modo de prueba',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  licencia.estado == EstadoLicencia.activa ? (licencia.licenciaKey ?? '') : '${licencia.diasRestantesDemo ?? '—'} días restantes de la demo',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Datos del negocio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nombreCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _direccionCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _telefonoCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _vendedorCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Vendedor / responsable por defecto'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: _guardar,
                        child: const Text('Guardar cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Elaborado por A2K Digital Studio', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
