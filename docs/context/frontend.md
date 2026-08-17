# Frontend

Paquete Flutter: `sistema_mentorias` (raíz del repo).  
SDK: `^3.11.5`.  
Dependencias que sí se usan en el código leído: `http`, `web_socket_channel`.  
En `pubspec` también están `provider`, `crypto`, `intl`: **no** aparecen en `main.dart`, models ni services. `provider` no envuelve la app.

Host hardcodeado:

```dart
ApiService.baseUrl = 'http://localhost:8080'
ChatService → ws://localhost:8080/ws/chat?userId=
```

## Arranque — `lib/main.dart`

`MaterialApp` Material 3, seed `deepPurple`, tema claro/oscuro.

- `MyApp.appKey` (`GlobalKey<_MyAppState>`) para `toggleTheme()` desde los homes (`import '../main.dart'`).
- Ruta inicial: `/login`.
- `/chat` no está en `routes`: `onGenerateRoute` exige `settings.arguments as Usuario`.

| Ruta | Widget |
|---|---|
| `/login` | `LoginScreen` |
| `/register` | `RegisterScreen` |
| `/home_estudiante` | `HomeEstudiante` |
| `/home_mentor` | `HomeMentor` |
| `/perfil` | `PerfilScreen` |
| `/buscar_mentores` | `BuscarMentoresScreen` |
| `/evaluar` | `EvaluarScreen` |
| `/chats` | `ChatsListScreen` |
| `/estudiantes` | `EstudiantesListScreen` |
| `/horarios` | `HorariosScreen` |
| `/chat` | `ChatScreen(contacto: Usuario)` |

## Modelos

JSON `snake_case` → Dart `camelCase`.

### `Usuario`

`id`, `nombre`, `correo`, `rol`,  
`habilidadesAprender`, `habilidadesEnsenar`, `objetivos`, `experiencia`,  
`nivel`, `nivelEnsenar`.

No incluye `password`. Nulls opcionales → `''` o `1`.

### `Horario`

`id`, `mentorId`, `diaSemana`, `horaInicio`, `horaFin`.

### `Mensaje`

`id`, `emisorId`, `receptorId`, `contenido`, `fecha` (string).  
Sin `toJson`: el envío lo arma `ChatService`.

## Services

### `ApiService`

Métodos estáticos + `static Usuario? usuarioActual` (sesión en memoria).

| Método | Extra |
|---|---|
| `register` / `login` | setean `usuarioActual` |
| `updatePerfil` | si el id es el actual, refresca `usuarioActual` |
| `getMensajes` | devuelve `List<Map>`, no `List<Mensaje>` |

Errores → `Exception` con `data['error']` o mensaje genérico.

### `ChatService`

Una instancia por `ChatScreen`:

- `conectar(userId)` / `enviarMensaje` / `mensajesStream` / `desconectar` / `dispose`
- El historial **no** pasa por aquí (`ApiService.getMensajes` + este stream)

## Convención de las pantallas

Casi todas son `StatefulWidget` con el mismo patrón: `_loading`, `_error`/`_mensaje`, `dispose` de controllers.  
Las únicas `StatelessWidget` son los dos homes (y sus `_MenuCard` privados).

La sesión se lee de `ApiService.usuarioActual`. Si es `null` (app recargada), las pantallas que asumen usuario logueado no tienen un guard global en `main.dart`.

No hay inbox de conversaciones en backend: `/chats` es **búsqueda de usuarios**, no historial de hilos.

---

## Pantallas

### `login_screen.dart` — `/login`

Auth. Formulario (`_formKey`) con correo y password.

| Estado | Uso |
|---|---|
| `_correoController`, `_passwordController` | inputs |
| `_loading`, `_error` | UI de espera / fallo |

`_login()` → `ApiService.login`. Con 200, `usuarioActual` queda seteado; la navegación (no vista en el esqueleto) debe ir a `/home_estudiante` o `/home_mentor` según `usuario.rol`.  
Link típico a `/register` (el `build` no se leyó línea a línea).

---

### `register_screen.dart` — `/register`

Alta. Formulario: nombre, correo, password + `_rol` (default `'estudiante'`).

`_register()` → `ApiService.register(...)`. Mismo criterio de navegación por rol que el login.  
El backend acepta solo `estudiante` | `mentor`.

---

### `home_estudiante.dart` — `/home_estudiante`

Menú del estudiante. `StatelessWidget`.

- Lee `ApiService.usuarioActual` (saludo / datos).
- Importa `main.dart` → `MyApp.appKey.currentState?.toggleTheme()`.
- Tarjetas `_MenuCard` (icono, título, subtítulo, `onTap`).

Destinos coherentes con el rol: `/perfil`, `/buscar_mentores`, `/chats`, y logout → `/login` (limpiar `usuarioActual` si el código lo hace).  
`/horarios` en el front sirve para **ver** disponibilidad de un mentor; en el estudiante eso está en `BuscarMentoresScreen._verHorarios`, no hace falta que el home lo tenga.

---

### `home_mentor.dart` — `/home_mentor`

Igual que el home estudiante: `StatelessWidget` + `_MenuCard` + toggle de tema.

Destinos coherentes con el rol: `/perfil`, `/horarios`, `/estudiantes`, `/evaluar`, `/chats`, logout.

`_MenuCard` está **duplicado** en los dos homes (no es un widget compartido en `lib/widgets/`, que está vacío).

---

### `perfil_screen.dart` — `/perfil`

Edición del usuario logueado. Precarga controllers en `initState` desde `usuarioActual`.

