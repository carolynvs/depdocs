FROM alpine:3.1

ARG HUGO_VERSION=0.30.2

# Install HUGO
RUN apk add --update wget ca-certificates && \
    mkdir -p /tmp/hugo && cd /tmp/hugo && \
    wget https://github.com/gohugoio/hugo/releases/download/v0.30.2/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    tar -xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/local/bin/hugo && \
    rm -r /tmp/hugo && \
    apk del wget ca-certificates && \
    rm /var/cache/apk/*

ENTRYPOINT ["/usr/local/bin/hugo"]
