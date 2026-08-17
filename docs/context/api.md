# API

Base: `http://localhost:8080`  
Content-Type: `application/json`  
CORS: `*` (también responde `OPTIONS`)

No hay header `Authorization`. El `userId` del chat va por query en el WebSocket.

Errores típicos: `{ "error": "..." }`.

---

## Auth

### `POST /api/register`

Body:

```json
{ "nombre": "...", "correo": "...", "password": "...", "rol": "estudiante" }
```

`rol` debe ser `estudiante` o `mentor`.

| Código | Cuándo |
|---|---|
| 200 | Creado. Devuelve `{ mensaje, usuario }` — el `usuario` incluye `password` (hash) |
| 400 | Faltan campos o rol inválido |
| 409 | Correo ya registrado |

El password se guarda como SHA-256 hex.

### `POST /api/login`

```json
{ "correo": "...", "password": "..." }
```

| Código | Cuándo |
|---|---|
| 200 | `{ mensaje, usuario }` **sin** `password` |
| 400 | Faltan correo/password |
| 401 | Correo inexistente o hash distinto (`Credenciales inválidas`) |

---

## Perfil

### `GET /api/perfil/<id>`

200: objeto usuario sin password.  
400: id no numérico.  
404: no existe.

### `PUT /api/perfil/<id>`

Body: mapa parcial. El server **solo aplica** estas claves:

- `nombre`
- `habilidades_aprender`
- `habilidades_ensenar`
- `objetivos`
- `experiencia`
- `nivel`
- `nivel_ensenar`

No se puede cambiar `correo`, `password` ni `rol` por esta vía.

200: `{ mensaje, usuario }` sin password.  
400 / 404: igual que el GET.

---

## Matching y usuarios

### `GET /api/mentores?habilidad=<texto>&nivel=<int>`

Mentores con `habilidades_ensenar LIKE '%texto%'` y `nivel_ensenar >= nivel`.

200: array de usuarios sin password.  
400: falta query param, o `nivel` no es número.

### `GET /api/estudiantes/<mentorId>`

Estudiantes **distintos** que aparecen en `evaluaciones` de ese mentor.
Sin password. 400 si el id no es número.

### `GET /api/usuarios/buscar?q=<texto>`

`nombre LIKE` o `correo LIKE`, máximo 20. Sin password.  
400 si `q` falta o está vacío.

---

## Evaluación

### `POST /api/evaluacion`

```json
{ "mentor_id": 1, "estudiante_id": 2, "resultado": "aprobado" }
```

`resultado`: `aprobado` | `reprobado`.

Si es `aprobado`, hace `nivel = nivel + 1` en el estudiante.

200:

```json
{
  "mensaje": "Estudiante aprobado. Nivel subido a N",
  "evaluacion_id": 1,
  "nivel_actual": 2
}
```

(o el mensaje de reprobado, sin subir nivel).

400: campos faltantes, resultado inválido, mentor/estudiante inexistente o con rol incorrecto.

---

## Chat HTTP

### `GET /api/mensajes/<userId1>/<userId2>`

Historial en ambos sentidos, `ORDER BY fecha ASC`.

200: array de filas `mensajes` (incluye `id`, `emisor_id`, `receptor_id`, `contenido`, `fecha`).  
400: ids no numéricos.

El envío **no** es REST: va por WebSocket.

---

## Horarios

Días: `lunes`, `martes`, `miercoles`, `jueves`, `viernes`, `sabado`, `domingo`.

### `GET /api/horarios/mentor/<id>`

200: array ordenado por `dia_semana, hora_inicio` (orden alfabético del día, no de calendario).

### `POST /api/horarios`

```json
{
  "mentor_id": 1,
  "dia_semana": "lunes",
  "hora_inicio": "09:00",
  "hora_fin": "10:00"
}
```

200: `{ mensaje, id }`.  
400: faltan campos o día inválido.

No valida que `hora_fin > hora_inicio` ni solapes.

### `DELETE /api/horarios/<id>`

200: `{ mensaje: "Horario eliminado" }` aunque el id no exista (el `DELETE` no comprueba filas).

---

## WebSocket

### `GET /ws/chat?userId=<int>`  (upgrade)

Query `userId` obligatoria y numérica; si no, 400 texto plano.

Cliente envía:

```json
{ "receptor_id": 2, "contenido": "hola" }
```

Server:

1. `INSERT` en `mensajes`
2. Si el receptor tiene socket abierto, le manda:

```json
{ "id", "emisor_id", "receptor_id", "contenido", "fecha" }
```

3. Al emisor, lo mismo más `"enviado": true`

`fecha` del push es `DateTime.now().toIso8601String()` del server, no necesariamente el `CURRENT_TIMESTAMP` de SQLite.

Si faltan campos o el JSON es inválido, el mensaje se ignora (no hay error tipado al cliente).

---

## Mapa rápido front → API

| `ApiService` / `ChatService` | Endpoint |
|---|---|
| `register` | `POST /api/register` |
| `login` | `POST /api/login` |
| `getPerfil` / `updatePerfil` | `GET/PUT /api/perfil/<id>` |
| `buscarMentores` | `GET /api/mentores` |
| `evaluarEstudiante` | `POST /api/evaluacion` |
| `getMensajes` | `GET /api/mensajes/a/b` |
| `getEstudiantesDeMentor` | `GET /api/estudiantes/<id>` |
| `buscarUsuarios` | `GET /api/usuarios/buscar` |
| `getHorariosDeMentor` | `GET /api/horarios/mentor/<id>` |
| `crearHorario` | `POST /api/horarios` |
| `eliminarHorario` | `DELETE /api/horarios/<id>` |
| `ChatService.conectar` | `ws://localhost:8080/ws/chat?userId=` |