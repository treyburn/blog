FROM golang:1.24.2-bookworm

ENV HUGO_VERSION=0.147.1
ENV DART_SASS_VERSION=1.87.0

# Install PostCSS deps
RUN apt update

# install Dart-SASS deps
RUN curl -LJO https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz
RUN tar -xf dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz
RUN cp -r dart-sass/* /usr/local/bin
RUN rm -rf dart-sass*

# install hugo from source
RUN curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb
RUN apt install -y ./hugo_extended_${HUGO_VERSION}_linux-amd64.deb
RUN rm hugo_extended_${HUGO_VERSION}_linux-amd64.deb

WORKDIR /src

ENTRYPOINT ["hugo"]