
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  // DIRECCION DE LA API
  final String url =
      'https://jsonplaceholder.typicode.com/posts';

  // READ - CONSULTAR REGISTROS
  Future<List<dynamic>> obtenerServicios() async {

    final respuesta = await http.get(Uri.parse(url));

    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    } else {
      throw Exception('Error al consultar los servicios');
    }
  }

  // CREATE - CREAR REGISTRO
  Future<Map<String, dynamic>> crearServicio(
      String nombre, String descripcion) async {

    final respuesta = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': nombre,
        'body': descripcion,
        'userId': 1,
      }),
    );

    if (respuesta.statusCode == 201) {
      return jsonDecode(respuesta.body);
    } else {
      throw Exception('Error al crear el servicio');
    }
  }

  // UPDATE - ACTUALIZAR REGISTRO
  Future<Map<String, dynamic>> actualizarServicio(
      int id, String nombre, String descripcion) async {

    final respuesta = await http.put(
      Uri.parse('$url/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'title': nombre,
        'body': descripcion,
        'userId': 1,
      }),
    );

    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    } else {
      throw Exception('Error al actualizar el servicio');
    }
  }

  // DELETE - ELIMINAR REGISTRO
  Future<bool> eliminarServicio(int id) async {

    final respuesta = await http.delete(
      Uri.parse('$url/$id'),
    );

    if (respuesta.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al eliminar el servicio');
    }
  }
}
