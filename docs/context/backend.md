# Backend

Paquete: `mentorias_backend` (`backend/pubspec.yaml`).  
SDK: `^3.11.5`.

Dependencias: `shelf`, `shelf_router`, `shelf_web_socket`, `web_socket_channel`, `sqlite3`, `crypto`, `path`.

## Arranque — `bin/server.dart`

1. `initDatabase()`
2. Registra rutas en un `Router` de Shelf
3. Pipeline: `logRequests` → CORS → router
4. Escucha `localhost` + `PORT` o `8080`

CORS permite `GET, POST, PUT, DELETE, OPTIONS` y headers `Content-Type, Authorization`
(el header de Authorization **no se usa** en los handlers).

Hay tres wrappers en el mismo archivo porque Shelf necesita firmas concretas:

- `buscarMentoresHandler` → `buscarMentores`
- `handleHistorialChatHandler` → `handleHistorialChat`
- `getEstudiantesMentorHandler` / `buscarUsuariosHandler` — lógica inline (no están en un `*_routes.dart`)

`getEstudiantesDeMentor` y `buscarUsuarios` viven en `database.dart`; el JSON se arma en `server.dart`.

## Base de datos — `lib/db/database.dart`

Archivo: `mentorias.db` junto al *cwd*.  
API: `sqlite3` (`late final Database db`).

### `usuarios`

| Columna | Notas |
|---|---|
| id | PK autoincrement |
| nombre | NOT NULL |
| correo | UNIQUE NOT NULL |
| password | hash SHA-256 (texto) |
| rol | `estudiante` \| `mentor` |
| habilidades_aprender / habilidades_ensenar | texto libre, default `''` |
| objetivos / experiencia | texto libre |
| nivel | default 1 (progreso del estudiante) |
| nivel_ensenar | default 1 (filtro de matching del mentor) |

### `mensajes`

`emisor_id`, `receptor_id` → `usuarios(id)`, `contenido`, `fecha` default `CURRENT_TIMESTAMP`.

### `evaluaciones`

`resultado` ∈ `aprobado` | `reprobado`.  
`insertEvaluacion`: si aprobado, `UPDATE usuarios SET nivel = nivel + 1`.

### `horarios`

`dia_semana` con CHECK de los 7 días (sin tilde).  
`hora_inicio` / `hora_fin` son `TEXT` (no hay tipo TIME).

### Helpers

| Función | Uso |
|---|---|
| `getUsuarioById` / `getUsuarioByCorreo` | auth y perfil |
| `insertUsuario` | register (solo nombre, correo, hash, rol) |
| `updateUsuario` | whitelist de campos de perfil |
| `buscarMentoresDB` | `LIKE` + `nivel_ensenar >=` |
| `getMensajes` / `insertMensaje` | chat |
| `insertEvaluacion` | evaluación + side effect de nivel |
| `getEstudiantesDeMentor` | DISTINCT via join evaluaciones |
| `buscarUsuarios` | nombre/correo, `LIMIT 20` |
| `getHorariosByMentor` / `insertHorario` / `deleteHorario` | disponibilidad |

No hay migraciones: solo `CREATE TABLE IF NOT EXISTS`. Si cambia el schema hay que borrar el `.db` o alterarlo a mano.

## Rutas

### `routes/auth_routes.dart`

- `_hashPassword`: SHA-256 del UTF-8
- `handleRegister` / `handleLogin` (ver `api.md`)

### `routes/profile_routes.dart`

GET/PUT perfil. PUT relee el usuario y lo devuelve sin password.

### `routes/match_routes.dart`

Solo `buscarMentores`. El resto de “búsqueda” está en `server.dart`.

### `routes/evaluacion_routes.dart`

Valida existencia y rol de ambos usuarios antes del insert.

### `routes/horarios_routes.dart`

GET por mentor, POST (valida día), DELETE por id de fila.

### `routes/chat_routes.dart`

- `handleHistorialChat`: HTTP
- `handleWebSocketConnection`: mapa `_connectedUsers`
- Al cerrar o error, saca al usuario del mapa

## Qué no está implementado (para no documentarlo como si existiera)

- Middleware de auth
- Modelos Dart de servidor (se usan `Map<String, dynamic>` de sqlite3)
- Tabla de reservas / sesiones
- Tabla de “match” persistente
- Refresh de token o sesión server-side
```

---

## 5. `docs/frontend.md`

```markdown
# Frontend

Paquete Flutter: `sistema_mentorias` (raíz).  
SDK: `^3.11.5`.  
Dependencias usadas de verdad en el código leído: `http`, `web_socket_channel`.  
En `pubspec` también están `provider`, `crypto`, `intl` — **no aparecen** en `main.dart` ni en los services/models de esta pasada.

Host del API (hardcodeado):

```dart
ApiService.baseUrl = 'http://localhost:8080'
ChatService → ws://localhost:8080/ws/chat?userId=
```

