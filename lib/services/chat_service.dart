import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/mensaje.dart';

class ChatService {
  WebSocketChannel? _channel;
  final StreamController<Mensaje> _mensajesController = StreamController<Mensaje>.broadcast();

  Stream<Mensaje> get mensajesStream => _mensajesController.stream;

  void conectar(int userId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws/chat?userId=$userId'),
    );

    _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          final mensaje = Mensaje.fromJson(json);
          _mensajesController.add(mensaje);
        } catch (e) {
          print('[ChatService] Error parseando mensaje: $e');
        }
      },
      onDone: () {
        print('[ChatService] Conexión cerrada');
      },
      onError: (error) {
        print('[ChatService] Error: $error');
      },
    );
  }

  void enviarMensaje(int receptorId, String contenido) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'receptor_id': receptorId,
      'contenido': contenido,
    }));
  }

  void desconectar() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    desconectar();
    _mensajesController.close();
  }
}
