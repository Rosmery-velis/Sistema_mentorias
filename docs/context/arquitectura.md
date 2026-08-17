# Arquitectura

Sistema partido en **dos procesos** que se hablan por red local.

```text
┌─────────────────────────────────────────┐
│  Flutter (Chrome / escritorio)          │
│                                         │
│  screens/  →  ApiService (HTTP)         │
│            →  ChatService (WebSocket)   │
│  models: Usuario, Horario, Mensaje      │
│  sesión: ApiService.usuarioActual       │
└──────────────────┬──────────────────────┘
                   │  HTTP  :8080/api/*
                   │  WS    :8080/ws/chat?userId=
┌──────────────────▼──────────────────────┐
│  Dart Shelf                             │
│  bin/server.dart  (router + CORS)       │
│  lib/routes/*     (handlers)            │
│  lib/db/database.dart  (sqlite3)        │
│  mentorias.db                           │
└─────────────────────────────────────────┘
```

No hay capa de autenticación en el server (ni middleware de token).
CORS está abierto (`Access-Control-Allow-Origin: *`) para que Chrome pueda llamar al API.

## Responsabilidades

| Capa | Qué hace | Qué no hace |
|---|---|---|
| `screens/` | UI, navegación, formularios | SQL, hash de passwords |
| `ApiService` | HTTP + parseo a modelos | Estado de UI |
| `ChatService` | WS connect / send / stream | Historial (eso es HTTP) |
| `routes/` | Validar request y responder JSON | Widgets |
| `database.dart` | Schema + helpers SQL | HTTP |

Las carpetas `backend/lib/middleware/` y `backend/lib/models/` existen pero **no se usan**.
En el front, `lib/widgets/` está vacía. `provider` está en el `pubspec` de Flutter pero el arranque no lo usa: la sesión es un estático.

## Roles y datos

Un `usuario` es `estudiante` **o** `mentor` (`CHECK` en SQLite).

Campos que importan para el matching:

- Estudiante: `habilidades_aprender`, `nivel`
- Mentor: `habilidades_ensenar`, `nivel_ensenar`

**No hay tabla de matches ni de sesiones agendadas.**
“Match” = búsqueda `LIKE` sobre mentores.
“Estudiantes de un mentor” = usuarios que ese mentor **ya evaluó** (join con `evaluaciones`).

## Flujos principales

### Alta y sesión

```text
RegisterScreen / LoginScreen
    → POST /api/register | /api/login
    → ApiService.usuarioActual = Usuario
    → /home_estudiante  o  /home_mentor
```

El login **sí** quita `password` de la respuesta. El registro **devuelve el usuario completo**, incluido el hash (detalle a tener en cuenta).

### Buscar mentor

```text
Estudiante (nivel N, habilidad X)
    → GET /api/mentores?habilidad=X&nivel=N
    → mentores donde
         rol = 'mentor'
         AND habilidades_ensenar LIKE '%X%'
         AND nivel_ensenar >= N
```

### Chat

```text
1. GET /api/mensajes/<yo>/<otro>     historial (SQLite)
2. ChatService.conectar(yo)          WS
3. enviar { receptor_id, contenido }
4. Server: INSERT mensajes
5. Si el otro está conectado, se lo reenvía
6. Al emisor le llega el mismo payload con "enviado": true
```

Las conexiones WS viven en un `Map<int, WebSocketChannel>` en memoria.
Un usuario = una conexión. Si se conecta de nuevo, pisa la anterior.
Si el server se reinicia, se caen todos los sockets (el historial queda en DB).

### Horarios

Solo disponibilidad del mentor (día + rango horario). No hay reserva ni cruce con el estudiante.

```text
GET    /api/horarios/mentor/<id>
POST   /api/horarios          { mentor_id, dia_semana, hora_inicio, hora_fin }
DELETE /api/horarios/<id>
```

Días válidos: `lunes … domingo` (sin tilde: `miercoles`, `sabado`).

### Evaluación

```text
POST /api/evaluacion  { mentor_id, estudiante_id, resultado }
resultado ∈ { aprobado, reprobado }

si aprobado → usuarios.nivel += 1  (del estudiante)
```

Eso también “vincula” al estudiante con el mentor para `GET /api/estudiantes/<mentorId>`.

## Navegación de la app

Definida en `lib/main.dart`:

| Ruta | Pantalla |
|---|---|
| `/login` | LoginScreen (inicial) |
| `/register` | RegisterScreen |
| `/home_estudiante` | HomeEstudiante |
| `/home_mentor` | HomeMentor |
| `/perfil` | PerfilScreen |
| `/buscar_mentores` | BuscarMentoresScreen |
| `/evaluar` | EvaluarScreen |
| `/chats` | ChatsListScreen |
| `/estudiantes` | EstudiantesListScreen |
| `/horarios` | HorariosScreen |
| `/chat` | ChatScreen (argumento: `Usuario` contacto) |

Tema claro/oscuro con `MyApp.appKey` + `toggleTheme()`.

## Decisiones que la doc debe dejar explícitas

1. **Sesión client-side.** No hay token. Recargar = login de nuevo.
2. **API abierta.** Conocer un id alcanza para leer/escribir perfil, borrar horarios, etc.
3. **Password.** SHA-256 sin salt. Suficiente para demo, no para producción.
4. **Matching simple.** Texto libre + `LIKE`, no tags normalizados.
5. **Evaluación = progreso y también relación mentor–estudiante.**