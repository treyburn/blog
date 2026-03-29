FROM docker.io/golang:1.24.2-alpine

ENV HUGO_VERSION=0.159.0-r0

# Prerequirements
RUN apk add --update --no-cache gcc musl-dev build-base git

# Compile from source
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo=${HUGO_VERSION}

WORKDIR /src

ENTRYPOINT ["hugo"]