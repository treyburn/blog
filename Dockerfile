# Official Hugo image (Alpine-based, extended build with dart-sass).
# Tags: https://github.com/gohugoio/hugo/pkgs/container/hugo
FROM ghcr.io/gohugoio/hugo:v0.165.0

# Image tooling beyond what Hugo ships. Root only for the install; the base
# image's non-root `hugo` user is restored below.
USER root
RUN apk add --no-cache jpegoptim optipng gifsicle
USER hugo
