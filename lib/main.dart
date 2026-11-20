
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:agenda_barber/login.dart';
import 'package:agenda_barber/servicios_page.dart';

void main() {
  runApp(const MiLogin());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>
    with SingleTickerProviderStateMixin {

  final TextEditingController controlador = TextEditingController();

  late final AnimationController animacion;

  String texto = '¡Ya paseme inge!';

  bool alertaCupertino = false;

  // MENU INFERIOR
  int paginaSeleccionada = 0;

  // CRONOMETRO
  int segundos = 0;

  Timer? temporizador;

  final Stopwatch cronometro = Stopwatch();

  @override
  void initState() {
    super.initState();

    // ANIMACION DE LA PILDORA
    animacion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // INICIAR CRONOMETRO
    cronometro.start();

    temporizador = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {

        if (mounted) {
          setState(() {
            segundos = cronometro.elapsed.inSeconds;
          });
        }

      },
    );
  }

  // FORMATO DEL CRONOMETRO
  String obtenerTiempo() {

    int minutos = segundos ~/ 60;
    int segundosRestantes = segundos % 60;

    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundosRestantes.toString().padLeft(2, '0')}';
  }

  // MOSTRAR ALERTAS
  void mostrarAlerta() {

    final String mensaje = controlador.text.trim().isEmpty
        ? '¡Estoy cansado!'
        : controlador.text.trim();

    setState(() {
      texto = '¡$mensaje!';
    });

    if (alertaCupertino) {

      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (contextAlerta) {

          return CupertinoAlertDialog(
            title: const Text('Lo de hoy'),

            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(mensaje),
            ),

            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(contextAlerta).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

    } else {

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (contextAlerta) {

          return AlertDialog(
            title: const Text('Lo de hoy'),
            content: Text(mensaje),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(contextAlerta).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  // PANTALLA DE INICIO
  Widget pantallaInicio() {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Text(
            '¡Ya lo hice a mano profe Jhony!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // PILDORA GIRATORIA CON CRONOMETRO
          Stack(
            alignment: Alignment.center,
            children: [

              RotationTransition(
                turns: animacion,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),

                  child: Image.network(
                    'https://plus.unsplash.com/premium_photo-1664299631876-f143dc691c4d?q=80&w=397&auto=format&fit=crop',

                    width: 270,
                    height: 115,

                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.red,
                      );
                    },
                  ),
                ),
              ),

              // CONTADOR EN EL CENTRO
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),

                  borderRadius: BorderRadius.circular(50),

                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),

                child: Text(
                  obtenerTiempo(),

                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // TEXTO DINAMICO
          Text(
            texto,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 243, 33, 156),
            ),
          ),

          const SizedBox(height: 25),

          // CAMPO DE TEXTO
          TextField(
            controller: controlador,

            decoration: const InputDecoration(
              labelText: 'Escribe algo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),

          const SizedBox(height: 15),

          // BOTON DE ALERTA
          ElevatedButton(
            onPressed: mostrarAlerta,
            child: const Text('Pícale'),
          ),

          const SizedBox(height: 15),

          // SEGUNDA PAGINA
          ElevatedButton(
            onPressed: () {

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const SegundaPagina(),
                ),
              );

            },

            child: const Text('SI'),
          ),

          const SizedBox(height: 25),

          // SWITCH DE ALERTAS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                'Normal',
                style: TextStyle(fontSize: 16),
              ),

              CupertinoSwitch(
                value: alertaCupertino,

                onChanged: (valor) {
                  setState(() {
                    alertaCupertino = valor;
                  });
                },
              ),

              const Text(
                'Cupertino',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 72, 255, 0),

      // BARRA SUPERIOR
      appBar: AppBar(

        title: Text(
          paginaSeleccionada == 0
              ? 'BARBER SHOP'
              : 'Servicios Barber Shop',
        ),

        backgroundColor: const Color.fromARGB(255, 243, 240, 33),

        foregroundColor: const Color.fromARGB(255, 105, 54, 244),
      ),

      // CONTENIDO DE LAS PESTAÑAS
      body: paginaSeleccionada == 0
          ? pantallaInicio()
          : const ServiciosPage(),

      // MENU INFERIOR
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: paginaSeleccionada,

        onTap: (indice) {

          setState(() {
            paginaSeleccionada = indice;
          });

        },

        backgroundColor: const Color(0xFF111111),

        selectedItemColor: const Color(0xFFD4AF37),

        unselectedItemColor: Colors.white54,

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut),
            label: 'Servicios',
          ),

        ],
      ),
    );
  }

  // LIBERAR RECURSOS
  @override
  void dispose() {

    temporizador?.cancel();

    cronometro.stop();

    controlador.dispose();

    animacion.dispose();

    super.dispose();
  }
}

// SEGUNDA PAGINA

class SegundaPagina extends StatelessWidget {

  const SegundaPagina({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.blue.shade100,

      appBar: AppBar(
        title: const Text('La otra'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.phone_android,
              size: 100,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              '¡La otra pagina prof jhony!',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
