import 'package:flutter/material.dart';
import '../models/app_module.dart';
import '../theme/app_theme.dart';
import 'caja/caja_screen.dart';
import 'configuracion/configuracion_screen.dart';
import 'cotizaciones/cotizaciones_screen.dart';
import 'devoluciones/devoluciones_screen.dart';
import 'etiquetas/etiquetas_screen.dart';
import 'fiados/fiados_screen.dart';
import 'formula/formula_screen.dart';
import 'inventario/inventario_screen.dart';
import 'pesaje/pesaje_screen.dart';
import 'pos/pos_screen.dart';
import 'reportes/reportes_screen.dart';

final List<AppModule> appModules = [
  AppModule(
    id: 'pos',
    label: 'Punto de Venta',
    icon: Icons.point_of_sale,
    builder: (_) => const PosScreen(),
    hasOwnFab: true,
  ),
  AppModule(
    id: 'inventario',
    label: 'Inventario',
    icon: Icons.inventory_2,
    builder: (_) => const InventarioScreen(),
    hasOwnFab: true,
  ),
  AppModule(
    id: 'pesaje',
    label: 'Pesaje gr/L',
    icon: Icons.scale,
    builder: (_) => const PesajeScreen(),
  ),
  AppModule(
    id: 'fiados',
    label: 'Fiados',
    icon: Icons.event_note,
    builder: (_) => const FiadosScreen(),
    hasOwnFab: true,
  ),
  AppModule(
    id: 'devoluciones',
    label: 'Devoluciones',
    icon: Icons.assignment_return,
    builder: (_) => const DevolucionesScreen(),
    hasOwnFab: true,
  ),
  AppModule(
    id: 'cotizaciones',
    label: 'Cotizaciones',
    icon: Icons.request_quote,
    builder: (_) => const CotizacionesScreen(),
    hasOwnFab: true,
  ),
  AppModule(
    id: 'reportes',
    label: 'Reportes',
    icon: Icons.bar_chart,
    builder: (_) => const ReportesScreen(),
  ),
  AppModule(
    id: 'caja',
    label: 'Caja',
    icon: Icons.account_balance_wallet,
    builder: (_) => const CajaScreen(),
  ),
  AppModule(
    id: 'formula',
    label: 'Fórmula 50/30/20',
    icon: Icons.calculate,
    builder: (_) => const FormulaScreen(),
  ),
  AppModule(
    id: 'etiquetas',
    label: 'Etiquetas',
    icon: Icons.label,
    builder: (_) => const EtiquetasScreen(),
    hasOwnFab: true,
  ),
  AppModule(
    id: 'config',
    label: 'Configuración',
    icon: Icons.settings,
    builder: (_) => const ConfiguracionScreen(),
  ),
];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  void _selectModule(int index) => setState(() => _selectedIndex = index);

  void _selectModuleFromDrawer(int index) {
    _selectModule(index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final current = appModules[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.devices_other, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text('ZYNC'),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                current.label,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.surface),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.devices_other, color: AppColors.accent, size: 36),
                  SizedBox(height: 8),
                  Text('ZYNC Electronics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Elaborado por A2K Digital Studio', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            for (var i = 0; i < appModules.length; i++)
              ListTile(
                leading: Icon(appModules[i].icon, color: i == _selectedIndex ? AppColors.accent : Colors.white70),
                title: Text(
                  appModules[i].label,
                  style: TextStyle(
                    color: i == _selectedIndex ? AppColors.accent : Colors.white70,
                    fontWeight: i == _selectedIndex ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: i == _selectedIndex,
                selectedTileColor: AppColors.accent.withValues(alpha: 0.08),
                onTap: () => _selectModuleFromDrawer(i),
              ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(current.id), child: current.builder(context)),
      ),
      floatingActionButton: current.hasOwnFab
          ? null
          : FloatingActionButton(
              onPressed: () => _selectModule(0),
              tooltip: 'Nueva venta',
              child: const Icon(Icons.point_of_sale),
            ),
    );
  }
}
