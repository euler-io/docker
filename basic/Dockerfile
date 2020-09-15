ARG BASE_IMAGE=eulerio/euler-api-opendistro:latest

FROM maven as builder

ARG EULER_VERSION

# Download dependencies from com.github.euler-io:euler-elasticsearch:$EULER_VERSION
COPY pom.xml .
RUN mkdir /dependencies \
    && mvn dependency:copy-dependencies -Deuler.version=${EULER_VERSION} -DoutputDirectory=/dependencies -f ./pom.xml

FROM $BASE_IMAGE

USER root

# Copy dependency to lib dir
COPY --from=builder /dependencies/* /app/lib/
RUN chown euler:euler -R /app/lib

USER euler
