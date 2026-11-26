import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';

// ---------------------------------------------------------------------------
// Piezas básicas
// ---------------------------------------------------------------------------
class Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? borde;
  final Color? fondo;
  final double radio;

  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borde,
    this.fondo,
    this.radio = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fondo ?? C.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radio),
        side: BorderSide(color: borde ?? C.borde),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Insignia extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color color;
  const Insignia(this.texto, {super.key, required this.fondo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
      child: Text(texto,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}

Widget insigniaEstado(Estado e, {bool proxima = false}) {
  if (proxima) return const Insignia('Próxima', fondo: C.oroSuave, color: C.oro);
  switch (e) {
    case Estado.pendiente:
      return const Insignia('Pendiente', fondo: C.oroSuave, color: C.oro);
    case Estado.confirmada:
      return const Insignia('Confirmada', fondo: C.verdeFondo, color: C.verde);
    case Estado.completada:
      return const Insignia('Completada', fondo: Color(0xFF2E2F2A), color: C.gris);
    case Estado.cancelada:
      return const Insignia('Cancelada', fondo: C.rojoFondo, color: C.rojo);
  }
}

class AvatarIniciales extends StatelessWidget {
  final String nombre;
  final double size;
  final bool resaltado;
  const AvatarIniciales(this.nombre, {super.key, this.size = 48, this.resaltado = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: resaltado ? C.oroSuave : const Color(0xFF2E2F2A),
      ),
      child: Text(
        iniciales(nombre),
        style: TextStyle(
          color: resaltado ? C.oro : C.texto,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.33,
        ),
      ),
    );
  }
}

class BotonOro extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback? onPressed;
  const BotonOro(this.texto, {super.key, this.icono, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: C.oro,
          foregroundColor: C.oscuro,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null) ...[Icon(icono, size: 22), const SizedBox(width: 10)],
            Text(texto, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class BotonContorno extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback? onPressed;
  final Color color;
  const BotonContorno(this.texto,
      {super.key, this.icono, this.onPressed, this.color = C.texto});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color == C.texto ? C.borde : color.withAlpha(120)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null) ...[Icon(icono, size: 19), const SizedBox(width: 8)],
            Flexible(
              child: Text(texto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

class BotonRedondo extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  final Color color;
  const BotonRedondo(this.icono, this.onTap, {super.key, this.color = C.oro});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.card,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icono, color: color)),
      ),
    );
  }
}

