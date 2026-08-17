import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:crypto/crypto.dart';
import '../db/database.dart';

String _hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

Future<Response> handleRegister(Request request) async {
  final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
  final nombre = body['nombre'] as String?;
  final correo = body['correo'] as String?;
  final password = body['password'] as String?;
  final rol = body['rol'] as String?;

  if (nombre == null || correo == null || password == null || rol == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Faltan campos requeridos: nombre, correo, password, rol'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  if (rol != 'estudiante' && rol != 'mentor') {
    return Response.badRequest(
      body: jsonEncode({'error': 'Rol debe ser "estudiante" o "mentor"'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  if (getUsuarioByCorreo(correo) != null) {
    return Response(409,
      body: jsonEncode({'error': 'El correo ya está registrado'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final hash = _hashPassword(password);
  final id = insertUsuario(nombre, correo, hash, rol);
  final usuario = getUsuarioById(id);

  return Response.ok(
    jsonEncode({'mensaje': 'Usuario registrado exitosamente', 'usuario': usuario}),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> handleLogin(Request request) async {
  final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
  final correo = body['correo'] as String?;
  final password = body['password'] as String?;

  if (correo == null || password == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Faltan campos: correo, password'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final usuario = getUsuarioByCorreo(correo);
  if (usuario == null) {
    return Response(401,
      body: jsonEncode({'error': 'Credenciales inválidas'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final hash = _hashPassword(password);
  if (usuario['password'] != hash) {
    return Response(401,
      body: jsonEncode({'error': 'Credenciales inválidas'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // No devolver el password
  final usuarioSinPassword = Map<String, dynamic>.from(usuario)..remove('password');

  return Response.ok(
    jsonEncode({'mensaje': 'Login exitoso', 'usuario': usuarioSinPassword}),
    headers: {'Content-Type': 'application/json'},
  );
}
