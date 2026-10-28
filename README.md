# Prueba Symplifica

Prueba técnica de desarrollador fullstack mid. Aplicación **SPA (Vue.js + Vite)** con
**API REST (Spring Boot 4 / Java 25)** y **PostgreSQL**, que muestra una tabla con la
lista de usuarios almacenados en la base de datos.

El frontend se compila dentro del backend, de modo que **todo puede servirse desde un
único JAR en el puerto 8080**, o bien trabajarse por separado en desarrollo.

---

## 🚀 Inicio rápido

```bash
# 1. Valida que tienes todo instalado (Docker, Node 24, Java 25, Maven)
pnpm validate

# 2. Levanta TODO el entorno con UN SOLO comando
#    (PostgreSQL + backend en :8080 + frontend en :5173)
pnpm dev
```

Con `pnpm dev`:

- **Backend:** http://localhost:8080
- **Frontend (Vite):** http://localhost:5173
- **API de usuarios:** http://localhost:8080/api/users
- **Health check:** http://localhost:8080/actuator/health

Pulsa **`Ctrl+C`** para detener el backend y el frontend a la vez.

### ▶️ Correr el proyecto (comandos con pnpm)

| Objetivo | Comando |
|---|---|
| **Levantar todo junto** (BD + backend + frontend) | **`pnpm dev`** |
| Levantar todo para **producción** (JAR único en :8080) | `pnpm start` |
| Levantar solo **backend** (BD + Spring Boot) | `pnpm serve` |
| Levantar solo **frontend** (BD + Vite) | `pnpm dev:frontend-only` |
| Levantar el **backend** sin tocar la BD | `pnpm backend:dev` |
| Levantar el **frontend** sin tocar la BD | `pnpm frontend:dev` |

### 🧪 Correr las pruebas unitarias (comandos con pnpm)

| Objetivo | Comando |
|---|---|
| **Todas las pruebas unitarias** | **`pnpm test`** |
| Alias de las pruebas unitarias | `pnpm test:unit` |
| Pruebas del backend (explícito) | `pnpm test:backend` |

