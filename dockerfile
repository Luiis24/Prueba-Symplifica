# --- ETAPA 1: Construir el Frontend (Vue.js) ---
FROM node:20-alpine AS frontend-build
WORKDIR /app-frontend
COPY frontend/ ./
RUN npm install && npm run build

# --- ETAPA 2: Construir el Backend (Spring Boot con Java 25) ---
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app
RUN apk add --no-cache maven

COPY backend/pom.xml .
COPY backend/src ./src

# Copiar los archivos compilados del frontend (dist) hacia la carpeta static de Spring Boot
COPY --from=frontend-build /app-frontend/dist ./src/main/resources/static

# Compilar el JAR final que ya incluirá todo el frontend estilizado
RUN mvn clean package -DskipTests

# --- ETAPA 3: Ejecución final ---
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]