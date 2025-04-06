# === Build Stage ===
FROM maven:3.9.3-eclipse-temurin-17 AS base
WORKDIR /app
COPY . .
RUN mvn clean package

# === Set version inside container ===
ARG VERSION
RUN mvn versions:set -DnewVersion=$VERSION && \
    mvn versions:commit

# === Stage 1: Clean and Test ===
FROM base AS test
RUN mvn clean test

# === Stage 2: Build JAR after successful tests ===
FROM base AS build
RUN mvn clean package

# === Runtime Stage ===
FROM eclipse-temurin:17-jdk-alpine AS runtime
WORKDIR /app

# Create a non-root user and use it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]

# Add health check (adjust the port if needed)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget -q --spider http://localhost:8080/ || exit 1
