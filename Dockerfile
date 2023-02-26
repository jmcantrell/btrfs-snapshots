FROM docker.io/archlinux:latest
RUN pacman -Sy --noconfirm parallel diffutils

WORKDIR /usr/src/app

COPY . .
RUN ./scripts/test
