FROM alpine:latest

# Instalace cronu
RUN apk add --no-cache dcron

# Zkopírování definice cron úlohy
COPY crontab /etc/crontabs/root
# Nastavení správných oprávnění pro crontab
RUN chmod 0644 /etc/crontabs/root

# Vytvoření log adresáře
RUN mkdir -p /var/log/cron

# Blokování AWS metadata service
RUN echo '#!/bin/sh' > /usr/local/bin/block-metadata.sh && \
    echo 'iptables -A OUTPUT -d 169.254.169.254 -j REJECT' >> /usr/local/bin/block-metadata.sh && \
    chmod +x /usr/local/bin/block-metadata.sh

# Spuštění cron démona v popředí při startu kontejneru s logováním
# CMD ["crond", "-f", "-l", "8"]
CMD ["crond", "-f", "-l", "2", "-L", "/var/log/cron.log"]