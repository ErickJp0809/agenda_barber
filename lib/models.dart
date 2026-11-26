enum Estado { pendiente, confirmada, completada, cancelada }

extension EstadoTexto on Estado {
  String get texto =>
      const ['Pendiente', 'Confirmada', 'Completada', 'Cancelada'][index];
}

class Barbero {
  final String id;
  String nombre;
  Barbero({required this.id, required this.nombre});

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre};
  factory Barbero.fromJson(Map<String, dynamic> j) =>
      Barbero(id: j['id'] as String, nombre: j['nombre'] as String);
}

class Servicio {
  final String id;
  String nombre;
  int minutos;
  int precio;
  Servicio({
    required this.id,
    required this.nombre,
    required this.minutos,
    required this.precio,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'nombre': nombre, 'minutos': minutos, 'precio': precio};
  factory Servicio.fromJson(Map<String, dynamic> j) => Servicio(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        minutos: j['minutos'] as int,
        precio: j['precio'] as int,
      );
}

class Cliente {
  final String id;
  String nombre;
  String telefono;
  int visitasPrevias; // visitas anteriores al uso de la app
  DateTime? ultimaPrevia;
  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.visitasPrevias = 0,
    this.ultimaPrevia,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        'visitasPrevias': visitasPrevias,
        'ultimaPrevia': ultimaPrevia?.toIso8601String(),
      };
  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        telefono: j['telefono'] as String,
        visitasPrevias: j['visitasPrevias'] as int,
        ultimaPrevia: j['ultimaPrevia'] == null
            ? null
            : DateTime.parse(j['ultimaPrevia'] as String),
      );
}

class Cita {
  final String id;
  String clienteId;
  String servicioId;
  String servicioNombre;
  String barberoId;
  DateTime inicio;
  int minutos;
  int precio;
  Estado estado;
  bool recordatorio;

  Cita({
    required this.id,
    required this.clienteId,
    required this.servicioId,
    required this.servicioNombre,
    required this.barberoId,
    required this.inicio,
    required this.minutos,
    required this.precio,
    this.estado = Estado.pendiente,
    this.recordatorio = false,
  });

  DateTime get fin => inicio.add(Duration(minutes: minutos));

  Map<String, dynamic> toJson() => {
        'id': id,
        'clienteId': clienteId,
        'servicioId': servicioId,
        'servicioNombre': servicioNombre,
        'barberoId': barberoId,
        'inicio': inicio.toIso8601String(),
        'minutos': minutos,
        'precio': precio,
        'estado': estado.index,
        'recordatorio': recordatorio,
      };
  factory Cita.fromJson(Map<String, dynamic> j) => Cita(
        id: j['id'] as String,
        clienteId: j['clienteId'] as String,
        servicioId: j['servicioId'] as String,
        servicioNombre: j['servicioNombre'] as String,
        barberoId: j['barberoId'] as String,
        inicio: DateTime.parse(j['inicio'] as String),
        minutos: j['minutos'] as int,
        precio: j['precio'] as int,
        estado: Estado.values[j['estado'] as int],
        recordatorio: j['recordatorio'] as bool,
      );
}
