import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mentorias_backend/db/database.dart';
import 'package:mentorias_backend/routes/auth_routes.dart';
import 'package:mentorias_backend/routes/profile_routes.dart';
import 'package:mentorias_backend/routes/match_routes.dart';
import 'package:mentorias_backend/routes/evaluacion_routes.dart';
import 'package:mentorias_backend/routes/chat_routes.dart';
import 'package:mentorias_backend/routes/horarios_routes.dart';

void main() async {
  // Inicializar base de datos
  initDatabase();
  print('[SERVER] Base de datos lista');

  final router = Router();

  // --- Auth ---
  router.post('/api/register', handleRegister);
  router.post('/api/login', handleLogin);

  // --- Perfil ---
  router.get('/api/perfil/<id>', getPerfil);
  router.put('/api/perfil/<id>', updatePerfil);

  // --- Matching ---
  router.get('/api/mentores', buscarMentoresHandler);

  // --- Estudiantes del mentor ---
  router.get('/api/estudiantes/<mentorId>', getEstudiantesMentorHandler);

  // --- Buscar usuarios ---
  router.get('/api/usuarios/buscar', buscarUsuariosHandler);

  // --- Evaluación ---
  router.post('/api/evaluacion', handleEvaluacion);

  // --- Chat historial ---
  router.get('/api/mensajes/<userId1>/<userId2>', handleHistorialChatHandler);

  // --- Horarios de disponibilidad ---
  router.get('/api/horarios/mentor/<id>', handleGetHorariosMentor);
  router.post('/api/horarios', handleCrearHorario);
  router.delete('/api/horarios/<id>', handleEliminarHorario);


  // --- WebSocket para chat en tiempo real ---
  router.get('/ws/chat', (Request request) {
    final userIdStr = request.url.queryParameters['userId'];
    if (userIdStr == null) {
      return Response.badRequest(body: 'userId requerido');
    }
    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      return Response.badRequest(body: 'userId inválido');
    }

    return webSocketHandler((WebSocketChannel webSocket) {
      handleWebSocketConnection(webSocket, userId);
    })(request);
  });

  // Middleware de logging
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, 'localhost', port);
  print('[SERVER] Servidor corriendo en http://${server.address.host}:${server.port}');
  print('[SERVER] Endpoints disponibles:');
  print('  POST /api/register');
  print('  POST /api/login');
  print('  GET  /api/perfil/<id>');
  print('  PUT  /api/perfil/<id>');
  print('  GET  /api/mentores?habilidad=X&nivel=Y');
  print('  POST /api/evaluacion');
  print('  GET  /api/mensajes/<userId1>/<userId2>');
  print('  WS   /ws/chat?userId=X');
}

// Wrappers para compatibilidad de tipos
Future<Response> buscarMentoresHandler(Request request) async {
  return buscarMentores(request);
}

Future<Response> handleHistorialChatHandler(Request request, String userId1, String userId2) async {
  return handleHistorialChat(request, userId1, userId2);
}

Future<Response> getEstudiantesMentorHandler(Request request, String mentorIdStr) async {
  final mentorId = int.tryParse(mentorIdStr);
  if (mentorId == null) {
    return Response.badRequest(body: '{"error": "ID inválido"}', headers: {'Content-Type': 'application/json'});
  }
  final estudiantes = getEstudiantesDeMentor(mentorId);
  final resultado = estudiantes.map((e) => Map<String, dynamic>.from(e)..remove('password')).toList();
  return Response.ok(jsonEncode(resultado), headers: {'Content-Type': 'application/json'});
}

Future<Response> buscarUsuariosHandler(Request request) async {
  final query = request.url.queryParameters['q'];
  if (query == null || query.isEmpty) {
    return Response.badRequest(body: '{"error": "Parámetro q requerido"}', headers: {'Content-Type': 'application/json'});
  }
  final usuarios = buscarUsuarios(query);
  final resultado = usuarios.map((u) => Map<String, dynamic>.from(u)..remove('password')).toList();
  return Response.ok(jsonEncode(resultado), headers: {'Content-Type': 'application/json'});
}

Middleware _corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    };
  };
}
