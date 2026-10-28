# Configuración de Base de Datos PostgreSQL

## Descripción General

Este proyecto incluye una configuración de PostgreSQL usando Docker Compose. La base de datos se ejecuta en el puerto **5433** (no 5432) para evitar conflictos con otras instancias locales.

## Configuración

### Credenciales por defecto

- **Usuario**: `prueba_user`
- **Contraseña**: `prueba_password`
- **Base de datos**: `prueba_db`
- **Puerto**: `5433`
- **Host**: `localhost`

### Archivo de configuración

- `docker-compose.yml` - Configuración de Docker Compose
- `scripts/init-db.sql` - Script de inicialización SQL
- `scripts/db-manage.sh` - Script de gestión (Linux/macOS)
- `scripts/db-manage.bat` - Script de gestión (Windows)
- `scripts/db-cli.js` - Wrapper de Node.js para ejecutar desde npm

## Comandos disponibles

### Iniciar PostgreSQL
```bash
pnpm db:start
```
Inicia el contenedor de PostgreSQL. Si ya existe, lo reinicia.

### Detener PostgreSQL
```bash
pnpm db:stop
```
Detiene el contenedor de PostgreSQL sin eliminarlo.

### Crear base de datos
```bash
pnpm db:create
```
Verifica que la base de datos existe. Se crea automáticamente al iniciar el contenedor.

### Eliminar base de datos
```bash
pnpm db:drop
```
**ADVERTENCIA**: Esto elimina la base de datos y todos sus datos. Pedirá confirmación.

```bash
pnpm db:drop
# Responde "si" cuando se solicite confirmación
```

### Resetear base de datos
```bash
pnpm db:reset
```
Elimina y recrea la base de datos. Equivalente a ejecutar `db:drop` y `db:create`.

### Ver estado
```bash
pnpm db:status
```
Muestra el estado actual de PostgreSQL y la información del contenedor.

## Flujo típico de desarrollo

```bash
# 1. Validar dependencias
pnpm validate

# 2. Iniciar la base de datos
pnpm db:start

# 3. Verificar estado
pnpm db:status

# 4. (Opcional) Resetear si necesitas una base de datos limpia
pnpm db:reset

# 5. Cuando termines
pnpm db:stop
```

## Conexión desde la aplicación

### Desde Java
```properties
spring.datasource.url=jdbc:postgresql://localhost:5433/prueba_db
spring.datasource.username=prueba_user
spring.datasource.password=prueba_password
```

### Desde Node.js
```javascript
const pool = new Pool({
  user: 'prueba_user',
  password: 'prueba_password',
  host: 'localhost',
  port: 5433,
  database: 'prueba_db',
});
```

### Desde psql (línea de comandos)
```bash
psql -U prueba_user -h localhost -p 5433 -d prueba_db
# Contraseña: prueba_password
```

### Desde DBeaver/pgAdmin
```
Host: localhost
Port: 5433
Database: prueba_db
User: prueba_user
Password: prueba_password
```

## Volúmenes de datos

Los datos de PostgreSQL se almacenan en un volumen de Docker llamado `postgres_data`. Esto significa que:

- Los datos persisten entre reinicios de contenedor
- Si ejecutas `docker-compose down`, los datos se mantienen
- Para eliminar completamente los datos: `docker volume rm prueba-symplifica_postgres_data`

## Solución de problemas

### "Error: bind: address already in use"
El puerto 5433 ya está en uso. Opciones:
1. Cambiar el puerto en `docker-compose.yml`
2. Detener el servicio que usa ese puerto
3. Usar otro puerto: `docker run -p NUEVO_PUERTO:5432 ...`

### "PostgreSQL no responde"
```bash
# Verificar logs del contenedor
docker logs prueba-symplifica-postgres

# Reiniciar
pnpm db:stop
pnpm db:start
```

### "No se puede conectar a la base de datos"
1. Verifica que PostgreSQL está corriendo: `pnpm db:status`
2. Verifica las credenciales en tu aplicación
3. Verifica que usas el puerto correcto (5433, no 5432)

## Backup y Restore

### Crear backup
```bash
docker exec prueba-symplifica-postgres pg_dump -U prueba_user -d prueba_db > backup.sql
```

### Restaurar backup
```bash
docker exec -i prueba-symplifica-postgres psql -U prueba_user -d prueba_db < backup.sql
```

## Personalización

Para agregar más scripts SQL en la inicialización:
1. Crea archivos en la carpeta `scripts/` nombrados `02-*.sql`, `03-*.sql`, etc.
2. Docker Compose ejecutará todos los archivos en orden alfabético

Ejemplo:
```bash
scripts/
├── init-db.sql         # Se ejecuta primero (01)
├── 02-create-tables.sql   # Se ejecuta segundo
└── 03-seed-data.sql       # Se ejecuta tercero
```

## Referencias

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
