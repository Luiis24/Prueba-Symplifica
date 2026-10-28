# Etapa de construcción (Build)
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app

# Instalar Maven globalmente ya que el proyecto no incluye mvnw
RUN apk add --no-cache maven

# Copiar el archivo de dependencias y el código fuente
COPY pom.xml .
COPY src ./src

# Compilar el proyecto usando Maven global
RUN mvn clean package -DskipTests

# Etapa final de ejecución (Run)
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

# Copiar el JAR generado desde la etapa de construcción
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]