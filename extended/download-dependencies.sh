#!/bin/bash
set -e

if [[ ${DOCKER_TAG} == 'latest' || ${DOCKER_TAG} == 'dev' ]]; then
	depVersion=$(curl -s https://repo1.maven.org/maven2/com/github/euler-io/euler-elasticsearch/maven-metadata.xml | grep '<latest>' | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/")
else
	depVersion=$DOCKER_TAG
fi
echo "Using: $depVersion"

mkdir /dependencies
mvn dependency:copy-dependencies -Deuler.version=${depVersion} -DdownloadSources=false -DdownloadJavadocs=false -DincludeScope=runtime -DoutputDirectory=/dependencies -f $(dirname "$(readlink -f "$0")")/pom.xml
