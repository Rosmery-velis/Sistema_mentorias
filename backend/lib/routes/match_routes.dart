import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db/database.dart';

Response buscarMentores(Request request) {
  final habilidad = request.url.queryParameters['habilidad'];
  final nivelStr = request.url.queryParameters['nivel'];

  if (habilidad == null || nivelStr == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Parámetros requeridos: habilidad, nivel'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final nivel = int.tryParse(nivelStr);
  if (nivel == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Nivel debe ser un número'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final mentores = buscarMentoresDB(habilidad, nivel);
  // No devolver passwords
  final resultado = mentores.map((m) {
    final sinPassword = Map<String, dynamic>.from(m)..remove('password');
    return sinPassword;
  }).toList();

  return Response.ok(
    jsonEncode(resultado),
    headers: {'Content-Type': 'application/json'},
  );
}
