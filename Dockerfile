# === Build Stage ===
FROM maven:3.9.3-eclipse-temurin-17 AS base
WORKDIR /app
COPY . .
RUN mvn clean package

# === Stage 1: Clean and Test ===
FROM base AS test
RUN mvn clean test

# === Stage 2: Build JAR after successful tests ===
FROM base AS build
RUN mvn clean package

# === Runtime Stage ===
FROM eclipse-temurin:17-jdk-alpine AS runtime
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]

