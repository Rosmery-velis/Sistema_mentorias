import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db/database.dart';

Future<Response> handleEvaluacion(Request request) async {
  final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
  final mentorId = body['mentor_id'] as int?;
  final estudianteId = body['estudiante_id'] as int?;
  final resultado = body['resultado'] as String?;

  if (mentorId == null || estudianteId == null || resultado == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Campos requeridos: mentor_id, estudiante_id, resultado'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  if (resultado != 'aprobado' && resultado != 'reprobado') {
    return Response.badRequest(
      body: jsonEncode({'error': 'Resultado debe ser "aprobado" o "reprobado"'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final mentor = getUsuarioById(mentorId);
  if (mentor == null || mentor['rol'] != 'mentor') {
    return Response.badRequest(
      body: jsonEncode({'error': 'Mentor no válido'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final estudiante = getUsuarioById(estudianteId);
  if (estudiante == null || estudiante['rol'] != 'estudiante') {
    return Response.badRequest(
      body: jsonEncode({'error': 'Estudiante no válido'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final id = insertEvaluacion(mentorId, estudianteId, resultado);
  final estudianteActualizado = getUsuarioById(estudianteId)!;

  return Response.ok(
    jsonEncode({
      'mensaje': resultado == 'aprobado'
          ? 'Estudiante aprobado. Nivel subido a ${estudianteActualizado['nivel']}'
          : 'Estudiante reprobado. Debe seguir practicando.',
      'evaluacion_id': id,
      'nivel_actual': estudianteActualizado['nivel'],
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
