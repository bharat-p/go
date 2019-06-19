FROM golang:1.12

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs closure-compiler
RUN npm install -g typescript sass

RUN mkdir -p /home/appuser
WORKDIR /home/appuser
COPY . .
RUN make ALL
RUN CGO_ENABLED=0 go build -v -o go-links .

FROM alpine:latest
WORKDIR /root/
RUN apk add --no-cache tini
# Tini is now available at /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]
COPY --from=0 /home/appuser/go-links .
CMD ["./go-links", "--data=/data", "--addr=:80"]