class ChipFiltro extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;
  const ChipFiltro(this.texto, {super.key, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? C.oroSuave : C.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: activo ? C.oro : C.borde),
        ),
        child: Text(texto,
            style: TextStyle(
                color: activo ? C.oro : C.gris,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

InputDecoration deco(String label, {String? hint, Color? fill, IconData? icono}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      fillColor: fill,
      prefixIcon: icono == null ? null : Icon(icono, color: C.gris),
    );

void aviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}

Future<bool> confirmar(BuildContext context, String titulo, String mensaje,
    {String si = 'Aceptar'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: C.card,
      title: Text(titulo, style: const TextStyle(color: C.texto)),
      content: Text(mensaje, style: const TextStyle(color: C.gris)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Cancelar', style: TextStyle(color: C.gris)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(si, style: const TextStyle(color: C.oro)),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Hoja inferior estándar (selectores y formularios).
Future<T?> hoja<T>(BuildContext context, Widget Function(BuildContext) builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
      child: SafeArea(top: false, child: SingleChildScrollView(child: builder(c))),
    ),
  );
}

class TituloHoja extends StatelessWidget {
  final String texto;
  const TituloHoja(this.texto, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(texto,
            style: const TextStyle(color: C.texto, fontSize: 22, fontWeight: FontWeight.w600)),
      );
}

// ---------------------------------------------------------------------------
// Tarjeta de cita (la usan Agenda y el historial de clientes)
// ---------------------------------------------------------------------------
class CitaTarjeta extends StatelessWidget {
  final Cita cita;
  final bool proxima;
  final bool mostrarFecha;
  final VoidCallback onTap;
  const CitaTarjeta({
    super.key,
    required this.cita,
    required this.onTap,
    this.proxima = false,
    this.mostrarFecha = false,
  });

  @override
  Widget build(BuildContext context) {
    final cli = store.cliente(cita.clienteId);
    final bar = store.barbero(cita.barberoId);
    final apagada = cita.estado == Estado.cancelada;
    final extra = '${mostrarFecha ? '${cita.inicio.day} ${mesCorto(cita.inicio)} · ' : ''}'
        '${bar?.nombre ?? 'Sin barbero'}';
    return Tarjeta(
      onTap: onTap,
      borde: proxima ? C.oro : null,
      child: Opacity(
        opacity: apagada ? 0.55 : 1,
        child: Row(
          children: [
            SizedBox(
              width: 54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(horaTxt(cita.inicio),
                      style: TextStyle(
                          color: proxima ? C.oro : C.texto,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(horaTxt(cita.fin),
                      style: const TextStyle(color: C.gris, fontSize: 14)),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: C.borde,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(cli?.nombre ?? 'Cliente eliminado',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: C.texto, fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      insigniaEstado(cita.estado, proxima: proxima),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${cita.servicioNombre} · ${cita.minutos} min · ${dinero(cita.precio)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: C.gris, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(extra, style: const TextStyle(color: C.gris, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantalla de lista simple (Servicios / Barberos)
// ---------------------------------------------------------------------------
class PantallaLista extends StatelessWidget {
  final String titulo;
  final String vacio;
  final VoidCallback onAgregar;
  final List<Widget> hijos;
  const PantallaLista({
    super.key,
    required this.titulo,
    required this.vacio,
    required this.onAgregar,
    required this.hijos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  BotonRedondo(Icons.arrow_back, () => Navigator.pop(context), color: C.texto),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(titulo,
                        style: const TextStyle(
                            color: C.texto, fontSize: 30, fontWeight: FontWeight.w700)),
                  ),
                  BotonRedondo(Icons.add, onAgregar),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: hijos.isEmpty
                    ? Center(child: Text(vacio, style: const TextStyle(color: C.gris)))
                    : ListView(children: hijos),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCatalogo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const ItemCatalogo({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tarjeta(
        onTap: onEditar,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: C.oroSuave, borderRadius: BorderRadius.circular(12)),
              child: Icon(icono, color: C.oro),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          color: C.texto, fontSize: 18, fontWeight: FontWeight.w600)),
                  if (subtitulo.isNotEmpty)
                    Text(subtitulo, style: const TextStyle(color: C.gris, fontSize: 14)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: C.card,
              icon: const Icon(Icons.more_vert, color: C.gris),
              onSelected: (v) => v == 'editar' ? onEditar() : onEliminar(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selector de fecha propio (en español, sin paquetes de localización)
// ---------------------------------------------------------------------------
Future<DateTime?> elegirFecha(BuildContext context, DateTime inicial) =>
    hoja<DateTime>(context, (c) => _Calendario(inicial: inicial));

class _Calendario extends StatefulWidget {
  final DateTime inicial;
  const _Calendario({required this.inicial});
  @override
  State<_Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<_Calendario> {
  late DateTime mes = DateTime(widget.inicial.year, widget.inicial.month);

  @override
  Widget build(BuildContext context) {
    final huecos = mes.weekday - 1;
    final diasMes = DateTime(mes.year, mes.month + 1, 0).day;
    final celdas = <Widget>[
      for (final l in ['L', 'M', 'X', 'J', 'V', 'S', 'D'])
        Center(child: Text(l, style: const TextStyle(color: C.gris))),
      for (var i = 0; i < huecos; i++) const SizedBox.shrink(),
      for (var d = 1; d <= diasMes; d++) _dia(DateTime(mes.year, mes.month, d)),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: C.oro),
              onPressed: () => setState(() => mes = DateTime(mes.year, mes.month - 1)),
            ),
            Expanded(
              child: Text('${cap(nombreMes(mes))} de ${mes.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: C.texto, fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: C.oro),
              onPressed: () => setState(() => mes = DateTime(mes.year, mes.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: celdas,
        ),
      ],
    );
  }

  Widget _dia(DateTime f) {
    final sel = mismoDia(f, widget.inicial);
    final hoy = mismoDia(f, DateTime.now());
    return GestureDetector(
      onTap: () => Navigator.pop(context, f),
      child: Container(
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: sel ? C.oro : null,
          border: hoy && !sel ? Border.all(color: C.oro) : null,
        ),
        child: Text('${f.day}',
            style: TextStyle(
                color: sel ? C.oscuro : C.texto,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}
