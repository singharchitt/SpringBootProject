FROM bellsoft/liberica-openjdk-alpine:22 AS build
WORKDIR /workspace/app

# Copying the meta data
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Building the jar
RUN ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM bellsoft/liberica-openjdk-alpine:22
VOLUME /tmp
# slicing the jar for more optimised run
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# copy private key for firebase auth
COPY private-key.json /app/.

ENTRYPOINT ["java","-cp","app:app/lib/*","com.bharat.backendAssignment.BackendAssignmentApplication"]