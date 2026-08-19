# Sistema de Mentorías

Aplicación de mentorías con dos roles: **estudiante** y **mentor**.
El estudiante busca mentores por habilidad y nivel, chatea, ve horarios y es evaluado.
El mentor publica disponibilidad, chatea, ve estudiantes y registra aprobado/reprobado.

## Stack

| Capa | Tecnología |
|---|---|
| App | Flutter (`sistema_mentorias`), Chrome / escritorio |
| API | Dart Shelf (`mentorias_backend`), puerto `8080` |
| Tiempo real | WebSocket (`/ws/chat`) |
| Persistencia | SQLite (`backend/mentorias.db`) |

Frontend y backend se hablan por HTTP/JSON en `http://localhost:8080`.
El chat en vivo usa `ws://localhost:8080/ws/chat?userId=<id>`.

## Cómo correrlo

Hace falta **dos procesos**: primero el backend, después la app.

### 1. Backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Deberías ver:

```text
[DB] Base de datos inicializada en: .../mentorias.db
[SERVER] Servidor corriendo en http://localhost:8080
```

El archivo `mentorias.db` se crea solo en el directorio desde el que lanza el server
(`Directory.current`). Conviene ejecutarlo **siempre desde `backend/`**.

Variable opcional: `PORT` (por defecto `8080`).

### 2. App Flutter

Desde la raíz del repo:

```bash
flutter pub get
flutter run -d chrome
```

o el dispositivo de escritorio que uses. La app asume el API en `http://localhost:8080`
(`lib/services/api_service.dart`).

### Flujo mínimo para probar

1. Registrar un **mentor** y completar habilidades / nivel de enseñanza en perfil.
2. Registrar un **estudiante**.
3. En el home del estudiante: buscar mentores → chat / horarios.
4. En el home del mentor: horarios, estudiantes, evaluar.

No hay usuarios de semilla: todo se crea por `/api/register`.
La sesión vive solo en memoria (`ApiService.usuarioActual`); al recargar la app hay que volver a iniciar sesión.

## Estructura

```text
.
├── lib/                     # App Flutter
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── temas/
├── backend/                 # API Dart + SQLite
│   ├── bin/server.dart
│   ├── lib/db/database.dart
│   ├── lib/routes/
│   └── mentorias.db
└── docs/
    ├── arquitectura.md
    ├── api.md
    ├── frontend.md
    └── backend.md
```

## Documentación

- [Arquitectura](docs/context/arquitectura.md) — cómo se conectan las capas y los flujos
- [API](docs/context/api.md) — endpoints, bodies y códigos
- [Frontend](docs/context/frontend.md) — app Flutter
- [Backend](docs/context/backend.md) — server, rutas y SQLite

## Auth (resumen)

- Registro y login con correo + password.
- El backend guarda el password con **SHA-256** (no hay JWT ni cookies).
- Las rutas **no** exigen token: cualquiera que conozca un `id` puede consultar/editar.

Eso está bien para un prototipo local; no es un modelo de producción.