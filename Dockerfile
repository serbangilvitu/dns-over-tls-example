FROM docker.io/ubuntu:20.04

RUN apt-get update && \
    apt-get -y install curl knot-dnsutils golang-cfssl

COPY ./cfssl /cfssl