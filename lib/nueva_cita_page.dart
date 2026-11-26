import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';
import 'recordatorio.dart';
import 'clientes_page.dart';

class NuevaCitaPage extends StatefulWidget {
  final Cita? editar;
  final DateTime? fecha;
  final String? barberoId;
  final String? clienteId;
  const NuevaCitaPage({super.key, this.editar, this.fecha, this.barberoId, this.clienteId});

  @override
  State<NuevaCitaPage> createState() => _NuevaCitaPageState();
}

class _NuevaCitaPageState extends State<NuevaCitaPage> {
  String? clienteId;
  String? servicioId;
  String? barberoId;
  late DateTime fecha;
  DateTime? inicio;
  bool recordatorio = true;

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    if (e != null) {
      clienteId = e.clienteId;
      servicioId = e.servicioId;
      barberoId = e.barberoId;
      fecha = soloDia(e.inicio);
      inicio = e.inicio;
      recordatorio = e.recordatorio;
    } else {
      clienteId = widget.clienteId;
      servicioId = store.servicios.isEmpty ? null : store.servicios.first.id;
      barberoId = widget.barberoId ??
          (store.barberos.isEmpty ? null : store.barberos.first.id);
      fecha = soloDia(widget.fecha ?? DateTime.now());
    }
  }

  // Horarios cada 30 min de 9:00 a 20:00 que alcancen a terminar antes del cierre.
  List<DateTime> _horarios(int minutos) {
    final l = <DateTime>[];
    var t = DateTime(fecha.year, fecha.month, fecha.day, 9);
    final cierre = DateTime(fecha.year, fecha.month, fecha.day, 20);
    while (!t.add(Duration(minutes: minutos)).isAfter(cierre)) {
      l.add(t);
      t = t.add(const Duration(minutes: 30));
    }
    return l;
  }

  bool _ocupado(DateTime t, int minutos) {
    final e = widget.editar;
    final esElMismo = e != null && t.isAtSameMomentAs(e.inicio);
    if (t.isBefore(DateTime.now()) && !esElMismo) return true;
    return store.haySolape(barberoId!, t, minutos, excluirId: e?.id);
  }

  // La hora elegida solo vale si sigue disponible tras cambiar fecha/servicio/barbero.
  DateTime? _seleccion(List<DateTime> slots, int minutos) {
    final i = inicio;
    if (i == null || barberoId == null) return null;
    final existe = slots.any((s) => s.isAtSameMomentAs(i));
    return existe && !_ocupado(i, minutos) ? i : null;
  }

  @override
  Widget build(BuildContext context) {
    final cliente = clienteId == null ? null : store.cliente(clienteId!);
    final servicio = servicioId == null ? null : store.servicio(servicioId!);
    final minutos = servicio?.minutos ?? 30;
    final slots = barberoId == null ? <DateTime>[] : _horarios(minutos);
    final sel = _seleccion(slots, minutos);
    final editando = widget.editar != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: C.texto),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(editando ? 'Editar cita' : 'Nueva cita',
                        style: const TextStyle(
                            color: C.texto, fontSize: 32, fontWeight: FontWeight.w700)),
                  ),
                  BotonRedondo(Icons.close, () => Navigator.pop(context), color: C.texto),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  const Text('Un buen servicio empieza con una buena cita.',
                      style: TextStyle(color: C.gris, fontSize: 16)),
                  const SizedBox(height: 18),
                  _etiqueta('Cliente'),
                  _campo(
                    icono: Icons.person_outline,
                    titulo: cliente?.nombre ?? 'Selecciona un cliente',
                    sub: cliente?.telefono,
                    vacio: cliente == null,
                    onTap: () async {
                      final id = await hoja<String>(context, (c) => const SelectorCliente());
                      if (id != null) setState(() => clienteId = id);
                    },
                  ),
                  const SizedBox(height: 18),
                  _etiqueta('Servicio'),
                  _campo(
                    icono: Icons.content_cut,
                    titulo: servicio?.nombre ?? 'Selecciona un servicio',
                    sub: servicio == null
                        ? null
                        : '${servicio.minutos} min · ${dinero(servicio.precio)}',
                    vacio: servicio == null,
                    onTap: _elegirServicio,
                  ),
                  const SizedBox(height: 18),
                  _etiqueta('Barbero'),
                  if (store.barberos.isEmpty)
                    const Text('Agrega un barbero desde el menú de tu perfil.',
                        style: TextStyle(color: C.gris))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [for (final b in store.barberos) _chipBarbero(b)],
                    ),
                  const SizedBox(height: 18),
                  _etiqueta('Fecha'),
                  _campo(
                    icono: Icons.calendar_month_outlined,
                    titulo: fechaLarga(fecha),
                    onTap: () async {
                      final f = await elegirFecha(context, fecha);
                      if (f != null) setState(() => fecha = soloDia(f));
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _etiqueta('Hora de inicio')),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('Duración: $minutos min',
                            style: const TextStyle(color: C.gris, fontSize: 14)),
                      ),
                    ],
                  ),
                  _horas(slots, sel, minutos),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Enviar recordatorio por WhatsApp',
                            style: TextStyle(color: C.gris, fontSize: 16)),
                      ),
                      Switch(
                        value: recordatorio,
                        activeThumbColor: C.oscuro,
                        activeTrackColor: C.oro,
                        onChanged: (v) => setState(() => recordatorio = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            sel == null
                                ? '$minutos min · Elige una hora'
                                : '$minutos min · Finaliza a las ${horaTxt(sel.add(Duration(minutes: minutos)))}',
                            style: const TextStyle(color: C.gris, fontSize: 15)),
                      ),
                      Text(dinero(servicio?.precio ?? 0),
                          style: const TextStyle(
                              color: C.texto, fontSize: 26, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BotonOro(editando ? 'Guardar cambios' : 'Crear cita',
                      icono: Icons.check,
                      onPressed: () => _guardar(sel, cliente, servicio)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(color: C.gris, fontSize: 16)),
      );

  Widget _campo({
    required IconData icono,
    required String titulo,
    String? sub,
    required VoidCallback onTap,
    bool vacio = false,
  }) {
    return Tarjeta(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radio: 18,
      child: Row(
        children: [
          Icon(icono, color: C.oro),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        color: vacio ? C.gris : C.texto,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                if (sub != null)
                  Text(sub, style: const TextStyle(color: C.gris, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: C.gris),
        ],
      ),
    );
  }

  Widget _chipBarbero(Barbero b) {
    final sel = barberoId == b.id;
    return GestureDetector(
      onTap: () => setState(() => barberoId = b.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? C.oroSuave : C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: sel ? C.oro : C.borde),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarIniciales(b.nombre, size: 34, resaltado: sel),
            const SizedBox(width: 10),
            Text(b.nombre,
                style: TextStyle(
                    color: sel ? C.oro : C.gris, fontSize: 16, fontWeight: FontWeight.w500)),
            if (sel) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, color: C.oro, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _horas(List<DateTime> slots, DateTime? sel, int minutos) {
    if (barberoId == null) {
      return const Text('Selecciona un barbero para ver horarios.',
          style: TextStyle(color: C.gris));
    }
    return LayoutBuilder(builder: (context, caja) {
      final ancho = (caja.maxWidth - 3 * 8) / 4;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in slots)
            () {
              final off = _ocupado(t, minutos);
              final esSel = sel != null && sel.isAtSameMomentAs(t);
              return GestureDetector(
                onTap: off ? null : () => setState(() => inicio = t),
                child: Container(
                  width: ancho,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: esSel ? C.oro : C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: esSel ? C.oro : C.borde),
                  ),
                  child: Text(horaTxt(t),
                      style: TextStyle(
                        color: esSel ? C.oscuro : (off ? C.gris : C.texto),
                        fontSize: 16,
                        fontWeight: esSel ? FontWeight.w700 : FontWeight.w500,
                        decoration: off ? TextDecoration.lineThrough : null,
                        decorationColor: C.gris,
                      )),
                ),
              );
            }(),
        ],
      );
    });
  }

  void _elegirServicio() async {
    final id = await hoja<String>(
      context,
      (c) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TituloHoja('Servicio'),
          if (store.servicios.isEmpty)
            const Text('No hay servicios. Agrégalos desde el menú de tu perfil.',
                style: TextStyle(color: C.gris)),
          for (final s in store.servicios)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.content_cut, color: C.oro),
              title: Text(s.nombre, style: const TextStyle(color: C.texto, fontSize: 17)),
              subtitle: Text('${s.minutos} min · ${dinero(s.precio)}',
                  style: const TextStyle(color: C.gris)),
              trailing: servicioId == s.id ? const Icon(Icons.check, color: C.oro) : null,
              onTap: () => Navigator.pop(c, s.id),
            ),
        ],
      ),
    );
    if (id != null) setState(() => servicioId = id);
  }

  void _guardar(DateTime? sel, Cliente? cli, Servicio? srv) {
    if (cli == null) return aviso(context, 'Selecciona un cliente');
    if (srv == null) return aviso(context, 'Selecciona un servicio');
    if (barberoId == null) return aviso(context, 'Selecciona un barbero');
    if (sel == null) return aviso(context, 'Elige una hora disponible');

    final e = widget.editar;
    final cita = Cita(
      id: e?.id ?? store.nuevoId(),
      clienteId: cli.id,
      servicioId: srv.id,
      servicioNombre: srv.nombre,
      barberoId: barberoId!,
      inicio: sel,
      minutos: srv.minutos,
      precio: srv.precio,
      estado: e?.estado ?? Estado.pendiente,
      recordatorio: recordatorio,
    );
    store.guardarCita(cita);

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
        SnackBar(content: Text(e == null ? 'Cita creada' : 'Cita actualizada')));
    if (recordatorio && e == null) enviarRecordatorio(cita, messenger);
  }
}
