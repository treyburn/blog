FROM golang:1.24.2-alpine AS base

RUN apk add --update --no-cache gcc musl-dev build-base git
RUN CGO_ENABLED=1 go install -tags extended,withdeploy github.com/gohugoio/hugo@v0.147.1

WORKDIR /src

ENTRYPOINT ["hugo"]