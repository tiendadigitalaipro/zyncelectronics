import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_shell.dart';
import 'screens/licencia/licencia_screen.dart';
import 'services/analytics_service.dart';
import 'state/caja_controller.dart';
import 'state/cart_controller.dart';
import 'state/cotizaciones_controller.dart';
import 'state/devoluciones_controller.dart';
import 'state/fiados_controller.dart';
import 'state/formula_controller.dart';
import 'state/license_controller.dart';
import 'state/productos_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalyticsService.init();
  runApp(const ZyncElectronicsApp());
}

class ZyncElectronicsApp extends StatelessWidget {
  const ZyncElectronicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductosController()..cargar()),
        ChangeNotifierProvider(create: (_) => CartController()..cargar()),
        ChangeNotifierProvider(create: (_) => FiadosController()..cargar()),
        ChangeNotifierProvider(create: (_) => DevolucionesController()..cargar()),
        ChangeNotifierProvider(create: (_) => CotizacionesController()..cargar()),
        ChangeNotifierProvider(create: (_) => CajaController()..cargar()),
        ChangeNotifierProvider(create: (_) => FormulaController()..cargar()),
        ChangeNotifierProvider(create: (_) => LicenseController()..cargar()),
      ],
      child: MaterialApp(
        title: 'ZYNC Electronics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const LicenseGate(),
      ),
    );
  }
}

class LicenseGate extends StatelessWidget {
  const LicenseGate({super.key});

  @override
  Widget build(BuildContext context) {
    final licencia = context.watch<LicenseController>();

    switch (licencia.estado) {
      case EstadoLicencia.cargando:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
        );
      case EstadoLicencia.prueba:
      case EstadoLicencia.activa:
        return const HomeShell();
      case EstadoLicencia.bloqueada:
        return const LicenciaScreen();
    }
  }
}
