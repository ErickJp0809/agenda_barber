import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';

class BarberosPage extends StatelessWidget {
  const BarberosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => PantallaLista(
        titulo: 'Barberos',
        vacio: 'No hay barberos. Agrega el primero con +',
        onAgregar: () => _formulario(context),
        hijos: [
          for (final b in store.barberos)
            ItemCatalogo(
              icono: Icons.badge_outlined,
              titulo: b.nombre,
              subtitulo: '',
              onEditar: () => _formulario(context, barbero: b),
              onEliminar: () async {
                final ok = await confirmar(
                    context, 'Eliminar barbero', '¿Eliminar a ${b.nombre}?',
                    si: 'Eliminar');
                if (!ok || !context.mounted) return;
                if (!store.eliminarBarbero(b.id)) {
                  aviso(context, 'No se puede: tiene citas asignadas');
                }
              },
            ),
        ],
      ),
    );
  }

  void _formulario(BuildContext context, {Barbero? barbero}) {
    final nombre = TextEditingController(text: barbero?.nombre ?? '');
    final llave = GlobalKey<FormState>();

    hoja<void>(
      context,
      (c) => Form(
        key: llave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloHoja(barbero == null ? 'Nuevo barbero' : 'Editar barbero'),
            TextFormField(
              controller: nombre,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: C.texto),
              decoration: deco('Nombre completo', fill: C.bg),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Escribe el nombre' : null,
            ),
            const SizedBox(height: 20),
            BotonOro('Guardar', onPressed: () {
              if (!llave.currentState!.validate()) return;
              store.guardarBarbero(
                  Barbero(id: barbero?.id ?? store.nuevoId(), nombre: nombre.text.trim()));
              Navigator.pop(c);
            }),
          ],
        ),
      ),
    );
  }
}
