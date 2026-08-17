import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/horario.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static Usuario? usuarioActual;

  // --- Auth ---
  static Future<Usuario> register(String nombre, String correo, String password, String rol) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'password': password,
        'rol': rol,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error en registro');
    }

    final usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    usuarioActual = usuario;
    return usuario;
  }

  static Future<Usuario> login(String correo, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error en login');
    }

    final usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    usuarioActual = usuario;
    return usuario;
  }

  // --- Perfil ---
  static Future<Usuario> getPerfil(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/perfil/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error al obtener perfil');
    }

    return Usuario.fromJson(data);
  }

  static Future<Usuario> updatePerfil(int id, Map<String, dynamic> campos) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/perfil/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(campos),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error al actualizar perfil');
    }

    final usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    if (usuarioActual?.id == id) {
      usuarioActual = usuario;
    }
    return usuario;
  }

  // --- Matching ---
  static Future<List<Usuario>> buscarMentores(String habilidad, int nivel) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mentores?habilidad=$habilidad&nivel=$nivel'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al buscar mentores');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Evaluación ---
  static Future<Map<String, dynamic>> evaluarEstudiante(
      int mentorId, int estudianteId, String resultado) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/evaluacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mentor_id': mentorId,
        'estudiante_id': estudianteId,
        'resultado': resultado,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error en evaluación');
    }

    return data;
  }

  // --- Mensajes ---
  static Future<List<Map<String, dynamic>>> getMensajes(int userId1, int userId2) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mensajes/$userId1/$userId2'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener mensajes');
    }

    final data = jsonDecode(response.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // --- Estudiantes del mentor ---
  static Future<List<Usuario>> getEstudiantesDeMentor(int mentorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/estudiantes/$mentorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener estudiantes');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Buscar usuarios ---
  static Future<List<Usuario>> buscarUsuarios(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/usuarios/buscar?q=$query'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al buscar usuarios');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Horarios ---
  static Future<List<Horario>> getHorariosDeMentor(int mentorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/horarios/mentor/$mentorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener horarios');
    }

    final data = jsonDecode(response.body) as List;
    return data.map((e) => Horario.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> crearHorario(int mentorId, String dia, String inicio, String fin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/horarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mentor_id': mentorId,
        'dia_semana': dia,
        'hora_inicio': inicio,
        'hora_fin': fin,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Error al crear horario');
    }
  }

  static Future<void> eliminarHorario(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/horarios/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar horario');
    }
  }
}
