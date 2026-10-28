# Scripts de Validación

## validate-env.js

Script para validar que el entorno está correctamente configurado con todas las dependencias requeridas.

**Compatible con:** Windows, macOS y Linux ✅

### Validaciones

- **Docker**: Verifica que Docker está instalado y corriendo
- **Node.js**: Verifica que Node.js versión 24 está instalado
- **Java**: Verifica que Java versión 25 está instalado
- **Maven**: Verifica que Maven está instalado

### Uso

```bash
# Ejecutar con pnpm (recomendado)
pnpm validate

# O ejecutar directamente con Node
node scripts/validate-env.js
```

### Salida

El script detecta automáticamente tu sistema operativo y muestra:

```
🔍 Validando dependencias del proyecto...
   Sistema operativo: Windows / macOS / Linux

✅ Docker: Docker version 24.0.0, build 12345
✅ Node.js: v24.0.0
✅ Java: openjdk version "25.0.1"
✅ Maven: Apache Maven 3.9.0

✨ ¡Todas las dependencias están correctamente configuradas!
```

O si hay problemas:

```
❌ Docker: Docker no está corriendo. Inicia Docker Desktop o el daemon de Docker
❌ Java: Se esperaba Java 25, pero se encontró versión 21

⚠️  Por favor, instala o actualiza las dependencias faltantes.

📋 Requisitos:
   - Node.js v24.x (https://nodejs.org)
   - Java 25 (https://www.oracle.com/java/technologies/downloads/)
   - Maven 3.9+ (https://maven.apache.org/download.cgi)
   - Docker (https://www.docker.com/products/docker-desktop)
```

### Códigos de Salida

- `0` - Todas las validaciones pasaron ✅
- `1` - Al menos una validación falló ❌

### Requisitos Mínimos

| Dependencia | Versión | Descargar |
|---|---|---|
| Node.js | 24.x | https://nodejs.org |
| Java | 25 | https://www.oracle.com/java/technologies/downloads/ |
| Maven | 3.9+ | https://maven.apache.org/download.cgi |
| Docker | Latest | https://www.docker.com/products/docker-desktop |

### Solución de Problemas

#### "Docker no está corriendo"
- En Windows/macOS: Abre Docker Desktop
- En Linux: Ejecuta `sudo systemctl start docker`

#### "No está en el PATH"
Asegúrate de que las herramientas están correctamente instaladas y agregadas a la variable de entorno `PATH`.

- **Windows**: Reinicia tu terminal o IDE después de instalar
- **macOS/Linux**: Verifica tu archivo `.bashrc` o `.zshrc`

#### Versión incorrecta
Instala la versión específica requerida:
- Para Node.js: Usa `nvm` (https://github.com/nvm-sh/nvm) o descarga directamente
- Para Java: Descarga Java 25 de Oracle o usa `sdkman` (https://sdkman.io/)
