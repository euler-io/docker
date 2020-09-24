ARG DOCKER_TAG=latest

FROM maven as builder

ARG DOCKER_TAG=latest

RUN mkdir /build && cd /build
COPY ./basic/pom.xml /build
COPY ./basic/download-dependencies.sh /build
COPY ./templates /build

# Download dependencies from com.github.euler-io:euler-elasticsearch:$EULER_VERSION
RUN /build/download-dependencies.sh

# Build templates configuration
RUN echo "templates: [" > /build/templates.conf \
    && cat /build/parse-files.conf >> /build/templates.conf \
    && echo "]" >> /build/templates.conf

FROM eulerio/euler-api-opendistro:$DOCKER_TAG

USER root

ENV EULER_OPTS=""

# Copy dependency to lib dir
COPY --from=builder /dependencies/* /app/lib/
COPY --from=builder /build/templates.conf /app/
RUN chown euler:euler -R /app
USER euler

CMD java -jar ${JAVA_OPTS} /app/opendistro-http-api.jar -classpath /app/lib com.github.euler.api.ESEulerHTTPAPI -Dconfig.file=/app/basic.conf ${EULER_OPTS}
