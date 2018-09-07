FROM gcc:8.2.0 as builder

ARG KEEPALIVED_VER=2.0.7

RUN wget -qP /tmp http://www.keepalived.org/software/keepalived-${KEEPALIVED_VER}.tar.gz \
  && mkdir /tmp/k && tar xpzf /tmp/keepalived-${KEEPALIVED_VER}.tar.gz -C /tmp/k --strip-components=1 \
  && cd /tmp/k \
  && ./configure \
  && make

FROM debian:stretch-slim

ARG CONFD_VER=0.16.0

# python3-minimal, python3-requests, curl required for DigitalOcean assign-ip script
RUN apt-get update && apt-get install -y openssl python3-minimal python3-requests curl wget && rm -rf /var/lib/apt/lists/*
COPY --from=builder /tmp/k/keepalived/keepalived .

RUN wget -qO /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VER}/confd-${CONFD_VER}-linux-amd64 && chmod +x /usr/bin/confd
COPY etc /etc
RUN mkdir -p /etc/keepalived

# http://do.co/assign-ip
COPY assign-ip master.sh /
RUN chmod +x /master.sh

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/keepalived", "--dont-fork", "--log-console"]
