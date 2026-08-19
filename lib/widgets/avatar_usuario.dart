// Avatar circular reutilizable para mostrar usuarios.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';

class AvatarUsuario extends StatelessWidget {
  // Rol del usuario ('mentor' o 'estudiante').
  // Determina el color de fondo del avatar.
  final String rol;

  // Texto opcional que se muestra en lugar del ícono.
  // Si se proporciona, se ignora [icono].
  final String? texto;

  // Ícono opcional que se muestra dentro del avatar.
  // Si ni [texto] ni [icono] se proporcionan, se usa un ícono
  // por defecto según el [rol].
  final IconData? icono;

  // Tamaño del avatar. Por defecto es 40.
  final double tamano;

  const AvatarUsuario({
    super.key,
    required this.rol,
    this.texto,
    this.icono,
    this.tamano = 20,
  });

  /// Retorna el color de fondo según el rol.
  Color get _colorFondo {
    return rol == 'mentor' ? ColoresApp.advertencia : ColoresApp.primario;
  }

  /// Retorna el ícono a mostrar si no se proporcionó texto.
  IconData get _iconoDefault {
    return rol == 'mentor' ? Icons.person : Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: _colorFondo,
      radius: tamano,
      child: texto != null
          ? Text(
              texto!,
              style: const TextStyle(
                color: ColoresApp.textoSobrePrimario,
                fontWeight: FontWeight.bold,
              ),
            )
          : Icon(icono ?? _iconoDefault, color: ColoresApp.textoSobrePrimario),
    );
  }
}
