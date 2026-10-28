# Configuración del Frontend - Integración con Backend

## Descripción General

El frontend (Vue.js + Vite) está configurado para:
1. Construirse en la carpeta `backend/src/main/resources/static` del backend
2. Ser servido por Spring Boot usando Thymeleaf
3. Permitir que Vue Router maneje la navegación del lado del cliente

Este es un patrón típico de **Single Page Application (SPA)** donde:
- El backend actúa como API REST + servidor de archivos estáticos
- El frontend es una SPA que se carga una sola vez
- Todas las rutas se manejan del lado del cliente (Vue Router)

## Estructura de Carpetas

```
PruebaSymplifica/
├── frontend/                              ← Código fuente Vue.js
│   ├── src/
│   ├── public/
│   ├── vite.config.js                    ← Configurado para build al backend
│   └── package.json
│
├── backend/
│   ├── src/main/resources/
│   │   ├── static/                       ← Assets estáticos (generados por build)
│   │   │   ├── js/
│   │   │   ├── css/
│   │   │   └── images/
│   │   └── templates/
│   │       └── index.html                ← Template Thymeleaf
│   │
│   ├── src/main/java/com/symplifica/
│   │   └── config/
│   │       └── FrontendConfig.java       ← Controlador SPA
│   └── src/main/resources/
│       ├── application.properties
│       ├── application-dev.properties
│       └── application-prod.properties
```

## Configuración Vite (vite.config.js)

```javascript
build: {
  outDir: '../backend/src/main/resources/static',
  emptyOutDir: true,
  rollupOptions: {
    output: {
      entryFileNames: 'js/[name].[hash].js',
      chunkFileNames: 'js/[name].[hash].js',
      assetFileNames: ({ name }) => {
        // Organiza assets por tipo
        if (/\.(gif|jpe?g|png|svg|webp)$/.test(name)) {
          return 'images/[name].[hash][extname]'
        } else if (/\.css$/.test(name)) {
          return 'css/[name].[hash][extname]'
        }
        return '[name].[hash][extname]'
      }
    }
  }
}
```

### Cambios principales:
- ✅ `outDir`: Build output en `backend/src/main/resources/static`
- ✅ `emptyOutDir`: Limpia la carpeta antes de cada build
- ✅ `rollupOptions`: Organiza assets en carpetas `js/`, `css/`, `images/`

## Controlador Spring Boot (FrontendConfig.java)

```java
@Controller
@RequestMapping("/")
public class FrontendConfig implements ErrorController {
    
    @GetMapping({"", "/", "/error"})
    public String index() {
        return "index";  // Devuelve templates/index.html
    }
    
    @GetMapping("/**")
    public String forwardToIndex() {
        return "index";  // Todas las rutas → index.html
    }
}
```

### Cómo funciona:
1. Todas las peticiones GET a rutas que NO son `/api/**` van al controlador
2. El controlador devuelve `"index"`, que Thymeleaf resuelve como `templates/index.html`
3. El archivo `index.html` carga `main.js` que inicializa Vue
4. Vue Router maneja la navegación del lado del cliente

## Template Thymeleaf (templates/index.html)

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Prueba Symplifica</title>
    <script type="module" crossorigin src="/js/main.js"></script>
</head>
<body>
    <div id="app"></div>
</body>
</html>
```

### Puntos clave:
- ✅ El `src="/js/main.js"` apunta al archivo generado por Vite
- ✅ El hash en el nombre del archivo (`main.abc123.js`) permite cache busting
- ✅ El `<div id="app"></div>` es donde Vue monta la aplicación

## Comandos Disponibles

### Desarrollo

```bash
# Iniciar todo (BD + Frontend dev)
pnpm dev

# O manualmente:
pnpm db:start                  # Inicia PostgreSQL
pnpm frontend:dev              # Inicia servidor Vite (puerto 5173)

# En otra terminal:
pnpm backend:dev               # Inicia Spring Boot (puerto 8080)
```

### Build para Producción

```bash
# Build del frontend y empaquetado del backend
pnpm build                     # Build frontend → backend/resources/static/

# Luego empaquetar el backend
cd backend
mvn clean package              # Crea JAR con frontend incluido
java -jar target/backend.jar   # Ejecuta el JAR con frontend incluido
```

### Scripts de Frontend (desde raíz)

```bash
pnpm frontend:dev              # Inicia Vite dev server
pnpm frontend:build            # Build para producción
pnpm frontend:preview          # Preview del build local
```

### Scripts de Backend (desde raíz)

```bash
pnpm backend:dev               # Inicia Spring Boot en dev
pnpm backend:build             # Compila el JAR
```

## Flujo de Desarrollo

### Opción 1: Desarrollo separado (recomendado)

```bash
# Terminal 1: Base de datos
pnpm db:start

