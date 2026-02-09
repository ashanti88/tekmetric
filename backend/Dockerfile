#  Tekmetric Backend (Spring Boot)

# - Build the application using Maven
# - Produce a small, secure runtime image
# - Run as a non-root user
# - Allow runtime configuration via environment variables

# -----------------------
# BUILD STAGE
# -----------------------

FROM maven:3.9-eclipse-temurin-17 AS build

# Set working directory inside the container
WORKDIR /app

# COPY pom.xml first to leverage Docker layer caching
# REDOWNLOAD DEPENDENCIES ONLY IF pom.xml CHANGES
COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline

# COPY APPLICATION source code and BUILD the JAR
COPY src ./src
RUN mvn -q -DskipTests package

# -----------------------
# RUNTIME
# -----------------------
# A lightweight JRE image for running the application
# OR we can use: "gcr.io/distroless/java17-debian12" for faster builds and smaller image size (but has some tradeoffs)
FROM eclipse-temurin:17-jre  

# Application runtime directory
WORKDIR /app

# Create a non-root user for security
# Prepare writable directories in a single layer
RUN useradd -r -u 10001 -g root appuser \
  && mkdir -p /app /tmp \
  && chown -R 10001:0 /app /tmp

# Copy the built JAR from the build stage
COPY --from=build /app/target/interview-1.0-SNAPSHOT.jar /app/app.jar

# JVM defaults:
# - JAVA_OPTS is intentionally empty and overridden at runtime
# - JAVA_TOOL_OPTIONS sets safe defaults for containerized JVMs
ENV JAVA_OPTS="" \
    JAVA_TOOL_OPTIONS="-XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

# Expose the application port (Spring Boot default)
EXPOSE 8080

# Drop privileges and run as non-root user
USER 10001

# This ensures that SIGTERM and SIGINT signals (used by Docker and Kubernetes)
# are delivered directly to the Java process, allowing GRACEFUL SHUTDOWN.
ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]