## Arranque — `lib/main.dart`

`MaterialApp` con Material 3, seed `deepPurple`, tema claro/oscuro.

- `MyApp.appKey` (`GlobalKey<_MyAppState>`) para `toggleTheme()` desde otras pantallas.
- Ruta inicial: `/login`.
- `/chat` no está en `routes`: se construye en `onGenerateRoute` con `settings.arguments as Usuario`.

Lista de rutas: ver `docs/arquitectura.md`.

## Modelos

Mapean 1:1 las columnas JSON del backend (`snake_case` en JSON, `camelCase` en Dart).

### `Usuario`

`id`, `nombre`, `correo`, `rol`,  
`habilidadesAprender`, `habilidadesEnsenar`, `objetivos`, `experiencia`,  
`nivel`, `nivelEnsenar`.

`fromJson` tolera nulls en los opcionales (string `''`, nivel `1`).  
**No** incluye `password`. Si el register llega a parsear un JSON con password, ese campo se ignora.

### `Horario`

`id`, `mentorId`, `diaSemana`, `horaInicio`, `horaFin`.  
`fromJson` asume ints/strings no nulos.

### `Mensaje`

`id`, `emisorId`, `receptorId`, `contenido`, `fecha` (string; si viene null → `''`).  
No tiene `toJson`; el envío lo arma `ChatService` a mano.

## Services

### `ApiService`

Clase con métodos **estáticos** + `static Usuario? usuarioActual` (la “sesión”).

| Método | Efecto extra |
|---|---|
| `register` / `login` | setean `usuarioActual` |
| `updatePerfil` | si el id es el actual, refresca `usuarioActual` |
| resto | no tocan la sesión |

Errores: tiran `Exception` con `data['error']` o un mensaje genérico.
`getMensajes` devuelve `List<Map<String, dynamic>>`, no `List<Mensaje>` (el parseo a modelo queda para la pantalla o para el WS).

### `ChatService`

Instancia (no estática):

- `conectar(userId)` — abre el canal y parsea cada frame a `Mensaje`
- `mensajesStream` — `StreamController.broadcast`
- `enviarMensaje(receptorId, contenido)`
- `desconectar` / `dispose`

El historial **no** pasa por aquí; hay que mezclar `ApiService.getMensajes` + este stream.

## Pantallas (por rutas; código aún no leído)

| Archivo | Ruta | Rol esperado (por el nombre / API que existiría) |
|---|---|---|
| `login_screen.dart` | `/login` | Auth |
| `register_screen.dart` | `/register` | Auth |
| `home_estudiante.dart` | `/home_estudiante` | Menú estudiante |
| `home_mentor.dart` | `/home_mentor` | Menú mentor |
| `perfil_screen.dart` | `/perfil` | GET/PUT perfil |
| `buscar_mentores.dart` | `/buscar_mentores` | `buscarMentores` |
| `chats_list_screen.dart` | `/chats` | lista + `buscarUsuarios` |
| `chat_screen.dart` | `/chat` | historial + WS |
| `horarios_screen.dart` | `/horarios` | CRUD disponibilidad |
| `estudiantes_list_screen.dart` | `/estudiantes` | `getEstudiantesDeMentor` |
| `evaluar_screen.dart` | `/evaluar` | `evaluarEstudiante` |

Esta tabla se rellena con responsabilidad real, estados y navegación cuando pegues esos 11 archivos.

## Notas de diseño del cliente

- Sesión no persistida (ni `shared_preferences` en estas dependencias usadas).
- Un solo `baseUrl` local; no hay flavors / `.env`.
- El theme toggle depende de un `GlobalKey` público, no de un `ChangeNotifier`.
```

---

## Cómo queda dividido (respuesta a tu duda)

| Pregunta | Respuesta concreta |
|---|---|
| ¿README = toda la doc? | No. README = qué es + cómo prenderlo + links. |
| ¿Un md de front y uno de back? | Sí, **más** arquitectura y API (el puente). |
| ¿Un md por `.dart`? | No. |

`api.md` no es “del backend”: es el contrato que **los dos** tienen que respetar. Si mañana cambia un endpoint, se toca `api.md` y se revisa `ApiService`, no se reescribe el README.

---

## Segunda pasada (pantallas)

Cuando quieras cerrar `frontend.md`, corre el script con:

```python
# Nombres o patrones de archivos a buscar
# Soporta wildcards: * = cualquier texto, ? = un carácter
FILE_NAMES = [
    "login_screen.dart",
    "register_screen.dart",
    "home_estudiante.dart",
    "home_mentor.dart",
    "perfil_screen.dart",
    "buscar_mentores.dart",
    "chats_list_screen.dart",
    "chat_screen.dart",
    "horarios_screen.dart",
    "estudiantes_list_screen.dart",
    "evaluar_screen.dart",
]