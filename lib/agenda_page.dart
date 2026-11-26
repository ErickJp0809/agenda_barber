import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';
import 'nueva_cita_page.dart';
import 'cita_detalle_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime dia = soloDia(DateTime.now());
  String? barberoId; // null = todos
  Estado? estado; // null = todos
  bool verTarde = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => _contenido(context),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    final ahora = DateTime.now();
    final lunes = sumarDias(dia, -(dia.weekday - 1));
    final delBarbero = store.citasDelDia(dia, barberoId: barberoId);
    final activas = delBarbero.where((c) => c.estado != Estado.cancelada).toList();
    final hechas = activas.where((c) => c.estado == Estado.completada).length;
    final lista = estado == null
        ? delBarbero
        : delBarbero.where((c) => c.estado == estado).toList();
    final manana = lista.where((c) => c.inicio.hour < 14).toList();
    final tarde = lista.where((c) => c.inicio.hour >= 14).toList();
    final separar = manana.isNotEmpty && tarde.isNotEmpty;
    final visibles = (separar && !verTarde) ? manana : lista;
    final sig = mismoDia(dia, ahora) ? store.siguienteCita(ahora) : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Agenda',
                  style: TextStyle(color: C.texto, fontSize: 36, fontWeight: FontWeight.w700)),
            ),
            BotonRedondo(
              Icons.add,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NuevaCitaPage(fecha: dia, barberoId: barberoId)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Mes + flechas (cambian de semana)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final f = await elegirFecha(context, dia);
                  if (f != null) setState(() => dia = soloDia(f));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${cap(nombreMes(dia))} de ${dia.year}',
                        style: const TextStyle(color: C.texto, fontSize: 20)),
                    const Icon(Icons.arrow_drop_down, color: C.gris),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left, color: C.texto),
              onPressed: () => setState(() => dia = sumarDias(dia, -7)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: C.texto),
              onPressed: () => setState(() => dia = sumarDias(dia, 7)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tira de la semana
        Row(
          children: [
            for (var i = 0; i < 7; i++) _diaSemana(sumarDias(lunes, i), i, ahora),
          ],
        ),
        const SizedBox(height: 18),
        // Filtros
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChipFiltro('Todos',
                        activo: barberoId == null,
                        onTap: () => setState(() => barberoId = null)),
                    for (final b in store.barberos)
                      ChipFiltro(b.nombre.split(' ').first,
                          activo: barberoId == b.id,
                          onTap: () => setState(() => barberoId = b.id)),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.tune, color: estado == null ? C.gris : C.oro),
              onPressed: _filtroEstado,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(etiquetaDia(dia),
                  style: const TextStyle(
                      color: C.texto, fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            Text('${activas.length} citas · $hechas completadas',
                style: const TextStyle(color: C.gris, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 14),
        if (visibles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.event_busy, color: C.gris, size: 44),
                SizedBox(height: 10),
                Text('No hay citas para este día',
                    style: TextStyle(color: C.gris, fontSize: 16)),
              ],
            ),
          ),
        for (final c in visibles)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CitaTarjeta(
              cita: c,
              proxima: sig != null && sig.id == c.id,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CitaDetallePage(citaId: c.id))),
            ),
          ),
        if (separar)
          Center(
            child: TextButton(
              onPressed: () => setState(() => verTarde = !verTarde),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      verTarde
                          ? 'Ocultar las citas de la tarde'
                          : 'Ver las ${tarde.length} citas de la tarde',
                      style: const TextStyle(color: C.oro, fontSize: 16)),
                  const SizedBox(width: 6),
                  Icon(verTarde ? Icons.arrow_upward : Icons.arrow_downward,
                      color: C.oro, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _diaSemana(DateTime f, int i, DateTime ahora) {
    final sel = mismoDia(f, dia);
    final hoy = mismoDia(f, ahora);
    final tiene = store.citasDelDia(f, barberoId: barberoId)
        .any((c) => c.estado != Estado.cancelada);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => dia = f),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          decoration: BoxDecoration(
            color: sel ? C.oro : C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hoy && !sel ? C.oro : Colors.transparent),
          ),
          child: Column(
            children: [
              Text('LMXJVSD'[i],
                  style: TextStyle(color: sel ? C.oscuro : C.gris, fontSize: 14)),
              const SizedBox(height: 6),
              Text('${f.day}',
                  style: TextStyle(
                      color: sel ? C.oscuro : C.texto,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tiene ? (sel ? C.oscuro : C.oro) : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _filtroEstado() {
    hoja<void>(
      context,
      (c) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TituloHoja('Filtrar por estado'),
          for (final e in <Estado?>[null, ...Estado.values])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e == null ? 'Todos' : e.texto,
                  style: TextStyle(color: estado == e ? C.oro : C.texto, fontSize: 17)),
              trailing: estado == e ? const Icon(Icons.check, color: C.oro) : null,
              onTap: () {
                setState(() => estado = e);
                Navigator.pop(c);
              },
            ),
        ],
      ),
    );
  }
}
