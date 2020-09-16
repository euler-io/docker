ARG DOCKER_TAG=latest

FROM maven as builder

ARG DOCKER_TAG=latest

# Download dependencies from com.github.euler-io:euler-elasticsearch:$EULER_VERSION
COPY pom.xml .
COPY download-dependencies.sh .
RUN ./download-dependencies.sh

FROM eulerio/euler-api-opendistro:$DOCKER_TAG

USER root

# Copy dependency to lib dir
COPY --from=builder /dependencies/* /app/lib/
RUN chown euler:euler -R /app/lib

USER euler
