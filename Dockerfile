FROM eclipse-temurin:17-jdk-alpine AS builder
ENV APP_HOME=/usr/share/apps/sernfe
WORKDIR ${APP_HOME}
COPY mvnw .
RUN chmod +x mvnw
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN ./mvnw package -DskipTests
ARG JAR_FILE=target/*.jar
RUN cp ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM eclipse-temurin:17-jre-alpine
ENV APP_HOME=/usr/share/apps/sernfe
WORKDIR ${APP_HOME}
COPY --from=builder ${APP_HOME}/dependencies/ ./
COPY --from=builder ${APP_HOME}/spring-boot-loader/ ./
COPY --from=builder ${APP_HOME}/snapshot-dependencies/ ./
COPY --from=builder ${APP_HOME}/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]