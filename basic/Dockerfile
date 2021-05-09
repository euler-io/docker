ARG DOCKER_TAG=latest

FROM maven as builder

ARG DOCKER_TAG=latest

RUN mkdir /build && cd /build
COPY ./basic/pom.xml /build
COPY ./basic/download-dependencies.sh /build
COPY ./templates /build

COPY ./basic/reference.conf /build
RUN cd /build \
    && jar cvf basic-config.jar reference.conf

# Download dependencies from com.github.euler-io:euler-elasticsearch:$EULER_VERSION
RUN /build/download-dependencies.sh

# Build templates configuration
RUN echo "templates: [" > /build/templates.conf \
    && cat /build/parse-files.conf >> /build/templates.conf \
    && cat /build/add-new-files.conf >> /build/templates.conf \
    && cat /build/delete-files.conf >> /build/templates.conf \
    && cat /build/update-files.conf >> /build/templates.conf \
    && echo "]" >> /build/templates.conf

FROM eulerio/euler-api-opendistro:$DOCKER_TAG

ENV JAVA_OPTS=""
ENV APP_ARGS=""

USER root

# Copy dependencies to lib dir
COPY --from=builder /dependencies/* /app/lib/
COPY --from=builder /build/templates.conf /app/
COPY --from=builder /build/basic-config.jar /app/lib
RUN chown euler:euler -R /app
USER euler

CMD java -Dloader.path=/app/lib ${JAVA_OPTS} -jar /app/opendistro-http-api.jar ${APP_ARGS}
