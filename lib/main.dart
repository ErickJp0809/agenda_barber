import 'package:flutter/material.dart';
import 'package:agenda_barber/login.dart';
import 'package:agenda_barber/store.dart';
import 'package:agenda_barber/tema.dart';
import 'package:agenda_barber/inicio_page.dart';
import 'package:agenda_barber/agenda_page.dart';
import 'package:agenda_barber/clientes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.cargar(); // carga (o crea) los datos locales
  runApp(const MiLogin());
}

/// Pantalla principal con la barra inferior: Inicio · Agenda · Clientes.
/// (Se mantiene el nombre MainApp porque login.dart navega hacia él.)
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int pagina = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pagina,
        children: [
          InicioPage(irA: (i) => setState(() => pagina = i)),
          const AgendaPage(),
          const ClientesPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: C.bg,
          border: Border(top: BorderSide(color: C.borde)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              _item(0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
              _item(1, Icons.calendar_month_outlined, Icons.calendar_month, 'Agenda'),
              _item(2, Icons.people_outline, Icons.people, 'Clientes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icono, IconData activo, String texto) {
    final sel = pagina == i;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => pagina = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(sel ? activo : icono, color: sel ? C.oro : C.gris, size: 28),
              const SizedBox(height: 4),
              Text(texto,
                  style: TextStyle(
                      color: sel ? C.oro : C.gris,
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
