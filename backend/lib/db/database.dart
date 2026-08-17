import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;

late final Database db;

void initDatabase() {
  final dbPath = p.join(Directory.current.path, 'mentorias.db');
  db = sqlite3.open(dbPath);

  db.execute('''
    CREATE TABLE IF NOT EXISTS usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      correo TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      rol TEXT NOT NULL CHECK(rol IN ('estudiante', 'mentor')),
      habilidades_aprender TEXT DEFAULT '',
      habilidades_ensenar TEXT DEFAULT '',
      objetivos TEXT DEFAULT '',
      experiencia TEXT DEFAULT '',
      nivel INTEGER DEFAULT 1,
      nivel_ensenar INTEGER DEFAULT 1
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS mensajes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      emisor_id INTEGER NOT NULL,
      receptor_id INTEGER NOT NULL,
      contenido TEXT NOT NULL,
      fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (emisor_id) REFERENCES usuarios(id),
      FOREIGN KEY (receptor_id) REFERENCES usuarios(id)
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS evaluaciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mentor_id INTEGER NOT NULL,
      estudiante_id INTEGER NOT NULL,
      resultado TEXT NOT NULL CHECK(resultado IN ('aprobado', 'reprobado')),
      fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (mentor_id) REFERENCES usuarios(id),
      FOREIGN KEY (estudiante_id) REFERENCES usuarios(id)
    )
  ''');

  db.execute('''
  CREATE TABLE IF NOT EXISTS horarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mentor_id INTEGER NOT NULL,
    dia_semana TEXT NOT NULL CHECK(dia_semana IN ('lunes','martes','miercoles','jueves','viernes','sabado','domingo')),
    hora_inicio TEXT NOT NULL,
    hora_fin TEXT NOT NULL,
    FOREIGN KEY (mentor_id) REFERENCES usuarios(id)
  )
  ''');

  print('[DB] Base de datos inicializada en: $dbPath');
}

// --- Helpers para usuarios ---

Map<String, dynamic>? getUsuarioById(int id) {
  final result = db.select('SELECT * FROM usuarios WHERE id = ?', [id]);
  return result.isEmpty ? null : result.first;
}

Map<String, dynamic>? getUsuarioByCorreo(String correo) {
  final result = db.select('SELECT * FROM usuarios WHERE correo = ?', [correo]);
  return result.isEmpty ? null : result.first;
}

int insertUsuario(String nombre, String correo, String passwordHash, String rol) {
  db.execute(
    'INSERT INTO usuarios (nombre, correo, password, rol) VALUES (?, ?, ?, ?)',
    [nombre, correo, passwordHash, rol],
  );
  return db.lastInsertRowId;
}

void updateUsuario(int id, Map<String, dynamic> campos) {
  final allowedFields = [
    'nombre', 'habilidades_aprender', 'habilidades_ensenar',
    'objetivos', 'experiencia', 'nivel', 'nivel_ensenar',
  ];
  final sets = <String>[];
  final values = <dynamic>[];
  for (final entry in campos.entries) {
    if (allowedFields.contains(entry.key)) {
      sets.add('${entry.key} = ?');
      values.add(entry.value);
    }
  }
  if (sets.isEmpty) return;
  values.add(id);
  db.execute('UPDATE usuarios SET ${sets.join(', ')} WHERE id = ?', values);
}

List<Map<String, dynamic>> buscarMentoresDB(String habilidad, int nivel) {
  return db.select(
    "SELECT * FROM usuarios WHERE rol = 'mentor' AND habilidades_ensenar LIKE ? AND nivel_ensenar >= ?",
    ['%$habilidad%', nivel],
  );
}

// --- Helpers para mensajes ---

List<Map<String, dynamic>> getMensajes(int userId1, int userId2) {
  return db.select(
    '''SELECT * FROM mensajes
       WHERE (emisor_id = ? AND receptor_id = ?) OR (emisor_id = ? AND receptor_id = ?)
       ORDER BY fecha ASC''',
    [userId1, userId2, userId2, userId1],
  );
}

int insertMensaje(int emisorId, int receptorId, String contenido) {
  db.execute(
    'INSERT INTO mensajes (emisor_id, receptor_id, contenido) VALUES (?, ?, ?)',
    [emisorId, receptorId, contenido],
  );
  return db.lastInsertRowId;
}

// --- Helpers para evaluaciones ---

int insertEvaluacion(int mentorId, int estudianteId, String resultado) {
  db.execute(
    'INSERT INTO evaluaciones (mentor_id, estudiante_id, resultado) VALUES (?, ?, ?)',
    [mentorId, estudianteId, resultado],
  );
  if (resultado == 'aprobado') {
    db.execute('UPDATE usuarios SET nivel = nivel + 1 WHERE id = ?', [estudianteId]);
  }
  return db.lastInsertRowId;
}

List<Map<String, dynamic>> getEstudiantesDeMentor(int mentorId) {
  return db.select(
    "SELECT DISTINCT u.* FROM usuarios u INNER JOIN evaluaciones e ON u.id = e.estudiante_id WHERE e.mentor_id = ?",
    [mentorId],
  );
}

List<Map<String, dynamic>> buscarUsuarios(String query) {
  return db.select(
    "SELECT * FROM usuarios WHERE nombre LIKE ? OR correo LIKE ? LIMIT 20",
    ['%$query%', '%$query%'],
  );
}

// --- Helpers para horarios ---

List<Map<String, dynamic>> getHorariosByMentor(int mentorId) {
  return db.select(
    'SELECT * FROM horarios WHERE mentor_id = ? ORDER BY dia_semana, hora_inicio',
    [mentorId],
  );
}

int insertHorario(int mentorId, String diaSemana, String horaInicio, String horaFin) {
  db.execute(
    'INSERT INTO horarios (mentor_id, dia_semana, hora_inicio, hora_fin) VALUES (?, ?, ?, ?)',
    [mentorId, diaSemana, horaInicio, horaFin],
  );
  return db.lastInsertRowId;
}

void deleteHorario(int id) {
  db.execute('DELETE FROM horarios WHERE id = ?', [id]);
}
