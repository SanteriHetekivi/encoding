FROM alpine:edge

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update \
    && apk add --no-cache handbrake \
    && apk add --no-cache python3 \
    && apk add --no-cache bash \
    && apk add --no-cache procps \
    && apk add --no-cache tzdata

COPY . /app

CMD ["python3", "/app/www/status.py"]