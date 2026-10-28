# Prueba Técnica Symplifica — Gestión de Usuarios

<img width="1920" height="945" alt="image" src="https://github.com/user-attachments/assets/150a7841-9dc8-43fc-8aba-b51130bae502" />


Aplicación web full stack desarrollada como parte del proceso de selección para el cargo de **Desarrollador Fullstack Mid en Symplifica**.

El proyecto integra una SPA construida con **Vue 3 y Vite**, una API REST desarrollada con **Java y Spring Boot**, y una base de datos **PostgreSQL** para gestionar usuarios mediante operaciones CRUD.

> **Nota sobre esta entrega:** la solución se amplió después de la sesión de prueba técnica. Se completaron las funcionalidades del frontend, se mejoró la interfaz y se incorporó el registro automático de un usuario de demostración solicitado durante la sesión.

## Características

- **Gestión de usuarios (CRUD):** consultar, crear, editar y eliminar registros.
- **Integración frontend/backend:** comunicación HTTP entre Vue y la API REST.
- **Registro automático de demostración:** al entrar a la aplicación, se comprueba si existe el usuario de prueba y se registra únicamente si no está presente.
- **Manejo de estados:** indicadores de carga, mensajes de éxito y errores de las peticiones.
- **Formulario reactivo:** creación y edición de usuarios con campos vinculados al estado de Vue.
- **Interfaz responsive:** diseño actualizado con estilos CSS, adaptable a pantallas de escritorio y dispositivos móviles.
- **Persistencia de datos:** almacenamiento en PostgreSQL.
- **Migraciones de base de datos:** gestión del esquema y datos iniciales mediante Flyway.

## Tecnologías utilizadas

| Área | Tecnologías |
|---|---|
| Frontend | Vue 3, JavaScript, Vite |
| Backend | Java 25, Spring Boot 4 |
| Persistencia | Spring Data JDBC |
| Base de datos | PostgreSQL 16 |
| Migraciones | Flyway |
| Pruebas | JUnit 5, Spring Test, Testcontainers |
| Entorno | Maven, pnpm, Docker |
| API | REST, JSON, HTTP |

## Arquitectura

El proyecto separa las responsabilidades entre la interfaz de usuario, la API y la persistencia.

```text
Vue 3 + Vite
     |
     | HTTP / JSON
     v
UsersController
     |
     v
UsersService
     |
     v
UsersRepository
     |
     v
PostgreSQL
```

- **Frontend:** presenta los usuarios, gestiona el formulario y comunica las acciones del usuario al backend.
- **Controller:** expone los endpoints REST y construye las respuestas HTTP.
- **Service:** centraliza las operaciones y la lógica de negocio.
- **Repository:** utiliza Spring Data JDBC para acceder a los datos.
- **PostgreSQL:** almacena los registros persistentes.

Flyway administra las migraciones de la base de datos. En desarrollo, Vite utiliza un proxy para dirigir las peticiones `/api` al backend.

## Funcionalidades de la API

La versión ampliada incorpora los siguientes endpoints:

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/users` | Consulta todos los usuarios. |
| `GET` | `/api/users/{id}` | Consulta un usuario por UUID. |
| `POST` | `/api/users` | Registra un usuario. |
| `PUT` | `/api/users/{id}` | Actualiza un usuario existente. |
| `DELETE` | `/api/users/{id}` | Elimina un usuario. |

Las operaciones que requieren un usuario inexistente pueden responder con `404 Not Found`. La creación devuelve `201 Created` y la eliminación exitosa devuelve `204 No Content`, según la implementación del backend.

### Ejemplo de consulta

```bash
curl http://localhost:8080/api/users
```

### Ejemplo de creación

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ana",
    "lastName": "Gomez",
    "email": "ana.gomez@example.com",
    "gender": "Female",
    "phone": "3001234567",
    "birthDate": "1998-05-20"
  }'
```

El identificador y los campos de fecha administrados por el backend dependen de su implementación actual.

## Mejoras realizadas después de la sesión técnica

Como complemento al trabajo realizado durante la evaluación, se continuó desarrollando el proyecto para completar las funcionalidades y reforzar los puntos identificados durante la sesión.

### 1. Completar el CRUD del frontend

Se conectaron las operaciones de creación, consulta, actualización y eliminación con los endpoints del backend mediante `fetch` y peticiones HTTP asíncronas.

### 2. Registro automático de usuario

Se incorporó la funcionalidad solicitada durante la sesión: registrar un usuario de demostración al entrar a la aplicación, verificando previamente si ya existe para evitar duplicados en el flujo normal.

### 3. Actualización visual

Se mejoró el CSS para proporcionar una interfaz más limpia y consistente, incluyendo:

- Formulario organizado en columnas.
- Campos con estados de foco.
- Botones diferenciados según la acción.
- Tabla con encabezados y filas más legibles.
- Mensajes visuales de éxito y error.
- Adaptación a pantallas pequeñas.

### 4. Manejo de respuestas HTTP

Se incorporaron comprobaciones de las respuestas del servidor para informar al usuario cuando una operación no se completa correctamente.

## Requisitos previos

Para ejecutar el proyecto localmente se requiere:

- Node.js 24.x.
- pnpm.
- Java 25.
- Maven 3.9 o superior.
- Docker con Docker Compose.

## Instalación y ejecución

Clona el repositorio y accede a la carpeta del proyecto:

```bash
git clone <URL_DEL_REPOSITORIO>
cd <CARPETA_DEL_PROYECTO>
```

Instala las dependencias del proyecto según su configuración y valida el entorno:

```bash
pnpm validate
```

Inicia la base de datos, el backend y el frontend:

```bash
pnpm dev
```

Direcciones locales:

| Servicio | URL |
|---|---|
| Frontend | http://localhost:5173 |
| Backend | http://localhost:8080 |
| API de usuarios | http://localhost:8080/api/users |
| Health check | http://localhost:8080/actuator/health |

Para conocer los demás comandos disponibles, consulta la documentación de configuración incluida en el repositorio.

## Pruebas

El proyecto incluye pruebas de backend con JUnit y Testcontainers.

Para ejecutarlas:

```bash
pnpm test
```

Docker debe estar en ejecución para que Testcontainers pueda levantar la base de datos temporal utilizada en las pruebas.

**Nota:** las pruebas existentes verifican los componentes y comportamientos cubiertos por su implementación actual; no implica que cada operación CRUD tenga una prueba automatizada independiente.

## Estado del proyecto

La aplicación cuenta con el backend desarrollado durante la sesión técnica y una versión complementada del frontend, con el CRUD integrado, mejoras visuales y la funcionalidad de registro automático solicitada durante la evaluación.

Esta entrega adicional refleja el trabajo realizado después de la sesión y el interés por seguir fortaleciendo las competencias necesarias para el cargo.

## Autor

**Luis Morales**

- GitHub: [Luiis24](https://github.com/Luiis24)
- Portafolio: [lsmoralesdev.netlify.app](https://lsmoralesdev.netlify.app)

