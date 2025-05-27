FROM docker.io/golang:1.24.2-alpine

ENV HUGO_VERSION=0.147.1

# Prerequirements
RUN apk add --update --no-cache gcc musl-dev build-base git

# Compile from source
RUN CGO_ENABLED=1 go install -tags extended,withdeploy github.com/gohugoio/hugo@v${HUGO_VERSION}

WORKDIR /src

ENTRYPOINT ["hugo"]