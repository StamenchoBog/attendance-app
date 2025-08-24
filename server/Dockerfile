# Build stage
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

COPY gradle gradle/
COPY gradlew build.gradle settings.gradle ./
RUN chmod +x ./gradlew

# Cache Gradle dependencies
RUN --mount=type=cache,target=/home/gradle/.gradle \
    ./gradlew dependencies --no-daemon

COPY src src/

# Build the application JAR
RUN --mount=type=cache,target=/home/gradle/.gradle \
    ./gradlew bootJar --no-daemon

# Create minimal JRE
FROM eclipse-temurin:21-jdk-alpine AS jre-builder
WORKDIR /opt
USER root
RUN jlink \
    --module-path "$JAVA_HOME/jmods" \
    --add-modules java.compiler,java.logging,java.sql,java.rmi,java.naming,java.management,java.instrument,java.security.jgss,java.net.http,jdk.httpserver,jdk.naming.dns,java.desktop \
    --verbose \
    --strip-debug \
    --compress zip-6 \
    --no-header-files \
    --no-man-pages \
    --output /opt/jre-minimal

# Runtime stage
FROM alpine:3.21 AS runtime
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built JAR and minimal JRE
COPY --from=builder /app/build/libs/*.jar app.jar
COPY --from=jre-builder /opt/jre-minimal /opt/jre-minimal

ENV JAVA_HOME=/opt/jre-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"

RUN chown appuser:appgroup /app

USER appuser
EXPOSE 8080

# JVM settings
ENV JAVA_OPTS="-XX:MaxRAMPercentage=85.0 -XX:+UseContainerSupport -XX:+UseG1GC -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["java", "-jar", "app.jar"]