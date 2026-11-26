import 'package:flutter/material.dart';
import 'package:agenda_barber/login.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';
import 'nueva_cita_page.dart';
import 'cita_detalle_page.dart';
import 'servicios_page.dart';
import 'barberos_page.dart';

class InicioPage extends StatelessWidget {
  final void Function(int) irA;
  const InicioPage({super.key, required this.irA});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Se refresca cada 30 s para que "En 19 min" se mantenga al día.
      child: StreamBuilder<int>(
        stream: Stream.periodic(const Duration(seconds: 30), (i) => i),
        builder: (context, _) => ListenableBuilder(
          listenable: store,
          builder: (context, _) => _contenido(context),
        ),
      ),
    );
  }

  String _enTexto(DateTime ini, DateTime ahora) {
    final m = ini.difference(ahora).inMinutes;
    if (m <= 0) return 'En curso';
    if (m < 60) return 'En $m min';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? 'En $h h' : 'En $h h $r min';
  }

  Widget _contenido(BuildContext context) {
    final ahora = DateTime.now();
    final hoy = store.citasDelDia(ahora).where((c) => c.estado != Estado.cancelada).toList();
    final hechas = hoy.where((c) => c.estado == Estado.completada).length;
    final total = hoy.fold<int>(0, (s, c) => s + c.precio);
    final sig = store.siguienteCita(ahora);
    final despues = hoy
        .where((c) =>
            sig != null &&
            c.inicio.isAfter(sig.inicio) &&
            (c.estado == Estado.pendiente || c.estado == Estado.confirmada))
        .take(2)
        .toList();
    final porConfirmar = hoy.where((c) => c.estado == Estado.pendiente).toList();
    final saludo = ahora.hour < 12
        ? 'Buen día.'
        : ahora.hour < 19
            ? 'Buenas tardes.'
            : 'Buenas noches.';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: C.oroSuave, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.content_cut, color: C.oro, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('JP Barber',
                        style: TextStyle(
                            color: C.texto, fontSize: 22, fontWeight: FontWeight.w600)),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: C.texto, size: 28),
                        onPressed: () => _notificaciones(context, porConfirmar),
                      ),
                      if (porConfirmar.isNotEmpty)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(color: C.oro, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _menu(context),
                    child: const AvatarIniciales('Erick Juarez', size: 48, resaltado: true),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(saludo,
                  style: const TextStyle(
                      color: C.texto, fontSize: 40, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(fechaLarga(ahora),
                  style: const TextStyle(color: C.gris, fontSize: 17)),
              const SizedBox(height: 22),
              // Estadísticas
              Row(
                children: [
                  _stat('${hoy.length}', 'Citas hoy', C.texto),
                  const SizedBox(width: 12),
                  _stat('$hechas', 'Completadas', C.texto),
                  const SizedBox(width: 12),
                  _stat(dinero(total), 'Total previsto', C.oro),
                ],
              ),
              const SizedBox(height: 22),
              // Siguiente cita
              if (sig != null) _siguiente(context, sig, ahora) else _sinCitas(),
              const SizedBox(height: 26),
              if (despues.isNotEmpty) ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text('Después, en tu agenda',
                          style: TextStyle(
                              color: C.texto, fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () => irA(1),
                      child: const Text('Ver todas',
                          style: TextStyle(
                              color: C.oro, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final c in despues) _filaDespues(context, c),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: BotonOro('Nueva cita',
              icono: Icons.add,
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const NuevaCitaPage()))),
        ),
      ],
    );
  }

  Widget _stat(String valor, String etiqueta, Color color) {
    return Expanded(
      child: Tarjeta(
        padding: const EdgeInsets.fromLTRB(16, 18, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(valor,
                  style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 4),
            Text(etiqueta, style: const TextStyle(color: C.gris, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _siguiente(BuildContext context, Cita sig, DateTime ahora) {
    final cli = store.cliente(sig.clienteId);
    final bar = store.barbero(sig.barberoId);
    return Tarjeta(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => CitaDetallePage(citaId: sig.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: C.oroSuave,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: const Text('SIGUIENTE CITA',
                style: TextStyle(
                    color: C.oro, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarIniciales(cli?.nombre ?? '?', size: 56, resaltado: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cli?.nombre ?? 'Cliente eliminado',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: C.texto, fontSize: 23, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${sig.servicioNombre} · ${sig.minutos} min · ${dinero(sig.precio)}',
                              style: const TextStyle(color: C.gris, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Insignia(_enTexto(sig.inicio, ahora), fondo: C.oroSuave, color: C.oro),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${horaTxt(sig.inicio)} — ${horaTxt(sig.fin)}',
                        style: const TextStyle(
                            color: C.texto, fontSize: 19, fontWeight: FontWeight.w600)),
                    Text('Con ${bar?.nombre ?? '—'}',
                        style: const TextStyle(color: C.gris, fontSize: 15)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: C.borde),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ver detalle de la cita',
                        style: TextStyle(
                            color: C.oro, fontSize: 16, fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward, color: C.oro),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinCitas() {
    return const Tarjeta(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.event_available, color: C.oro, size: 40),
          SizedBox(height: 10),
          Text('No tienes más citas por atender hoy',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.texto, fontSize: 17, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text('Crea una nueva con el botón de abajo.',
              style: TextStyle(color: C.gris, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _filaDespues(BuildContext context, Cita c) {
    final cli = store.cliente(c.clienteId);
    final bar = store.barbero(c.barberoId);
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => CitaDetallePage(citaId: c.id))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(horaTxt(c.inicio),
                  style: const TextStyle(
                      color: C.oro, fontSize: 19, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cli?.nombre ?? '—',
                      style: const TextStyle(
                          color: C.texto, fontSize: 18, fontWeight: FontWeight.w500)),
                  Text('${c.servicioNombre} · ${bar?.nombre.split(' ').first ?? '—'}',
                      style: const TextStyle(color: C.gris, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: C.gris),
          ],
        ),
      ),
    );
  }

  void _notificaciones(BuildContext context, List<Cita> pendientes) {
    hoja<void>(
      context,
      (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TituloHoja('Citas por confirmar hoy'),
          if (pendientes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Todo al día, no hay citas pendientes de confirmar.',
                  style: TextStyle(color: C.gris)),
            ),
          for (final p in pendientes)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AvatarIniciales(store.cliente(p.clienteId)?.nombre ?? '?'),
              title: Text(store.cliente(p.clienteId)?.nombre ?? '—',
                  style: const TextStyle(color: C.texto)),
              subtitle: Text('${horaTxt(p.inicio)} · ${p.servicioNombre}',
                  style: const TextStyle(color: C.gris)),
              trailing: const Icon(Icons.chevron_right, color: C.gris),
              onTap: () {
                Navigator.pop(c);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CitaDetallePage(citaId: p.id)));
              },
            ),
        ],
      ),
    );
  }

  void _menu(BuildContext context) {
    Widget op(BuildContext c, IconData i, String t, VoidCallback f, {Color color = C.texto}) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(i, color: color == C.texto ? C.oro : color),
        title: Text(t, style: TextStyle(color: color, fontSize: 17)),
        onTap: () {
          Navigator.pop(c);
          f();
        },
      );
    }

    hoja<void>(
      context,
      (c) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TituloHoja('Mi barbería'),
          op(c, Icons.content_cut, 'Servicios', () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ServiciosPage()))),
          op(c, Icons.badge_outlined, 'Barberos', () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const BarberosPage()))),
          op(c, Icons.logout, 'Cerrar sesión', () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MiLogin()), (r) => false),
              color: C.rojo),
        ],
      ),
    );
  }
}
