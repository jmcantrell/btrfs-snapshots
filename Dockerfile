FROM docker.io/ubuntu:latest
RUN apt-get update -y
RUN apt-get install -y parallel

ENV TESTS_VERBOSE 1

WORKDIR /usr/src/app

COPY . .
RUN ./scripts/test
