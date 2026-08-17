import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../db/database.dart';

// Mapa de userId -> WebSocket conectados
final Map<int, WebSocketChannel> _connectedUsers = {};

Response handleHistorialChat(Request request, String userId1Str, String userId2Str) {
  final userId1 = int.tryParse(userId1Str);
  final userId2 = int.tryParse(userId2Str);

  if (userId1 == null || userId2 == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'IDs inválidos'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final mensajes = getMensajes(userId1, userId2);
  return Response.ok(
    jsonEncode(mensajes),
    headers: {'Content-Type': 'application/json'},
  );
}

void handleWebSocketConnection(WebSocketChannel webSocket, int userId) {
  _connectedUsers[userId] = webSocket;
  print('[WS] Usuario $userId conectado. Total: ${_connectedUsers.length}');

  webSocket.stream.listen(
    (message) {
      try {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        final receptorId = data['receptor_id'] as int?;
        final contenido = data['contenido'] as String?;

        if (receptorId == null || contenido == null) return;

        // Guardar en BD
        final msgId = insertMensaje(userId, receptorId, contenido);

        // Enviar al receptor si está conectado
        final receptorWs = _connectedUsers[receptorId];
        if (receptorWs != null) {
          receptorWs.sink.add(jsonEncode({
            'id': msgId,
            'emisor_id': userId,
            'receptor_id': receptorId,
            'contenido': contenido,
            'fecha': DateTime.now().toIso8601String(),
          }));
        }

        // Confirmar al emisor
        webSocket.sink.add(jsonEncode({
          'id': msgId,
          'emisor_id': userId,
          'receptor_id': receptorId,
          'contenido': contenido,
          'fecha': DateTime.now().toIso8601String(),
          'enviado': true,
        }));
      } catch (e) {
        print('[WS] Error procesando mensaje: $e');
      }
    },
    onDone: () {
      _connectedUsers.remove(userId);
      print('[WS] Usuario $userId desconectado. Total: ${_connectedUsers.length}');
    },
    onError: (error) {
      _connectedUsers.remove(userId);
      print('[WS] Error usuario $userId: $error');
    },
  );
}
