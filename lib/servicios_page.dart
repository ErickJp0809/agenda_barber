
import 'package:flutter/material.dart';
import 'api_service.dart';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {

  final ApiService api = ApiService();

  List<dynamic> servicios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarServicios();
  }

  // READ - CONSULTAR SERVICIOS
  Future<void> cargarServicios() async {

    setState(() {
      cargando = true;
    });

    try {

      final datos = await api.obtenerServicios();

      if (!mounted) return;

      setState(() {
        servicios = datos;
        cargando = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      mostrarMensaje('Error al cargar servicios');
    }
  }

  // MOSTRAR MENSAJES
  void mostrarMensaje(String mensaje) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // FORMULARIO PARA CREAR Y EDITAR
  void formularioServicio({Map<String, dynamic>? servicio}) {

    final nombre = TextEditingController(
      text: servicio?['title'] ?? '',
    );

    final descripcion = TextEditingController(
      text: servicio?['body'] ?? '',
    );

    showDialog(
      context: context,
      builder: (contexto) {

        return AlertDialog(

          title: Text(
            servicio == null
                ? 'Nuevo servicio'
                : 'Editar servicio',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre del servicio',
                ),
              ),

              TextField(
                controller: descripcion,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(contexto);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(

              onPressed: () async {

                if (nombre.text.trim().isEmpty ||
                    descripcion.text.trim().isEmpty) {

                  mostrarMensaje('Completa todos los campos');
                  return;
                }

                try {

                  if (servicio == null) {

                    // CREATE - CREAR SERVICIO

                    final nuevo = await api.crearServicio(
                      nombre.text.trim(),
                      descripcion.text.trim(),
                    );

                    // GENERAR ID LOCAL

                    final nuevoId = servicios.isEmpty
                        ? 101
                        : servicios
                        .map((s) => s['id'] as int)
                        .reduce((a, b) => a > b ? a : b) + 1;

                    // AGREGAR A LA LISTA

                    setState(() {

                      servicios.insert(0, {
                        ...nuevo,
                        'id': nuevoId,
                        '_local': true,
                      });

                    });

                    mostrarMensaje('Servicio creado');

                  } else {

                    // UPDATE - ACTUALIZAR SERVICIO

                    Map<String, dynamic> actualizado;

                    if (servicio['_local'] == true) {

                      // ACTUALIZAR REGISTRO LOCAL

                      actualizado = {
                        ...servicio,
                        'title': nombre.text.trim(),
                        'body': descripcion.text.trim(),
                      };

                    } else {

                      // ACTUALIZAR REGISTRO EN LA API

                      actualizado = await api.actualizarServicio(
                        servicio['id'],
                        nombre.text.trim(),
                        descripcion.text.trim(),
                      );

                    }

                    // ACTUALIZAR EN LA LISTA

                    setState(() {

                      final indice = servicios.indexWhere(
                            (s) => s['id'] == servicio['id'],
                      );

                      if (indice != -1) {

                        servicios[indice] = {
                          ...actualizado,
                          'id': servicio['id'],
                          if (servicio['_local'] == true)
                            '_local': true,
                        };

                      }

                    });

                    mostrarMensaje('Servicio actualizado');

                  }

                  if (!mounted) return;

                  Navigator.pop(contexto);

                } catch (e) {

                  mostrarMensaje('Error al guardar');

                  debugPrint('ERROR CRUD: $e');

                }

              },

              child: const Text('Guardar'),

            ),
          ],
        );
      },
    ).then((_) {
      nombre.dispose();
      descripcion.dispose();
    });
  }

  // DELETE - ELIMINAR SERVICIO
  Future<void> eliminarServicio(int id) async {

    try {

      // BUSCAR SERVICIO

      final servicio = servicios.firstWhere(
            (element) => element['id'] == id,
      );

      // ELIMINAR DE LA API SI NO ES LOCAL

      if (servicio['_local'] != true) {

        await api.eliminarServicio(id);

      }

      // ELIMINAR DE LA LISTA

      setState(() {

        servicios.removeWhere(
              (element) => element['id'] == id,
        );

      });

      mostrarMensaje('Servicio eliminado');

    } catch (e) {

      mostrarMensaje('Error al eliminar');

      debugPrint('ERROR DELETE: $e');

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        title: const Text('Servicios Barber Shop'),
        backgroundColor: const Color(0xFF111111),
        foregroundColor: const Color(0xFFD4AF37),
      ),

      // BOTON AGREGAR

      floatingActionButton: FloatingActionButton(

        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,

        onPressed: () {
          formularioServicio();
        },

        child: const Icon(Icons.add),

      ),

      body: cargando

          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      )

          : servicios.isEmpty

          ? const Center(
        child: Text(
          'No hay servicios disponibles',
          style: TextStyle(color: Colors.white),
        ),
      )

          : RefreshIndicator(

        onRefresh: cargarServicios,

        child: ListView.builder(

          itemCount: servicios.length,

          itemBuilder: (context, index) {

            final servicio = servicios[index];

            return Card(

              color: const Color(0xFF222222),

              margin: const EdgeInsets.all(10),

              child: ListTile(

                // NOMBRE DEL SERVICIO

                title: Text(
                  servicio['title'] ?? '',

                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // DESCRIPCION

                subtitle: Text(
                  "SI " + servicio['body']?? '',

                  style: const TextStyle(
                    color: Colors.white70,
                  ),

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // MENU DE OPCIONES

                trailing: PopupMenuButton<String>(

                  iconColor: Colors.white,

                  onSelected: (opcion) {

                    if (opcion == 'editar') {

                      formularioServicio(
                        servicio: Map<String, dynamic>.from(
                          servicio,
                        ),
                      );

                    }

                    if (opcion == 'eliminar') {

                      eliminarServicio(
                        servicio['id'],
                      );

                    }

                  },

                  itemBuilder: (context) => [

                    const PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),

                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),

                  ],

                ),

              ),

            );

          },

        ),

      ),

    );
  }
}
