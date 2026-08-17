import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../db/database.dart';

Future<Response> getPerfil(Request request, String idStr) async {
  final id = int.tryParse(idStr);
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'ID inválido'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final usuario = getUsuarioById(id);
  if (usuario == null) {
    return Response.notFound(
      jsonEncode({'error': 'Usuario no encontrado'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final usuarioSinPassword = Map<String, dynamic>.from(usuario)..remove('password');
  return Response.ok(
    jsonEncode(usuarioSinPassword),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> updatePerfil(Request request, String idStr) async {
  final id = int.tryParse(idStr);
  if (id == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'ID inválido'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final usuario = getUsuarioById(id);
  if (usuario == null) {
    return Response.notFound(
      jsonEncode({'error': 'Usuario no encontrado'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
  updateUsuario(id, body);

  final actualizado = getUsuarioById(id)!;
  final sinPassword = Map<String, dynamic>.from(actualizado)..remove('password');

  return Response.ok(
    jsonEncode({'mensaje': 'Perfil actualizado', 'usuario': sinPassword}),
    headers: {'Content-Type': 'application/json'},
  );
}
