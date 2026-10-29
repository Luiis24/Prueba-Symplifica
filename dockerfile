# --- ETAPA 1: Construir el Frontend (Vue.js / Vite) ---
FROM node:20-alpine AS frontend-build
WORKDIR /app-frontend

# Copiar el proyecto frontend completo (incluyendo vite.config.js)
COPY frontend/ ./
RUN npm install && npm run build

# --- ETAPA 2: Construir el Backend con Maven (Java 25) ---
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app
RUN apk add --no-cache maven

COPY backend/pom.xml .
COPY backend/src ./src

# Copiar los archivos compilados por Vite directamente desde donde los exportó 
# (Vite los envía a la ruta relativa del backend en la etapa anterior):
COPY --from=frontend-build /backend/src/main/resources/static ./src/main/resources/static

# Compilar el JAR ejecutable de Spring Boot con las vistas integradas
RUN mvn clean package -DskipTests

# --- ETAPA 3: Ejecución final ---
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]