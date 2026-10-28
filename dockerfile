# Etapa de construcción (Build) si el proyecto usa Maven o Gradle con wrapper
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY . .
# Si usa Maven: ./mvnw clean package -DskipTests
# Si usa Gradle: ./gradlew build -x test
RUN ./mvnw clean package -DskipTests

# Etapa final de ejecución
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Copia el JAR generado (ajusta el nombre del jar si es necesario)
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]