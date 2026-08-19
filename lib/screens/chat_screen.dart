// Pantalla de chat en tiempo real.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/mensaje.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../widgets/burbuja_chat.dart';
import '../widgets/barra_mensaje_chat.dart';

class ChatScreen extends StatefulWidget {
  // Contacto con el que se está conversando.
  final Usuario contacto;

  const ChatScreen({super.key, required this.contacto});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ─── Servicios ─────────────────────────────────

  // Servicio de chat que maneja la conexión WebSocket.
  final ChatService _chatService = ChatService();

  // ─── Controladores ─────────────────────────────

  // Controlador del campo de texto del mensaje.
  final _mensajeController = TextEditingController();

  // Controlador del scroll de la lista de mensajes.
  final _scrollController = ScrollController();

  // ─── Estado ────────────────────────────────────

  // Lista de mensajes de la conversación.
  List<Mensaje> _mensajes = [];

  // Indica si se está cargando el historial por primera vez.
  bool _cargando = true;

  // Suscripción al stream de mensajes del WebSocket.
  StreamSubscription? _suscripcionMensajes;

  // ══════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ══════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
    _conectarWebSocket();
  }

  @override
  void dispose() {
    _suscripcionMensajes?.cancel();
    _chatService.dispose();
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════
  //  LÓGICA
  // ══════════════════════════════════════════════════

  // Carga el historial de mensajes desde el backend.

  // Obtiene todos los mensajes intercambiados entre el usuario actual y el contacto, y desplaza el scroll al final.
  Future<void> _cargarHistorial() async {
    try {
      final miId = ApiService.usuarioActual!.id;
      final data = await ApiService.getMensajes(miId, widget.contacto.id);
      setState(() {
        _mensajes = data.map((m) => Mensaje.fromJson(m)).toList();
        _cargando = false;
      });
      _desplazarAlFinal();
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  // Conecta al WebSocket y escucha mensajes entrantes.

  // Solo procesa mensajes que involucren al contacto actual (como emisor o receptor).
  void _conectarWebSocket() {
    final miId = ApiService.usuarioActual!.id;
    _chatService.conectar(miId);

    _suscripcionMensajes = _chatService.mensajesStream.listen((mensaje) {
      final involucraContacto = mensaje.emisorId == widget.contacto.id ||
          mensaje.receptorId == widget.contacto.id;

      if (involucraContacto) {
        setState(() => _mensajes.add(mensaje));
        _desplazarAlFinal();
      }
    });
  }

  /// Envía un mensaje al contacto actual.
  ///
  /// Valida que el texto no esté vacío antes de enviar.
  /// Limpia el campo de texto después del envío.
  void _enviarMensaje() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    _chatService.enviarMensaje(widget.contacto.id, texto);
    _mensajeController.clear();
  }

  /// Desplaza la lista de mensajes al final (último mensaje).
  void _desplazarAlFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final miId = ApiService.usuarioActual!.id;

    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: _buildAppBar(),

      // ─── Cuerpo ───────────────────────────────
      body: Column(
        children: [
          // ─── Lista de mensajes ─────────────────
          Expanded(child: _buildListaMensajes(miId)),

          // ─── Barra de envío ────────────────────
          BarraMensajeChat(
            controlador: _mensajeController,
            onEnviar: _enviarMensaje,
          ),
        ],
      ),
    );
  }

  /// Barra superior con el nombre y rol del contacto.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.contacto.nombre),
          Text(
            widget.contacto.rol,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Lista de mensajes o indicador de carga.
  Widget _buildListaMensajes(int miId) {
    // Estado: cargando historial
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado: lista de mensajes
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _mensajes.length,
      itemBuilder: (context, index) {
        final mensaje = _mensajes[index];
        final esMio = mensaje.emisorId == miId;

        return BurbujaChat(
          contenido: mensaje.contenido,
          esMio: esMio,
        );
      },
    );
  }
}