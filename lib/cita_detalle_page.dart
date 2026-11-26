import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';
import 'recordatorio.dart';
import 'nueva_cita_page.dart';

class CitaDetallePage extends StatelessWidget {
  final String citaId;
  const CitaDetallePage({super.key, required this.citaId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final c = store.cita(citaId);
        if (c == null) return const Scaffold(body: SizedBox.shrink());
        final cli = store.cliente(c.clienteId);
        final bar = store.barbero(c.barberoId);
        final activa = c.estado == Estado.pendiente || c.estado == Estado.confirmada;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    BotonRedondo(Icons.arrow_back, () => Navigator.pop(context), color: C.texto),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text('Detalle de la cita',
                          style: TextStyle(
                              color: C.texto, fontSize: 26, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Tarjeta(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AvatarIniciales(cli?.nombre ?? '?', size: 58, resaltado: true),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cli?.nombre ?? 'Cliente eliminado',
                                    style: const TextStyle(
                                        color: C.texto,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600)),
                                Text(cli?.telefono ?? '',
                                    style: const TextStyle(color: C.gris, fontSize: 15)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      insigniaEstado(c.estado),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: C.borde),
                      ),
                      _fila(Icons.content_cut, 'Servicio', c.servicioNombre),
                      _fila(Icons.badge_outlined, 'Barbero', bar?.nombre ?? '—'),
                      _fila(Icons.calendar_month_outlined, 'Fecha', fechaLarga(c.inicio)),
                      _fila(Icons.schedule, 'Horario',
                          '${horaTxt(c.inicio)} — ${horaTxt(c.fin)} (${c.minutos} min)'),
                      _fila(Icons.payments_outlined, 'Precio', dinero(c.precio)),
                      _fila(Icons.chat_outlined, 'Recordatorio',
                          c.recordatorio ? 'Activado' : 'Desactivado'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (c.estado == Estado.pendiente) ...[
                  BotonOro('Confirmar cita',
                      icono: Icons.check,
                      onPressed: () => store.cambiarEstado(c, Estado.confirmada)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: BotonContorno('Marcar como completada',
                        icono: Icons.done_all,
                        onPressed: () => store.cambiarEstado(c, Estado.completada)),
                  ),
                ],
                if (c.estado == Estado.confirmada)
                  BotonOro('Marcar como completada',
                      icono: Icons.done_all,
                      onPressed: () => store.cambiarEstado(c, Estado.completada)),
                if (c.estado == Estado.cancelada)
                  BotonOro('Reactivar cita', icono: Icons.restore, onPressed: () {
                    if (store.haySolape(c.barberoId, c.inicio, c.minutos, excluirId: c.id)) {
                      aviso(context, 'Ese horario ya fue ocupado por otra cita');
                    } else {
                      store.cambiarEstado(c, Estado.pendiente);
                    }
                  }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: BotonContorno('Editar',
                          icono: Icons.edit_outlined,
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NuevaCitaPage(editar: c)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BotonContorno('Recordatorio',
                          icono: Icons.chat_outlined,
                          onPressed: () =>
                              enviarRecordatorio(c, ScaffoldMessenger.of(context))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (activa)
                  SizedBox(
                    width: double.infinity,
                    child: BotonContorno('Cancelar cita',
                        icono: Icons.event_busy,
                        color: C.rojo,
                        onPressed: () async {
                          final ok = await confirmar(context, 'Cancelar cita',
                              '¿Seguro que quieres cancelar esta cita?',
                              si: 'Sí, cancelar');
                          if (ok) store.cambiarEstado(c, Estado.cancelada);
                        }),
                  ),
                if (activa) const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: BotonContorno('Eliminar',
                      icono: Icons.delete_outline,
                      color: C.rojo,
                      onPressed: () async {
                        final ok = await confirmar(context, 'Eliminar cita',
                            'Se borrará por completo de la agenda.',
                            si: 'Eliminar');
                        if (ok && context.mounted) {
                          Navigator.pop(context);
                          store.eliminarCita(c.id);
                        }
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fila(IconData i, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: C.oro, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(k, style: const TextStyle(color: C.gris, fontSize: 15)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    color: C.texto, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
