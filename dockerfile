# --- ETAPA 1: Construir el Frontend directamente en el Backend ---
FROM node:20-alpine AS frontend-build
WORKDIR /app-frontend
COPY frontend/ ./
RUN npm install && npm run build

# --- ETAPA 2: Construir el Backend con Maven (Java 25) ---
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app
RUN apk add --no-cache maven

COPY backend/pom.xml .
COPY backend/src ./src

# Como Vite ya exportó los archivos estáticos en la etapa anterior directamente 
# a la ruta relativa del backend, los copiamos desde allá:
COPY --from=frontend-build /app-frontend/backend/src/main/resources/static ./src/main/resources/static

# Compilar el JAR final con todo integrado
RUN mvn clean package -DskipTests

# --- ETAPA 3: Ejecución final ---
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]