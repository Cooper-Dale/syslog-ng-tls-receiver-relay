FROM linuxserver/syslog-ng:latest

# doinstalujeme openssl
RUN apk add --no-cache openssl

# zkopíruj vlastní entrypoint a konfiguraci
COPY config/entrypoint.sh /custom-entrypoint.sh
COPY config/syslog-ng.conf /config/syslog-ng.conf

RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
