# Configuración de Base de Datos - Backend

## Descripción General

El backend está configurado para conectarse a PostgreSQL en el puerto **5433** con las siguientes credenciales:

- **Host**: localhost
- **Port**: 5433
- **Usuario**: prueba_user
- **Contraseña**: prueba_password
- **Base de datos**: prueba_db

## Archivos de Configuración

```
backend/src/main/resources/
├── application.properties       ← Configuración base (compartida)
├── application-dev.properties   ← Configuración para desarrollo
└── application-prod.properties  ← Configuración para producción
```

### application.properties (Base)

Contiene la configuración común a todos los ambientes:
- Credenciales de base de datos (PostgreSQL en puerto 5433)
- Pool de conexiones (HikariCP)
- Configuración de JPA/Hibernate
- Charset UTF-8
- Zona horaria y locale Colombia

### application-dev.properties (Desarrollo)

Configuración optimizada para desarrollo:
- Logging detallado (DEBUG)
- SQL mostrado en consola
- Hibernate DDL en modo `update` (crea/actualiza tablas automáticamente)
- Error handling detallado con stacktraces

### application-prod.properties (Producción)

Configuración optimizada para producción:
- Logging minimalista (WARN)
- SQL no mostrado
- Hibernate DDL en modo `validate` (solo valida el schema)
- Error handling seguro (sin stacktraces)
- Pool de conexiones más agresivo

## Cómo usar

### En desarrollo

```bash
# Maven
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"

# Gradle
./gradlew bootRun --args='--spring.profiles.active=dev'
```

O configurar en `application.properties`:
```properties
spring.profiles.active=dev
```

### En producción

```bash
# Maven
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=prod"

# Con JAR compilado
java -jar backend.jar --spring.profiles.active=prod
```

## Propiedades Principales

### DataSource (Conexión)

```properties
spring.datasource.url=jdbc:postgresql://localhost:5433/prueba_db
spring.datasource.username=prueba_user
spring.datasource.password=prueba_password
spring.datasource.driver-class-name=org.postgresql.Driver
```

### HikariCP (Pool de Conexiones)

```properties
spring.datasource.hikari.maximum-pool-size=10      # Máximo de conexiones
spring.datasource.hikari.minimum-idle=5             # Mínimo en idle
spring.datasource.hikari.connection-timeout=30000   # Timeout en ms
spring.datasource.hikari.idle-timeout=600000        # Timeout en idle (10 min)
spring.datasource.hikari.max-lifetime=1800000       # Max lifetime (30 min)
```

### JPA/Hibernate

```properties
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=validate              # update|create|validate
spring.jpa.show-sql=false                            # Mostrar SQL en logs
spring.jpa.properties.hibernate.format_sql=true      # Formatear SQL
```

#### Valores de `ddl-auto`

- **validate**: Solo valida el schema (modo seguro para producción)
- **update**: Crea nuevas tablas y actualiza las existentes (desarrollo)
- **create**: Crea nuevo schema (resetea BD)
- **create-drop**: Crea al iniciar, elimina al detener (testing)
- **none**: No hace nada (configuración manual)

## Dependencias Requeridas

Asegúrate de tener en `pom.xml`:

```xml
<!-- PostgreSQL Driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Spring Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Spring Web -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

## Verificar Conexión

### Desde la aplicación

Si la aplicación inicia correctamente sin errores de conexión, la BD está funcionando.

### Desde línea de comandos

```bash
# Conectar directamente
psql -U prueba_user -h localhost -p 5433 -d prueba_db
# Contraseña: prueba_password

# O con pgAdmin
# Host: localhost
# Port: 5433
# User: prueba_user
# Password: prueba_password
```

## Solución de Problemas

### "Connection refused"

1. Verificar que PostgreSQL está corriendo:
```bash
pnpm db:status
```

2. Verificar que está en el puerto correcto:
```bash
docker ps | grep postgres
```

### "Authentication failed"

Verificar las credenciales en `application.properties`:
- Usuario: `prueba_user`
- Contraseña: `prueba_password`

### "FATAL: remaining connection slots are reserved"

El pool de conexiones está saturado. Opciones:
1. Aumentar `maximum-pool-size` en `application.properties`
2. Revisar si hay conexiones abiertas no cerradas en el código
3. Reiniciar la base de datos: `pnpm db:stop && pnpm db:start`

### "Hibernate dialect error"

Asegúrate de usar `PostgreSQLDialect`:
```properties
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

## Configuración Avanzada

### Ejecutar scripts SQL al startup

Agregar archivos en `backend/src/main/resources/`:

```
data.sql          ← Data (INSERT)
schema.sql        ← Schema (CREATE TABLE)
```

Hibernate ejecutará estos archivos después de las migraciones.

### Usar Liquibase o Flyway

Para migraciones más robustas:

```xml
<!-- Flyway -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

Los scripts irían en `backend/src/main/resources/db/migration/`

### Pool de conexiones personalizado

```properties
# Tuning para aplicaciones de alto volumen
spring.datasource.hikari.maximum-pool-size=50
spring.datasource.hikari.minimum-idle=20
spring.datasource.hikari.connection-timeout=10000
spring.datasource.hikari.idle-timeout=300000
spring.datasource.hikari.max-lifetime=900000
```

## Referencias

- [Spring Boot DataSource Configuration](https://spring.io/guides/gs/accessing-data-mysql/)
- [HikariCP Documentation](https://github.com/brettwooldridge/HikariCP)
- [Hibernate Documentation](https://hibernate.org/orm/documentation/)
- [PostgreSQL JDBC Driver](https://jdbc.postgresql.org/)
