import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/mensaje.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final Usuario contacto;

  const ChatScreen({super.key, required this.contacto});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Mensaje> _mensajes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
    _conectarWebSocket();
  }

  Future<void> _cargarHistorial() async {
    try {
      final userId = ApiService.usuarioActual!.id;
      final data = await ApiService.getMensajes(userId, widget.contacto.id);
      setState(() {
        _mensajes = data.map((m) => Mensaje.fromJson(m)).toList();
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _conectarWebSocket() {
    final userId = ApiService.usuarioActual!.id;
    _chatService.conectar(userId);

    _chatService.mensajesStream.listen((mensaje) {
      if (mensaje.emisorId == widget.contacto.id ||
          mensaje.receptorId == widget.contacto.id) {
        setState(() => _mensajes.add(mensaje));
        _scrollToBottom();
      }
    });
  }

  void _enviar() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    _chatService.enviarMensaje(widget.contacto.id, texto);
    _mensajeController.clear();
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    final miId = ApiService.usuarioActual!.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contacto.nombre),
            Text(widget.contacto.rol, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = _mensajes[index];
                      final esMio = msg.emisorId == miId;

                      return Align(
                        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: esMio ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(msg.contenido, style: const TextStyle(fontSize: 15)),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _enviar,
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  iconSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
