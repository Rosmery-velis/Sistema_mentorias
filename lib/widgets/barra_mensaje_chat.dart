// Barra de entrada de texto para el chat.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';

class BarraMensajeChat extends StatelessWidget {
  // Controlador del campo de texto del mensaje.
  final TextEditingController controlador;

  // Función que se ejecuta al presionar el botón de enviar o al presionar Enter en el campo de texto.
  final VoidCallback onEnviar;

  const BarraMensajeChat({
    super.key,
    required this.controlador,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        boxShadow: [
          BoxShadow(
            color: ColoresApp.divisor,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Campo de texto
          Expanded(
            child: TextField(
              controller: controlador,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onEnviar(),
            ),
          ),
          const SizedBox(width: 8),

          // Botón de enviar
          IconButton(
            onPressed: onEnviar,
            icon: const Icon(Icons.send, color: ColoresApp.primario),
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}