# Terminal 2: Frontend
pnpm frontend:dev              # Abre en http://localhost:5173

# Terminal 3: Backend
pnpm backend:dev               # Abre en http://localhost:8080
```

**Ventajas:**
- Hot reload en frontend (cambios inmediatos)
- Desarrollo más rápido
- Fácil depuración

**Desventajas:**
- Requiere 3 terminales
- El frontend en dev se comunica con el backend en 8080

### Opción 2: Build y servir desde backend

```bash
# Build del frontend
pnpm frontend:build

# Inicia backend
pnpm backend:dev

# Accede a http://localhost:8080
```

**Ventajas:**
- Todo se sirve desde un puerto (8080)
- Simula el entorno de producción
- No necesita frontend dev server

**Desventajas:**
- Sin hot reload
- Requiere rebuild para ver cambios

## Cómo Comunicarse con el Backend (APIs)

### Desde Vue.js

```javascript
// En componentes Vue
const response = await fetch('/api/usuarios', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
})
const data = await response.json()
```

### IMPORTANTE: Rutas de API

- **Rutas del frontend**: `/`, `/usuarios`, `/productos`, etc.
- **Rutas de API**: `/api/**` (cualquier cosa que comience con `/api/`)

El controlador NO redirige rutas que comienzan con `/api/`, por lo que puedes crear controladores REST normales:

```java
@RestController
@RequestMapping("/api/usuarios")
public class UsuariosController {
    @GetMapping
    public List<Usuario> listar() {
        // Devuelve JSON
    }
}
```

## Estructura del Proyecto Después del Build

Después de ejecutar `pnpm build`, la estructura será:

```
backend/src/main/resources/static/
├── js/
│   ├── main.abc123def456.js
│   └── chunk.xyz789.js
├── css/
│   └── style.def456.css
├── images/
│   └── logo.png
└── ... otros assets
```

Spring Boot servirá automáticamente estos archivos cuando se soliciten.

## Depuración y Troubleshooting

### El frontend no se carga en http://localhost:8080

1. Verifica que el build fue exitoso: `pnpm frontend:build`
2. Verifica que los archivos están en `backend/src/main/resources/static/`
3. Verifica que el servidor Spring está corriendo
4. Limpia la caché del navegador (Ctrl+Shift+R)

### "Cannot find module" en el build

```bash
# En la carpeta frontend
pnpm install

# Luego intenta el build
pnpm frontend:build
```

### Hot reload no funciona en desarrollo

Asegúrate de que:
1. Estás en `http://localhost:5173` (frontend dev server)
2. No en `http://localhost:8080`

### Vue Router muestra 404 en rutas anidadas

Asegúrate de que el controlador redirige **todas** las rutas excepto `/api/**`:

```java
@GetMapping("/**")
public String forwardToIndex() {
    return "index";
}
```

## Integración con API REST

### Ejemplo: Crear un endpoint

```java
// backend/src/main/java/com/symplifica/api/ProductosController.java
@RestController
@RequestMapping("/api/productos")
public class ProductosController {
    
    @GetMapping
    public List<Producto> listar() {
        return productosService.findAll();
    }
    
    @GetMapping("/{id}")
    public Producto obtener(@PathVariable Long id) {
        return productosService.findById(id);
    }
    
    @PostMapping
    public Producto crear(@RequestBody Producto producto) {
        return productosService.save(producto);
    }
}
```

### Desde el frontend Vue:

```vue
<script setup>
import { ref, onMounted } from 'vue'

const productos = ref([])

onMounted(async () => {
  const response = await fetch('/api/productos')
  productos.value = await response.json()
})
</script>

<template>
  <div>
    <h1>Productos</h1>
    <ul>
      <li v-for="p in productos" :key="p.id">{{ p.nombre }}</li>
    </ul>
  </div>
</template>
```

## Para Producción

1. Build del frontend:
   ```bash
   pnpm frontend:build
   ```

2. Build del backend (incluye frontend):
   ```bash
   cd backend && mvn clean package
   ```

3. Ejecutar:
   ```bash
   java -jar backend/target/backend.jar --spring.profiles.active=prod
   ```

El JAR resultante contiene:
- ✅ Backend Spring Boot
- ✅ Frontend compilado (en static/)
- ✅ Template Thymeleaf
- ✅ Controlador SPA

Todo se sirve desde un único JAR en puerto 8080.

## Referencias

- [Vite Configuration](https://vitejs.dev/config/)
- [Vue.js Documentation](https://vuejs.org/)
- [Vue Router](https://router.vuejs.org/)
- [Spring Boot Static Resources](https://spring.io/guides/gs/serving-web-content/)
- [Thymeleaf](https://www.thymeleaf.org/)
