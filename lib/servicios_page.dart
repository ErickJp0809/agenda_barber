import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';

class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => PantallaLista(
        titulo: 'Servicios',
        vacio: 'No hay servicios. Agrega el primero con +',
        onAgregar: () => _formulario(context),
        hijos: [
          for (final s in store.servicios)
            ItemCatalogo(
              icono: Icons.content_cut,
              titulo: s.nombre,
              subtitulo: '${s.minutos} min · ${dinero(s.precio)}',
              onEditar: () => _formulario(context, servicio: s),
              onEliminar: () async {
                final ok = await confirmar(
                    context, 'Eliminar servicio', '¿Eliminar "${s.nombre}"?',
                    si: 'Eliminar');
                if (!ok || !context.mounted) return;
                if (!store.eliminarServicio(s.id)) {
                  aviso(context, 'No se puede: hay citas con este servicio');
                }
              },
            ),
        ],
      ),
    );
  }

  void _formulario(BuildContext context, {Servicio? servicio}) {
    final nombre = TextEditingController(text: servicio?.nombre ?? '');
    final minutos = TextEditingController(text: servicio?.minutos.toString() ?? '30');
    final precio = TextEditingController(text: servicio?.precio.toString() ?? '');
    final llave = GlobalKey<FormState>();

    hoja<void>(
      context,
      (c) => Form(
        key: llave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloHoja(servicio == null ? 'Nuevo servicio' : 'Editar servicio'),
            TextFormField(
              controller: nombre,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: C.texto),
              decoration: deco('Nombre del servicio', fill: C.bg),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe el nombre' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: minutos,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: C.texto),
                    decoration: deco('Duración (min)', fill: C.bg),
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      return (n == null || n < 5 || n > 240) ? '5 a 240' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: precio,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: C.texto),
                    decoration: deco('Precio', fill: C.bg),
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      return (n == null || n < 0) ? 'Precio no válido' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BotonOro('Guardar', onPressed: () {
              if (!llave.currentState!.validate()) return;
              store.guardarServicio(Servicio(
                id: servicio?.id ?? store.nuevoId(),
                nombre: nombre.text.trim(),
                minutos: int.parse(minutos.text.trim()),
                precio: int.parse(precio.text.trim()),
              ));
              Navigator.pop(c);
            }),
          ],
        ),
      ),
    );
  }
}
