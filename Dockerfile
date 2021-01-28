FROM golang:1.15.7-buster

RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install -y make npm \
    && npm install -g yarn \
    && alias yarn=yarnpkg

ENV GOPROXY https://goproxy.cn,direct
ENV CGO_ENABLED 0

ADD . /build

WORKDIR /build

RUN yarn config set ignore-engines true \
    && make gocron


FROM alpine:3.13.0

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache ca-certificates tzdata \
    && addgroup -S app \
    && adduser -S -g app app

ENV LANG C.UTF-8
ENV TZ Asia/Shanghai

WORKDIR /app

COPY --from=0 /build/bin/gocron .

RUN chown -R app:app ./

EXPOSE 8080

USER app

ENTRYPOINT ["/app/gocron"]

CMD ["web", "-p", "8080"]
