#!/bin/bash
set -e

enter_password() {
    local user_name=$1
    read -s -p "Enter ${user_name}'s password: " user_pwd
    read -s -p "Re-enter ${user_name}'s password: " user_pwd_verify
    if [ $user_pwd == $user_pwd_verify ]; then
        echo $user_pwd
        return 0
    else
        echo "Passwords for ${user_name} doesn't match."
        echo ""
        exit 1
    fi
}

interpolate() {
    local f=$1
    echo "Generating '${f}'."
    jinja2 ${f} /tmp/jinja.env -o /tmp/file.tmp
    cp /tmp/file.tmp ${f}
    rm /tmp/file.tmp
}

APP_VERSION=$(cat /etc/deploy/app_version)
OPENDISTRO_VERSION=$(cat /etc/deploy/opendistro_version)
echo ""
echo "Generating deployment files for version ${APP_VERSION}"
echo ""

/etc/deploy/generate_certificates.sh
echo ""

echo "Generating random jwt secret."
jwt_secret=$(pwgen -s 256 1 | base64 -w 0)
echo ""

echo "Generating random password for the Kibana server maintance tasks (kibanaserver)."
kibanaserver_pwd=$(pwgen -s 32 1 | base64 -w 0)
kibanaserver_pwd_hash=$(/usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p ${kibanaserver_pwd})
echo ""

echo "Create a password for the Opendistro Administrator user."
admin_pwd=$(enter_password admin)
admin_pwd_hash=$(/usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p ${admin_pwd})
echo ""

echo "Create a password for the Euler Administrator user."
euler_admin_pwd=$(enter_password euler-admin)
euler_admin_pwd_hash=$(/usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p ${euler_admin_pwd})
echo ""

echo "APP_VERSION=${APP_VERSION}" > /tmp/jinja.env
echo "OPENDISTRO_VERSION=${OPENDISTRO_VERSION}" >> /tmp/jinja.env
echo "PUBLIC_URL=https://${SERVER_NAME}" >> /tmp/jinja.env
echo "JWT_SECRET=${jwt_secret}" >> /tmp/jinja.env
echo "ADMIN_PWD_HASH=${admin_pwd_hash}" >> /tmp/jinja.env
echo "EULER_ADMIN_PWD=${euler_admin_pwd}" >> /tmp/jinja.env
echo "EULER_ADMIN_PWD_HASH=${euler_admin_pwd_hash}" >> /tmp/jinja.env
echo "KIBANA_SERVER_PWD=${kibanaserver_pwd}" >> /tmp/jinja.env
echo "KIBANA_SERVER_PWD_HASH=${kibanaserver_pwd_hash}" >> /tmp/jinja.env
echo "NODES=${NODES}" >> /tmp/jinja.env
echo "SERVER_NAME=${SERVER_NAME}" >> /tmp/jinja.env

cp -f /etc/deploy/docker-compose-base.yml /output/docker-compose-base.yml
interpolate /output/docker-compose-base.yml

mkdir -p ${OUTPUT}/config
cp -f /etc/deploy/config/* ${OUTPUT}/config

for f in $(find ${OUTPUT}/config -type f); do
    interpolate ${f}
done

rm /tmp/jinja.env

echo ""
echo "There are other important configurations at :"
echo " - https://opendistro.github.io/for-elasticsearch-docs/docs/install/docker/#important-settings "
echo " - https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html "
echo " - https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-prod-prerequisites "
echo ""
echo "You have to manually create the necessary volumes. For example:"
echo "    docker volume create cases-data"
echo "    docker volume create iped-data:/path/to/data/to/be/indexed"
echo "    docker volume create esdata-1"
echo "    docker volume create esdata-2"
echo "    docker volume create esdata-3"
echo ""
echo "You can also edit/extend the file docker-compose-base.yml and define the volumes configurations."
echo ""
echo "The services admin-api and search-api run as user and group iped:iped (uid 1100 and gid 1100)."
echo "You must set the volumes (cases-data and iped-data) ownership accordingly."
echo ""
echo "To run the app type: 'docker stack deploy -c docker-compose-base.yml iped'"
