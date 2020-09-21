ARG OPENDISTRO_VERSION=latest
FROM amazon/opendistro-for-elasticsearch:${OPENDISTRO_VERSION}

ARG APP_VERSION
ARG OPENDISTRO_VERSION=latest

ENV OUTPUT="/output"
ENV NODES=3
ENV NODE_NAME_PREDICATE="opendistro-"
ENV SERVER_NAME="localhost"

RUN mkdir -p /etc/deploy/config

COPY generate_certificates.sh /etc/deploy

RUN touch /var/lib/rpm/* \
    && yum update -y \
    && yum install -y deltarpm \
    && yum -y install openssl pwgen python-pip \
    && pip --proxy ${HTTP_PROXY}} install jinja2-cli \
    && pip --proxy ${HTTP_PROXY}} install --upgrade pip \
    && yum clean all \
    && chmod +x /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh \
    && echo ${OPENDISTRO_VERSION} > /etc/deploy/opendistro_version \
    && rm /tmp/set_proxy.sh

COPY deploy.sh /etc/deploy
COPY docker-compose-base.yml /etc/deploy
COPY ./config/* /etc/deploy/config/

RUN chmod +x /etc/deploy/generate_certificates.sh \
    && chmod +x /etc/deploy/deploy.sh

VOLUME /output
WORKDIR /output

CMD /etc/deploy/deploy.sh
