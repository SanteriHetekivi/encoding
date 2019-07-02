FROM alpine:edge

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update \
    && apk add --no-cache handbrake \
    && apk add --no-cache python3 \
    && apk add --no-cache bash \
    && apk add --no-cache procps \
    && apk add --no-cache tzdata \
    && apk add --no-cache shadow \
    && apk add --no-cache gosu

COPY . /app

RUN addgroup --gid 911 app \
    && mkdir -p /usr/src/app \
    && adduser -u 911 -G app -h /usr/src/app -s /bin/bash -S app

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["python3", "/app/www/status.py"]