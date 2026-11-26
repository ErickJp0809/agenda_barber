import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'tema.dart';
import 'widgets.dart';
import 'nueva_cita_page.dart';
import 'cita_detalle_page.dart';

// ---------------------------------------------------------------------------
// Formulario (crear / editar) reutilizable
// ---------------------------------------------------------------------------
Future<Cliente?> formularioCliente(BuildContext context, {Cliente? cliente}) {
  final nombre = TextEditingController(text: cliente?.nombre ?? '');
  final tel = TextEditingController(text: cliente?.telefono ?? '');
  final llave = GlobalKey<FormState>();

  return hoja<Cliente>(
    context,
    (c) => Form(
      key: llave,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TituloHoja(cliente == null ? 'Nuevo cliente' : 'Editar cliente'),
          TextFormField(
            controller: nombre,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: C.texto),
            decoration: deco('Nombre completo', fill: C.bg),
            validator: (v) =>
                (v == null || v.trim().length < 2) ? 'Escribe el nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: tel,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: C.texto),
            decoration: deco('Teléfono', fill: C.bg),
            validator: (v) {
              final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
              return (d.length < 8 || d.length > 15) ? 'Teléfono no válido' : null;
            },
          ),
          const SizedBox(height: 20),
          BotonOro('Guardar', onPressed: () {
            if (!llave.currentState!.validate()) return;
            final n = Cliente(
              id: cliente?.id ?? store.nuevoId(),
              nombre: nombre.text.trim(),
              telefono: tel.text.trim(),
              visitasPrevias: cliente?.visitasPrevias ?? 0,
              ultimaPrevia: cliente?.ultimaPrevia,
            );
            store.guardarCliente(n);
            Navigator.pop(c, n);
          }),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Selector de cliente (para la nueva cita)
// ---------------------------------------------------------------------------
class SelectorCliente extends StatefulWidget {
  const SelectorCliente({super.key});
  @override
  State<SelectorCliente> createState() => _SelectorClienteState();
}

class _SelectorClienteState extends State<SelectorCliente> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final nq = sinAcentos(q.trim());
    final lista = store.clientes
        .where((c) => nq.isEmpty || sinAcentos(c.nombre).contains(nq) || c.telefono.contains(nq))
        .toList()
      ..sort((a, b) => sinAcentos(a.nombre).compareTo(sinAcentos(b.nombre)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloHoja('Cliente'),
        TextField(
          style: const TextStyle(color: C.texto),
          decoration: deco('Buscar por nombre o teléfono', fill: C.bg, icono: Icons.search),
          onChanged: (v) => setState(() => q = v),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_add_alt_1, color: C.oro),
          title: const Text('Nuevo cliente', style: TextStyle(color: C.oro, fontSize: 17)),
          onTap: () async {
            final n = await formularioCliente(context);
            if (n != null && context.mounted) Navigator.pop(context, n.id);
          },
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final c in lista)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AvatarIniciales(c.nombre, size: 42),
                  title: Text(c.nombre, style: const TextStyle(color: C.texto)),
                  subtitle: Text(c.telefono, style: const TextStyle(color: C.gris)),
                  onTap: () => Navigator.pop(context, c.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pestaña Clientes
// ---------------------------------------------------------------------------
class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});
  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final buscar = TextEditingController();
  int filtro = 0; // 0 todos, 1 habituales, 2 nuevos
  bool asc = true;

  @override
  void dispose() {
    buscar.dispose();
    super.dispose();
  }

  String _ultima(Cliente c) {
    final u = store.ultimaVisita(c);
    final v = store.visitas(c);
    if (u == null || v == 0) return 'Sin visitas aún';
    return 'Última visita: ${u.day} ${mesCorto(u)} · $v ${v == 1 ? 'visita' : 'visitas'}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final q = sinAcentos(buscar.text.trim());
          final qd = buscar.text.replaceAll(RegExp(r'\D'), '');
          final lista = store.clientes.where((c) {
            final v = store.visitas(c);
            if (filtro == 1 && v < 5) return false;
            if (filtro == 2 && v > 2) return false;
            if (q.isEmpty) return true;
            return sinAcentos(c.nombre).contains(q) ||
                (qd.isNotEmpty && c.telefono.replaceAll(RegExp(r'\D'), '').contains(qd));
          }).toList()
            ..sort((a, b) => sinAcentos(a.nombre).compareTo(sinAcentos(b.nombre)));
          if (!asc) lista.setAll(0, lista.reversed.toList());

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Clientes',
                        style: TextStyle(
                            color: C.texto, fontSize: 36, fontWeight: FontWeight.w700)),
                  ),
                  BotonRedondo(Icons.add, () => formularioCliente(context)),
                ],
              ),
              const SizedBox(height: 6),
              Text('${store.clientes.length} clientes. Cada visita cuenta.',
                  style: const TextStyle(color: C.gris, fontSize: 16)),
              const SizedBox(height: 18),
              TextField(
                controller: buscar,
                style: const TextStyle(color: C.texto),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o teléfono',
                  prefixIcon: Icon(Icons.search, color: C.gris),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      ChipFiltro(['Todos', 'Habituales', 'Nuevos'][i],
                          activo: filtro == i, onTap: () => setState(() => filtro = i)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        ['Todos los clientes', 'Clientes habituales', 'Clientes nuevos'][filtro],
                        style: const TextStyle(
                            color: C.texto, fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => asc = !asc),
                    child: Row(
                      children: [
                        Text(asc ? 'A–Z' : 'Z–A',
                            style: const TextStyle(color: C.oro, fontSize: 15)),
                        const SizedBox(width: 4),
                        Icon(asc ? Icons.arrow_downward : Icons.arrow_upward,
                            color: C.oro, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No se encontraron clientes',
                        style: TextStyle(color: C.gris, fontSize: 16)),
                  ),
                )
              else
                Tarjeta(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      for (var i = 0; i < lista.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, indent: 66, endIndent: 10, color: C.borde),
                        _fila(context, lista[i]),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Center(
                child: Text('Mostrando ${lista.length} de ${store.clientes.length} clientes',
                    style: const TextStyle(color: C.gris, fontSize: 14)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fila(BuildContext context, Cliente c) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ClienteDetallePage(clienteId: c.id))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          children: [
            AvatarIniciales(c.nombre, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.nombre,
                      style: const TextStyle(
                          color: C.texto, fontSize: 18, fontWeight: FontWeight.w500)),
                  Text(c.telefono, style: const TextStyle(color: C.gris, fontSize: 15)),
                  Text(_ultima(c), style: const TextStyle(color: C.gris, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: C.gris),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detalle de cliente
// ---------------------------------------------------------------------------
class ClienteDetallePage extends StatelessWidget {
  final String clienteId;
  const ClienteDetallePage({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final c = store.cliente(clienteId);
        if (c == null) return const Scaffold(body: SizedBox.shrink());
        final u = store.ultimaVisita(c);
        final historial = store.citasDeCliente(c.id);

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    BotonRedondo(Icons.arrow_back, () => Navigator.pop(context), color: C.texto),
                    const Spacer(),
                    BotonRedondo(Icons.edit_outlined, () => formularioCliente(context, cliente: c)),
                    const SizedBox(width: 10),
                    BotonRedondo(Icons.delete_outline, () async {
                      final ok = await confirmar(context, 'Eliminar cliente',
                          'Se eliminará a ${c.nombre} y todas sus citas.',
                          si: 'Eliminar');
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                        store.eliminarCliente(c.id);
                      }
                    }, color: C.rojo),
                  ],
                ),
                const SizedBox(height: 20),
                Center(child: AvatarIniciales(c.nombre, size: 84, resaltado: true)),
                const SizedBox(height: 14),
                Center(
                  child: Text(c.nombre,
                      style: const TextStyle(
                          color: C.texto, fontSize: 26, fontWeight: FontWeight.w700)),
                ),
                Center(
                  child: Text(c.telefono,
                      style: const TextStyle(color: C.gris, fontSize: 16)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _dato('${store.visitas(c)}', 'Visitas'),
                    const SizedBox(width: 12),
                    _dato(u == null ? '—' : '${u.day} ${mesCorto(u)}', 'Última visita'),
                  ],
                ),
                const SizedBox(height: 18),
                BotonOro('Nueva cita',
                    icono: Icons.add,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NuevaCitaPage(clienteId: c.id)))),
                const SizedBox(height: 24),
                const Text('Historial de citas',
                    style: TextStyle(
                        color: C.texto, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (historial.isEmpty)
                  const Text('Este cliente aún no tiene citas.',
                      style: TextStyle(color: C.gris)),
                for (final h in historial)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CitaTarjeta(
                      cita: h,
                      mostrarFecha: true,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CitaDetallePage(citaId: h.id))),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dato(String valor, String etiqueta) {
    return Expanded(
      child: Tarjeta(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor,
                style: const TextStyle(
                    color: C.texto, fontSize: 26, fontWeight: FontWeight.w700)),
            Text(etiqueta, style: const TextStyle(color: C.gris, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
