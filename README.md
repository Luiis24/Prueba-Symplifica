# Prueba Técnica Symplifica — Gestión de Usuarios

<img width="1920" height="945" alt="image" src="https://github.com/user-attachments/assets/150a7841-9dc8-43fc-8aba-b51130bae502" />

Aplicación web full stack desarrollada como parte del proceso de selección para el cargo de **Desarrollador Fullstack Mid en Symplifica**.

El proyecto integra una SPA construida con **Vue 3 y Vite**, una API REST desarrollada con **Java 25 y Spring Boot 4**, y una base de datos **PostgreSQL** para gestionar usuarios mediante operaciones CRUD completas.

> **Nota sobre esta entrega:** la solución se amplió después de la sesión de prueba técnica. Se completaron las funcionalidades del frontend, se mejoró la interfaz de usuario, se implementó el registro automático de demostración y se orquestó la aplicación mediante **Docker Multi-stage Building** para su despliegue continuo en la nube (**Render**).

---

## Características

- **Gestión de usuarios (CRUD completo):** consultar, crear, editar y eliminar registros de usuarios en tiempo real.
- **Integración monolítica empaquetada:** el cliente frontend compilado es servido directamente por Spring Boot desde un único artefacto JAR ejecutable.
- **Registro automático de demostración:** al ingresar a la aplicación, se verifica la existencia del usuario de prueba y se registra automáticamente solo si no está presente.
- **Manejo de estados y UX:** indicadores visuales de carga, confirmaciones de acción y mensajes de éxito/error intuitivos.
- **Formulario reactivo:** creación y edición de usuarios dinámicas con enlace bidireccional de datos (`v-model` en Vue 3).
- **Diseño Responsive:** interfaz adaptable a pantallas de escritorio, tabletas y dispositivos móviles.
- **Persistencia y migraciones:** almacenamiento en PostgreSQL administrado mediante **Flyway**.
- **Despliegue automatizado en la nube:** dockerización multinivel optimizada para despliegues continuos en **Render**.

---

## Tecnologías utilizadas

| Área | Tecnologías |
|---|---|
| **Frontend** | Vue 3, JavaScript (ES6+), Vite, HTML5, CSS3 |
| **Backend** | Java 25, Spring Boot 4, Spring Web |
| **Persistencia** | Spring Data JDBC, PostgreSQL 16 |
| **Migraciones** | Flyway |
| **Pruebas** | JUnit 5, Spring Test, Testcontainers |
| **Contenedores & Paquetes** | Docker, Maven, pnpm |
| **Plataforma de Despliegue** | Render (Docker Service) |

---

## Arquitectura y Flujo de Despliegue

La solución empaqueta la SPA de Vue 3 directamente dentro del servidor Java de Spring Boot mediante un proceso de construcción por etapas en Docker (**Multi-stage Build**).

### Diagrama de Arquitectura de Despliegue

```text
+-----------------------------------------------------------------------+
|                            DOCKER BUILD                               |
|                                                                       |
|  [Etapa 1: Frontend]                 [Etapa 2: Backend Build]        |
|  Vue 3 + Vite                       Java 25 + Maven                   |
|  npm run build                      Copia estáticos a:                |
|         │                           /src/main/resources/static/       |
|         └─── Archivos compilados ───────────► │                        |
|                                               ▼                       |
|                                      mvn clean package                |
|                                               │                       |
|                                               ▼                       |
|                                       Genera app.jar                  |
+-----------------------------------------------------------------------+
                                                │
                                                ▼
+-----------------------------------------------------------------------+
|  [Etapa 3: Runtime - Contenedor Final Java 25 JRE]                     |
|                                                                       |
|                       Servidor Spring Boot (8080)                     |
|                   ┌─────────────────────────────────┐                 |
|                   │  Servidor de Archivos Estáticos │ (Vue 3 UI)        |
|                   ├─────────────────────────────────┤                 |
|                   │  Endpoints API REST (/api/users)│                 |
|                   └────────────────┬────────────────┘                 |
|                                    │                                  |
|                                    ▼                                  |
|                          PostgreSQL Database                          |
+-----------------------------------------------------------------------+
```

---

## Funcionalidades de la API REST

La API expone los siguientes endpoints para la administración de usuarios:

| Método | Endpoint | Descripción | Respuesta Exitosa |
|---|---|---|---|
| `GET` | `/api/users` | Lista todos los usuarios registrados | `200 OK` |
| `GET` | `/api/users/{id}` | Obtiene el detalle de un usuario por UUID | `200 OK` / `404 Not Found` |
| `POST` | `/api/users` | Registra un nuevo usuario | `201 Created` |
| `PUT` | `/api/users/{id}` | Actualiza la información de un usuario | `200 OK` / `404 Not Found` |
| `DELETE` | `/api/users/{id}` | Elimina un usuario por su UUID | `204 No Content` |

---

## Proceso de Despliegue y Cambios Clave

Para lograr el despliegue exitoso en **Render**, se implementaron los siguientes cambios y optimizaciones técnicas:

1. **Estructura Multi-Módulo Unificada:**
   - Se organizó el repositorio en una estructura raíz con carpetas independientes `/frontend` y `/backend`.

2. **Integración Build-Time (Vite + Spring Boot):**
   - Se configuró el proceso de compilación del frontend (`vite build`) para canalizar los assets estáticos HTML/JS/CSS e inyectarlos directamente en el directorio `src/main/resources/static` del backend antes de empaquetar el ejecutable `.jar`.

3. **Dockerfile Multinivel (Multi-Stage Dockerfile):**
   - **Etapa 1 (Node 20 Alpine):** Instala dependencias del frontend y compila el cliente Vue 3.
   - **Etapa 2 (Eclipse Temurin 25 JDK + Maven):** Recibe los archivos estáticos generados en la Etapa 1, los integra al código de Spring Boot y compila el JAR con `mvn clean package`.
   - **Etapa 3 (Eclipse Temurin 25 JRE Minimal):** Produce una imagen ligera de ejecución que solo contiene la JRE y el `.jar` listo para la nube.

4. **Publicación Continua en Render:**
   - La aplicación se conecta directamente con GitHub. Cada *push* a la rama `main` ejecuta la construcción del Dockerfile y despliega automáticamente los servicios web y la base de datos PostgreSQL.

---

## Instalación y Ejecución Local

### Requisitos previos

- Node.js 20+
- pnpm
- Java 25
- Maven 3.9+
- Docker & Docker Compose

### Pasos para ejecución local

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Luiis24/Prueba-Symplifica.git
   cd Prueba-Symplifica
   ```

2. **Validar el entorno de desarrollo:**
   ```bash
   pnpm validate
   ```

3. **Levantar base de datos, backend y frontend:**
   ```bash
   pnpm dev
   ```

### Direcciones de acceso local

| Servicio | URL Local |
|---|---|
| **Frontend (Dev Server)** | `http://localhost:5173` |
| **Backend API** | `http://localhost:8080/api/users` |
| **Health Check** | `http://localhost:8080/actuator/health` |

---

## Pruebas Automatizadas

El proyecto incluye pruebas de integración en el backend utilizando JUnit 5 y **Testcontainers** para levantar instancias reales y aisladas de PostgreSQL durante la fase de testing.

Para ejecutar las pruebas:

```bash
pnpm test
```

---

## Autor

**Luis Morales**

- **GitHub:** [@Luiis24](https://github.com/Luiis24)
- **Portafolio:** [lsmoralesdev.netlify.app](https://lsmoralesdev.netlify.app)