> Las pruebas usan **JUnit + Testcontainers**: levantan un PostgreSQL efímero en Docker,
> por lo que **Docker debe estar corriendo**. Consulta la sección
> [🧪 Pruebas](#-pruebas) para más detalle.

---

## 📋 Requisitos

| Herramienta | Versión requerida |
|---|---|
| Node.js | 24.x |
| Java | 25 |
| Maven | 3.9+ |
| Docker | Reciente (con `docker compose`) |

Ejecuta `pnpm validate` para verificarlas automáticamente.

---

## 🧾 Comandos disponibles

Todos se ejecutan **desde la raíz del proyecto**.

### Puesta en marcha conjunta

| Comando | Descripción |
|---|---|
| **`pnpm dev`** | 🔥 **Comando único.** Inicia PostgreSQL + backend + frontend en paralelo (`Ctrl+C` detiene todo). |
| `pnpm start` | Flujo de **producción**: instala, compila el frontend, empaqueta el backend y ejecuta el JAR (`java -jar`) en el puerto 8080. |
| `pnpm serve` | Inicia PostgreSQL + backend Spring Boot (8080). |
| `pnpm dev:frontend-only` | Inicia PostgreSQL + solo el frontend Vite (útil si ya corres el backend aparte). |

### Validación del entorno

| Comando | Descripción |
|---|---|
| `pnpm validate` | Alias de `validate:env`. |
| `pnpm validate:env` | Verifica Docker, Node.js 24, Java 25 y Maven. |

### Base de datos (PostgreSQL vía Docker en el puerto 5433)

| Comando | Descripción |
|---|---|
| `pnpm db:start` | Inicia (o reinicia) el contenedor de PostgreSQL. |
| `pnpm db:stop` | Detiene el contenedor sin eliminarlo. |
| `pnpm db:create` | Crea la base de datos `prueba_db` si no existe y asegura las extensiones. |
| `pnpm db:drop` | ⚠️ Elimina la base de datos y todos sus datos (pide confirmación escribiendo `si`). |
| `pnpm db:reset` | ⚠️ Elimina y recrea la base de datos. Al reiniciar el backend, Flyway vuelve a crear el esquema y sembrar los datos. |
| `pnpm db:status` | Muestra el estado del contenedor de PostgreSQL. |

### Frontend (Vue.js + Vite)

| Comando | Descripción |
|---|---|
| `pnpm frontend:dev` | Servidor de desarrollo Vite (5173) con proxy `/api` → `:8080`. |
| `pnpm frontend:build` | Compila el SPA en `backend/src/main/resources/static`. |
| `pnpm frontend:preview` | Sirve localmente el build de producción (4173). |
| `pnpm build` | Alias de `frontend:build`. |

### Backend (Spring Boot + Maven)

| Comando | Descripción |
|---|---|
| `pnpm backend:dev` | Ejecuta Spring Boot en el puerto 8080. |
| `pnpm backend:build` | `mvn clean package` (compila y ejecuta los tests). |
| `pnpm test` | Ejecuta **todas las pruebas unitarias** (backend). |
| `pnpm test:unit` | Alias de `test`. |
| `pnpm test:backend` | Ejecuta las pruebas del backend (`mvn test`). |

---

## 🗂️ Estructura del proyecto

```
PruebaSymplifica/
│
├── package.json                 # Scripts raíz (pnpm). Orquesta todo el proyecto.
├── docker-compose.yml           # Servicio PostgreSQL 16 (puerto 5433).
├── DATABASE.md                  # Documentación detallada de la base de datos.
├── FRONTEND_SETUP.md            # Documentación de la integración frontend/backend.
├── README.md                    # Este archivo.
│
├── scripts/                     # Utilidades de soporte (Node.js / shell).
│   ├── dev-all.js               # 🔥 Orquestador de `pnpm dev` (BD + backend + frontend).
│   ├── validate-env.js          # Validación de dependencias (Docker, Node, Java, Maven).
│   ├── db-cli.js                # Wrapper Node de los scripts de gestión de la BD.
│   ├── db-manage.sh             # Gestión de PostgreSQL para Linux/macOS.
│   ├── db-manage.bat            # Gestión de PostgreSQL para Windows.
│   └── init-db.sql              # Script de inicialización del contenedor (extensiones).
│
├── frontend/                    # SPA con Vue.js 3 + Vite 8.
│   ├── package.json
│   ├── vite.config.js           # Build → backend/.../static y proxy /api.
│   ├── index.html
│   ├── public/
│   └── src/
│       ├── main.js              # Punto de entrada de Vue.
│       ├── App.vue              # Componente principal: tabla de usuarios.
│       ├── style.css
│       ├── components/
│       │   └── HelloWorld.vue   # Componente de ejemplo de la plantilla Vite (sin uso).
│       └── assets/
│
└── backend/                     # API REST con Spring Boot 4 (Java 25).
    ├── pom.xml
    └── src/
        ├── main/
        │   ├── java/
        │   │   ├── com/symplifica/
        │   │   │   ├── backend/
        │   │   │   │   └── BackendApplication.java   # Clase principal + @EnableJdbcRepositories.
        │   │   │   ├── config/
        │   │   │   │   └── FrontendConfig.java        # Controlador SPA (rutas → index.html).
        │   │   │   └── user/
        │   │   │       ├── User.java                  # Entidad (record) mapeada a la tabla users.
        │   │   │       ├── UsersRepository.java       # Repositorio Spring Data JDBC.
        │   │   │       ├── UsersService.java          # Lógica de negocio.
        │   │   │       └── UsersController.java       # Endpoints REST /api/users.
        │   │   └── db/migration/
        │   │       ├── V1__Create_Users_Table.java    # Migración Flyway: crea la tabla.
        │   │       └── V2__Seed_Users.java            # Migración Flyway: inserta 3 usuarios.
        │   └── resources/
        │       ├── application.properties             # Configuración (BD, Flyway, Jackson, etc.).
        │       ├── templates/index.html               # Plantilla Thymeleaf del SPA.
        │       └── static/                            # Build del frontend (js/, css/, imágenes).
        │
        └── test/java/com/symplifica/
            ├── backend/BackendApplicationTests.java   # Carga del contexto.
            └── user/UsersServiceTest.java             # Test de integración con Testcontainers.
```

---

## 🔌 API REST

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/api/users` | Lista todos los usuarios. |
| `GET` | `/api/users/{id}` | Devuelve un usuario por su UUID (404 si no existe). |

Ejemplo:

```bash
curl http://localhost:8080/api/users
```

Respuesta (resumida):

```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "name": "Juan",
    "lastName": "Perez",
    "email": "juan.perez@symplifica.com",
    "gender": "Male",
    "phone": "+57 300 123 4567",
    "birthDate": "1990-01-15"
  }
]
```

---

## 🗄️ Base de datos

- **Motor:** PostgreSQL 16 (contenedor Docker).
- **Puerto:** `5433` (no 5432, para evitar conflictos).
- **Credenciales:** usuario `prueba_user` / contraseña `prueba_password` / BD `prueba_db`.
- **Migraciones:** Flyway en Java (paquete `db.migration`):
  - `V1__Create_Users_Table` → crea la tabla `users` e índices.
  - `V2__Seed_Users` → inserta 3 usuarios de ejemplo (Juan, Maria y Carlos).

Consulta la documentación completa en [`DATABASE.md`](DATABASE.md).

---

## 🧩 Flujos de trabajo

### Desarrollo (un solo comando, recomendado)

```bash
pnpm dev
```

Levanta la BD, el backend y el frontend juntos. Hot reload en el frontend y
reinicio de contexto en el backend.

### Desarrollo por separado (3 terminales)

```bash
# Terminal 1
pnpm db:start