| Controller | Campo probable |
|---|---|
| `_nombreController` | `nombre` |
| `_habilidadesController` | `habilidades_aprender` o `habilidades_ensenar` (un solo campo en UI) |
| `_objetivosController` | `objetivos` |
| `_experienciaController` | `experiencia` |
| `_nivelEnsenarController` | `nivel_ensenar` (típico del mentor) |

`_guardar()` → `ApiService.updatePerfil(id, campos)`.  
`nivel` del estudiante **no** se edita aquí: lo sube el backend al aprobar una evaluación.  
Correo, password y rol no son actualizables por API.

---

### `buscar_mentores.dart` — `/buscar_mentores`

Matching. Input `_habilidadController` + lista `_mentores`.

| Estado | Uso |
|---|---|
| `_mentores` | resultado |
| `_loading`, `_error` | red |
| `_buscado` | distinguir “aún no buscaste” vs “0 resultados” |

`_buscar()` → `ApiService.buscarMentores(habilidad, nivel)`. El `nivel` tiene que salir de `usuarioActual.nivel` (el API lo exige).

`_verHorarios(Usuario mentor)` es grande (~80 líneas): pide `ApiService.getHorariosDeMentor(mentor.id)` y muestra la disponibilidad (`Horario`). **No agenda**: solo consulta. El chat con ese mentor, si existe, saldría de aquí o de `/chats` (el esqueleto no muestra el `Navigator` concreto).

---

### `chats_list_screen.dart` — `/chats`

No es un listado de conversaciones abiertas. Es un **buscador de usuarios** para abrir un chat.

Mismos flags que buscar mentores: `_searchController`, `_resultados`, `_loading`, `_error`, `_buscado`.

`_buscar()` → `ApiService.buscarUsuarios(q)` (`nombre` o `correo`, máx. 20).  
Al elegir un usuario: `Navigator` a `/chat` con ese `Usuario` (la ruta nombrada lo exige).

Cualquier rol puede usarla: el API no filtra por rol.

---

### `chat_screen.dart` — `/chat`

Única pantalla con argumento de constructor: `ChatScreen(contacto: Usuario)`.

Dos canales mezclados:

```text
initState
  → _cargarHistorial()     GET /api/mensajes/<yo>/<contacto>
  → _conectarWebSocket()   ChatService.conectar(yo)
  → escucha mensajesStream y append a _mensajes
_enviar()
  → ChatService.enviarMensaje(contacto.id, texto)
dispose
  → desconecta WS + controllers
```

Estado: `_mensajes`, `_loading`, `_mensajeController`, `_scrollController`.  
`_scrollToBottom()` después de cargar / recibir.

El historial llega como `Map` (`ApiService.getMensajes`) y se convierte a `Mensaje` en la pantalla (el service no lo hace).

---

### `horarios_screen.dart` — `/horarios`

CRUD de disponibilidad del **mentor logueado**.

| Pieza | Rol |
|---|---|
| `_horarios`, `_loading`, `_error` | lista |
| `_diasSemana` / `_diasLabels` | claves API (`miercoles`) vs texto UI |
| `_cargarHorarios()` | `getHorariosDeMentor(usuarioActual.id)` |
| `_agregarHorario()` | abre `_AgregarHorarioDialog` → `crearHorario` |
| `_eliminarHorario` | `eliminarHorario(id)` |
| `_groupByDay()` | agrupa la lista para el `build` |

Diálogo interno:

- día default `lunes`
- `TimeOfDay` inicio `8:00`, fin `12:00`
- `_fmt` serializa a string para el API (`hora_inicio` / `hora_fin` son `TEXT`)

No hay validación de solapes en backend; si existe en el diálogo, no se vio en el esqueleto.

Pensada para mentor. Si un estudiante entra a `/horarios`, el API igual listaría/crearía filas con su id (no hay chequeo de rol).

---

### `estudiantes_list_screen.dart` — `/estudiantes`

Alumnos que **este mentor ya evaluó** (join `evaluaciones`, no un roster aparte).

`initState` → `_cargarEstudiantes()` → `ApiService.getEstudiantesDeMentor(usuarioActual.id)`.

Estado: `_estudiantes`, `_loading`, `_error`.  
Pantalla chica (~100 líneas): lista + estados vacíos/error. Desde aquí se puede ir a chat o a evaluar; el esqueleto no lo confirma.

---

### `evaluar_screen.dart` — `/evaluar`

El mentor **no elige de una lista**: tipea un id.

```text
_estudianteIdController
  → _buscarEstudiante()     getPerfil(id)
  → _estudiante = Usuario?
  → _confirmarEvaluar(resultado)   diálogo
  → _evaluar(resultado)            POST /api/evaluacion
```

`resultado`: `aprobado` | `reprobado`.  
Si aprueba, el backend incrementa `nivel` del estudiante.  
`_mensaje` muestra el texto que devuelve el API.

El backend exige que el id sea un usuario con `rol = estudiante` y que el emisor sea mentor; la UI debería mandar `usuarioActual.id` como `mentor_id`.

---

## Mapa pantalla → API → siguiente pantalla

```text
/login, /register
    POST /api/login | /api/register
    → /home_estudiante | /home_mentor

/perfil
    PUT /api/perfil/<id>

/buscar_mentores
    GET /api/mentores?habilidad&nivel
    GET /api/horarios/mentor/<id>     (_verHorarios)

/chats
    GET /api/usuarios/buscar?q=
    → /chat  (Usuario)

/chat
    GET /api/mensajes/<yo>/<otro>
    WS  /ws/chat?userId=<yo>

/horarios
    GET    /api/horarios/mentor/<yo>
    POST   /api/horarios
    DELETE /api/horarios/<id>

/estudiantes
    GET /api/estudiantes/<yo>

/evaluar
    GET  /api/perfil/<id>          (lookup)
    POST /api/evaluacion
```
