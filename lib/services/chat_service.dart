import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/mensaje.dart';

class ChatService {
  // ════ SINGLETON ════
  // Una sola instancia viva durante toda la app.
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // ════ ESTADO ════
  WebSocketChannel? _channel;
  final StreamController<Mensaje> _mensajesController =
      StreamController<Mensaje>.broadcast();

  // Set para deduplicación 
  final Set<int> _idsVistos = {};

  int? _userIdActual;
  bool _conectado = false;

  // ════ GETTERS ════
  Stream<Mensaje> get mensajesStream => _mensajesController.stream;
  bool get estaConectado => _conectado;
  int? get userIdActual => _userIdActual;

  // ════ CONEXIÓN ════
  void conectar(int userId) {
    // Ya conectado como este usuario → reutilizar
    if (_conectado && _userIdActual == userId) return;

    desconectar();
    _userIdActual = userId;

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws/chat?userId=$userId'),
    );

    _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          final mensaje = Mensaje.fromJson(json);

          // Deduplicación: si ya vimos este ID, ignorar
          if (mensaje.id != null && _idsVistos.contains(mensaje.id)) return;
          if (mensaje.id != null) _idsVistos.add(mensaje.id!);

          _mensajesController.add(mensaje);
        } catch (e) {
          print('[ChatService] Error parseando: $e');
        }
      },
      onDone: () {
        _conectado = false;
        print('[ChatService] Conexión cerrada');
      },
      onError: (error) {
        _conectado = false;
        print('[ChatService] Error: $error');
      },
    );

    _conectado = true;
    print('[ChatService] Conectado como usuario $userId');
  }

  // ════ ENVÍO ════
  void enviarMensaje(int receptorId, String contenido) {
    if (_channel == null || !_conectado) return;
    _channel!.sink.add(jsonEncode({
      'receptor_id': receptorId,
      'contenido': contenido,
    }));
  }

  // ════ DESCONEXIÓN ════
  // Solo cierra el WebSocket. NO cierra el stream controller porque es singleton y debe seguir vivo.
  void desconectar() {
    _channel?.sink.close();
    _channel = null;
    _conectado = false;
    _userIdActual = null;
    _idsVistos.clear();
  }
}