# Terminal 2
pnpm backend:dev      # http://localhost:8080

# Terminal 3
pnpm frontend:dev     # http://localhost:5173 (proxy /api → :8080)
```

### Producción (JAR único servido en 8080)

```bash
pnpm start
```

Compila el frontend dentro del backend, empaqueta todo y ejecuta el JAR. La
aplicación completa queda disponible en http://localhost:8080.

### Pruebas unitarias

```bash
pnpm test            # Ejecuta todas las pruebas unitarias
pnpm test:unit       # Alias
pnpm test:backend    # Pruebas del backend (mvn test)
```

### Compilar el backend (con tests incluidos)

```bash
pnpm backend:build
```

---

## 🧪 Pruebas

Ejecuta todas las pruebas unitarias con:

```bash
pnpm test
```

Equivale a `mvn test` dentro de `backend/` y ejecuta los tests de JUnit con
**Testcontainers** (levanta un PostgreSQL efímero en Docker, por lo que **Docker debe
estar corriendo**):

- `BackendApplicationTests` → verifica que el contexto de Spring carga.
- `UsersServiceTest` → verifica que las migraciones de Flyway crean y siembran
  correctamente los 3 usuarios esperados.

También puedes usar los alias:

```bash
pnpm test:unit      # Alias de pnpm test
pnpm test:backend   # Pruebas del backend (mvn test)
```

Resultado esperado:

```
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

> 💡 Recuerda que las pruebas **no** necesitan que la base de datos del proyecto esté
> levantada: Testcontainers crea su propio contenedor temporal y lo destruye al terminar.

---

## ⚙️ Notas técnicas

- **Spring Boot 4.1.1 / Java 25**: usa Jackson 3 (`tools.jackson`), por lo que las
  propiedades de fechas están bajo `spring.jackson.datatype.datetime.*`.
- **Flyway** corre en versión Java (clases en `db.migration`), no en SQL.
- El controlador `FrontendConfig` redirige a `index.html` **solo** las rutas del SPA;
  las APIs (`/api/**`), las de actuator (`/actuator/**`) y los recursos estáticos
  (`/js/**`, `/css/**`, etc.) se sirven con sus propios manejadores.
- **Actuator** expone `/actuator/health` e `/actuator/info`.

---

## 🛠️ Solución de problemas

| Problema | Solución |
|---|---|
| `bind: address already in use` en 5433 | Otro servicio usa el puerto. Cambia el mapeo en `docker-compose.yml` o detén ese servicio. |
| PostgreSQL no responde | `pnpm db:stop && pnpm db:start`, o revisa `docker logs prueba-symplifica-postgres`. |
| El frontend muestra error de API | Verifica que el backend esté en ejecución en el puerto 8080. |
| Quieres una base de datos limpia | `pnpm db:reset` y vuelve a iniciar el backend para re-sembrar los datos. |
| Los tests fallan | Asegúrate de que **Docker está corriendo** (Testcontainers necesita el daemon). |

---

## 📄 Licencia

ISC.
