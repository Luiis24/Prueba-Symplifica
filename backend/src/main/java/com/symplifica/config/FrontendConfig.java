package com.symplifica.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Controlador para manejar las rutas del SPA (Single Page Application) Vue.js
 *
 * Todas las rutas que no correspondan a recursos estáticos o APIs (/api/*)
 * serán redirigidas al index.html del frontend para que Vue Router maneje
 * la navegación del lado del cliente.
 *
 * Importante: el mapeo comodín NO debe "secuestrar" los recursos estáticos
 * (/js/**, /css/**, /images/**, favicon, etc.) ni los endpoints de actuator,
 * porque si no, Spring devuelve el index.html (HTML) donde el navegador
 * espera JS/CSS/JSON, rompiendo la aplicación en producción. Como un mapeo
 * @GetMapping("/**") tiene prioridad sobre el handler de recursos estáticos,
 * para esas rutas se sirve el recurso equivalente de forma explícita.
 *
 * Nota: en Spring Boot 4 la interfaz ErrorController se movió a
 * org.springframework.boot.webmvc.error y dejó de exponer getErrorPath(),
 * por lo que ya no es necesario implementarla aquí.
 */
@Controller
@RequestMapping("/")
public class FrontendConfig {

    private static final String INDEX = "index";

    /**
     * Maneja la ruta raíz y errores 404/500
     * Devuelve el archivo index.html para que Vue Router controle la navegación
     */
    @GetMapping({"", "/", "/error"})
    public String index() {
        return INDEX;
    }

    /**
     * Maneja todas las rutas del frontend que no son APIs ni recursos estáticos.
     *
     * Para rutas de API/actuator devolvemos 404 (no hay handler aquí). Para
     * recursos estáticos servimos el archivo real desde el classpath. Para
     * cualquier otra ruta devolvemos el index.html y que Vue Router navegue.
     */
    @GetMapping("/**")
    public Object forwardToIndex(HttpServletRequest request) {
        String path = request.getRequestURI();

        if (isApiOrActuator(path)) {
            return ResponseEntity.notFound().build();
        }

        if (isStaticResource(path)) {
            return serveStatic(path);
        }

        return INDEX;
    }

    private boolean isApiOrActuator(String path) {
        return path.startsWith("/api/") || path.startsWith("/actuator/");
    }

    /**
     * Determina si la ruta apunta a un recurso estático del frontend.
     */
    private boolean isStaticResource(String path) {
        return path.startsWith("/js/")
                || path.startsWith("/css/")
                || path.startsWith("/images/")
                || path.equals("/favicon.ico")
                || path.endsWith(".svg")
                || path.endsWith(".js")
                || path.endsWith(".css")
                || path.endsWith(".png")
                || path.endsWith(".ico")
                || path.endsWith(".map")
                || path.endsWith(".json");
    }

    /**
     * Sirve un recurso estático ubicado en src/main/resources/static.
     * Devuelve 404 si el archivo no existe.
     */
    private ResponseEntity<Resource> serveStatic(String path) {
        String relative = path.startsWith("/") ? path.substring(1) : path;
        Resource resource = new ClassPathResource("static/" + relative);

        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok()
                .contentType(mediaTypeFor(relative))
                .body(resource);
    }

    private MediaType mediaTypeFor(String path) {
        if (path.endsWith(".css")) {
            return MediaType.valueOf("text/css");
        }
        if (path.endsWith(".js")) {
            return MediaType.valueOf("application/javascript");
        }
        if (path.endsWith(".svg")) {
            return MediaType.valueOf("image/svg+xml");
        }
        if (path.endsWith(".png")) {
            return MediaType.IMAGE_PNG;
        }
        if (path.endsWith(".ico")) {
            return MediaType.valueOf("image/x-icon");
        }
        if (path.endsWith(".json")) {
            return MediaType.APPLICATION_JSON;
        }
        return MediaType.APPLICATION_OCTET_STREAM;
    }
}
