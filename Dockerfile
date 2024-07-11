FROM docker.repo.abc.com/eclipse:17-jdk-alpine

LABEL maintainer = "cep-az-rx"

ENV JAVA_HOME /opt/java/openjdk
RUN mkdir -P /target
