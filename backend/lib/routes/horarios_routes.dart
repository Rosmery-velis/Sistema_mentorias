import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db/database.dart';

// GET /api/horarios/mentor/<id>
Future<Response> handleGetHorariosMentor(Request request, String id) async {
  final mentorId = int.tryParse(id);
  if (mentorId == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'ID inválido'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
  final horarios = getHorariosByMentor(mentorId);
  return Response.ok(
    jsonEncode(horarios),
    headers: {'Content-Type': 'application/json'},
  );
}

// POST /api/horarios
Future<Response> handleCrearHorario(Request request) async {
  final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
  final mentorId = body['mentor_id'] as int?;
  final diaSemana = body['dia_semana'] as String?;
  final horaInicio = body['hora_inicio'] as String?;
  final horaFin = body['hora_fin'] as String?;

  if (mentorId == null || diaSemana == null || horaInicio == null || horaFin == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Faltan campos: mentor_id, dia_semana, hora_inicio, hora_fin'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final diasValidos = ['lunes','martes','miercoles','jueves','viernes','sabado','domingo'];
  if (!diasValidos.contains(diaSemana)) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Día inválido. Usa: ${diasValidos.join(", ")}'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final id = insertHorario(mentorId, diaSemana, horaInicio, horaFin);
  return Response.ok(
    jsonEncode({'mensaje': 'Horario creado exitosamente', 'id': id}),
    headers: {'Content-Type': 'application/json'},
  );
}

// DELETE /api/horarios/<id>
Future<Response> handleEliminarHorario(Request request, String id) async {
  final horarioId = int.tryParse(id);
  if (horarioId == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'ID inválido'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  deleteHorario(horarioId);
  return Response.ok(
    jsonEncode({'mensaje': 'Horario eliminado'}),
    headers: {'Content-Type': 'application/json'},
  );
}