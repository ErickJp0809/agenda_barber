import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'tema.dart';

/// Instancia única de los datos de la app.
/// Sin servidor ni base de datos: todo se guarda en el dispositivo
/// con shared_preferences (JSON), así los datos sobreviven al cerrar la app.
final store = AppStore();

T? _buscar<T>(List<T> lista, bool Function(T) f) {
  for (final e in lista) {
    if (f(e)) return e;
  }
  return null;
}

class AppStore extends ChangeNotifier {
  static const _clave = 'agenda_barber_datos_v1';

  List<Barbero> barberos = [];
  List<Servicio> servicios = [];
  List<Cliente> clientes = [];
  List<Cita> citas = [];

  int _contador = 0;
  String nuevoId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_contador++}';

  // ------------------------------------------------------------------ carga
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clave);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        List<T> lee<T>(String k, T Function(Map<String, dynamic>) f) =>
            (m[k] as List).map((e) => f(e as Map<String, dynamic>)).toList();
        barberos = lee('barberos', Barbero.fromJson);
        servicios = lee('servicios', Servicio.fromJson);
        clientes = lee('clientes', Cliente.fromJson);
        citas = lee('citas', Cita.fromJson);
        return;
      } catch (e) {
        debugPrint('Datos dañados, se reinician: $e');
      }
    }
    _sembrar();
    await _guardar();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _clave,
      jsonEncode({
        'barberos': barberos.map((e) => e.toJson()).toList(),
        'servicios': servicios.map((e) => e.toJson()).toList(),
        'clientes': clientes.map((e) => e.toJson()).toList(),
        'citas': citas.map((e) => e.toJson()).toList(),
      }),
    );
  }

  void _cambio() {
    notifyListeners();
    _guardar();
  }

  /// Datos de ejemplo (primer arranque) basados en el diseño de Figma.
  void _sembrar() {
    final ahora = DateTime.now();
    barberos = [
      Barbero(id: 'b1', nombre: 'Erick Juarez'),
      Barbero(id: 'b2', nombre: 'Josue Perez'),
    ];
    servicios = [
      Servicio(id: 's1', nombre: 'Corte clásico', minutos: 30, precio: 150),
      Servicio(id: 's2', nombre: 'Degradado', minutos: 30, precio: 200),
      Servicio(id: 's3', nombre: 'Corte + barba', minutos: 45, precio: 250),
      Servicio(id: 's4', nombre: 'Barba', minutos: 30, precio: 100),
    ];
    DateTime hace(int d) => soloDia(sumarDias(ahora, -d));
    clientes = [
      Cliente(id: 'c1', nombre: 'Álvaro Torres', telefono: '+34 621 308 745', visitasPrevias: 6, ultimaPrevia: hace(6)),
      Cliente(id: 'c2', nombre: 'Daniel Romero', telefono: '+34 612 458 903', visitasPrevias: 3, ultimaPrevia: hace(14)),
      Cliente(id: 'c3', nombre: 'Javier Martín', telefono: '+34 645 902 186', visitasPrevias: 12, ultimaPrevia: hace(13)),
      Cliente(id: 'c4', nombre: 'Marcos López', telefono: '+34 633 719 402', visitasPrevias: 8, ultimaPrevia: hace(12)),
      Cliente(id: 'c5', nombre: 'Pablo García', telefono: '+34 679 214 508', visitasPrevias: 2, ultimaPrevia: hace(18)),
      Cliente(id: 'c6', nombre: 'Sergio Navarro', telefono: '+34 607 835 291', visitasPrevias: 5, ultimaPrevia: hace(5)),
      Cliente(id: 'c7', nombre: 'Juan Perez', telefono: '+34 655 100 200'),
    ];

    // Primera cita: el siguiente horario cerrado (si ya es tarde, mañana).
    var t = DateTime(ahora.year, ahora.month, ahora.day, ahora.hour)
        .add(Duration(minutes: ahora.minute < 30 ? 30 : 60));
    if (t.hour < 9) t = DateTime(ahora.year, ahora.month, ahora.day, 9);
    if (t.hour >= 18) t = DateTime(ahora.year, ahora.month, ahora.day + 1, 10);
    DateTime mas(int m) => t.add(Duration(minutes: m));

    Cita c(String id, String cli, String srv, String bar, DateTime ini, Estado e) {
      final s = servicios.firstWhere((x) => x.id == srv);
      return Cita(
        id: id, clienteId: cli, servicioId: s.id, servicioNombre: s.nombre,
        barberoId: bar, inicio: ini, minutos: s.minutos, precio: s.precio,
        estado: e, recordatorio: true,
      );
    }

    citas = [
      c('a1', 'c4', 's3', 'b1', t, Estado.pendiente),
      c('a2', 'c3', 's1', 'b1', mas(60), Estado.confirmada),
      c('a3', 'c1', 's2', 'b2', mas(90), Estado.confirmada),
      c('a4', 'c5', 's3', 'b1', mas(120), Estado.pendiente),
      c('a5', 'c6', 's1', 'b2', mas(240), Estado.confirmada),
      c('a6', 'c7', 's3', 'b1', mas(24 * 60 + 30), Estado.pendiente),
    ];
  }

  // ---------------------------------------------------------------- consultas
  Cliente? cliente(String id) => _buscar(clientes, (e) => e.id == id);
  Servicio? servicio(String id) => _buscar(servicios, (e) => e.id == id);
  Barbero? barbero(String id) => _buscar(barberos, (e) => e.id == id);
  Cita? cita(String id) => _buscar(citas, (e) => e.id == id);

  List<Cita> citasDelDia(DateTime d, {String? barberoId, Estado? estado}) {
    final l = citas
        .where((c) =>
            mismoDia(c.inicio, d) &&
            (barberoId == null || c.barberoId == barberoId) &&
            (estado == null || c.estado == estado))
        .toList();
    l.sort((a, b) => a.inicio.compareTo(b.inicio));
    return l;
  }

  List<Cita> citasDeCliente(String clienteId) {
    final l = citas.where((c) => c.clienteId == clienteId).toList();
    l.sort((a, b) => b.inicio.compareTo(a.inicio));
    return l;
  }

  Cita? siguienteCita(DateTime ahora) {
    for (final c in citasDelDia(ahora)) {
      final activa =
          c.estado == Estado.pendiente || c.estado == Estado.confirmada;
      if (activa && c.fin.isAfter(ahora)) return c;
    }
    return null;
  }

  bool haySolape(String barberoId, DateTime inicio, int minutos,
      {String? excluirId}) {
    final fin = inicio.add(Duration(minutes: minutos));
    return citas.any((c) =>
        c.id != excluirId &&
        c.barberoId == barberoId &&
        c.estado != Estado.cancelada &&
        inicio.isBefore(c.fin) &&
        fin.isAfter(c.inicio));
  }

  int visitas(Cliente c) =>
      c.visitasPrevias +
      citas.where((x) => x.clienteId == c.id && x.estado == Estado.completada).length;

  DateTime? ultimaVisita(Cliente c) {
    var u = c.ultimaPrevia;
    for (final x in citas) {
      if (x.clienteId == c.id &&
          x.estado == Estado.completada &&
          (u == null || x.inicio.isAfter(u))) {
        u = x.inicio;
      }
    }
    return u;
  }

  // ---------------------------------------------------------------- acciones
  void guardarCita(Cita c) {
    final i = citas.indexWhere((e) => e.id == c.id);
    if (i == -1) {
      citas.add(c);
    } else {
      citas[i] = c;
    }
    _cambio();
  }

  void cambiarEstado(Cita c, Estado e) {
    c.estado = e;
    _cambio();
  }

  void eliminarCita(String id) {
    citas.removeWhere((e) => e.id == id);
    _cambio();
  }

  void guardarCliente(Cliente c) {
    final i = clientes.indexWhere((e) => e.id == c.id);
    if (i == -1) {
      clientes.add(c);
    } else {
      clientes[i] = c;
    }
    _cambio();
  }

  void eliminarCliente(String id) {
    clientes.removeWhere((e) => e.id == id);
    citas.removeWhere((e) => e.clienteId == id);
    _cambio();
  }

  void guardarServicio(Servicio s) {
    final i = servicios.indexWhere((e) => e.id == s.id);
    if (i == -1) {
      servicios.add(s);
    } else {
      servicios[i] = s;
    }
    _cambio();
  }

  /// Devuelve false si el servicio tiene citas asociadas.
  bool eliminarServicio(String id) {
    if (citas.any((c) => c.servicioId == id)) return false;
    servicios.removeWhere((e) => e.id == id);
    _cambio();
    return true;
  }

  void guardarBarbero(Barbero b) {
    final i = barberos.indexWhere((e) => e.id == b.id);
    if (i == -1) {
      barberos.add(b);
    } else {
      barberos[i] = b;
    }
    _cambio();
  }

  bool eliminarBarbero(String id) {
    if (citas.any((c) => c.barberoId == id)) return false;
    barberos.removeWhere((e) => e.id == id);
    _cambio();
    return true;
  }
}
