FROM alpine:latest

# Instalace cronu
RUN apk add --no-cache dcron

# Zkopírování definice cron úlohy
COPY crontab /etc/crontabs/root

# Spuštění cron démona v popředí při startu kontejneru
CMD ["crond", "-f", "-l", "8"]


