FROM docker.repo.abc.com/eclipse:17-jdk-alpine
RUN echo "https://repo1.uhc.com/artifactory/dl-cdn/v3.14/main" > /etc/apk/repositories
RUN cat /etc/apk/repositories
RUN apk update \
&& apk upgrade

LABEL maintainer = "cep-az-rx"

ENV JAVA_HOME /opt/java/openjdk
RUN mkdir -P /target
