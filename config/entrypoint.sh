#!/bin/sh
set -e

CERT_DIR="/certs"
LOG_DIR="/config/var/log"
REMOTE_LOG_DIR="/var/log/remote"

# ===== UID/GID =====
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# ===== Generuj certy pokud neexistují =====
if [ ! -f "$CERT_DIR/server.crt" ] || [ ! -f "$CERT_DIR/server.key" ] || [ ! -f "$CERT_DIR/ca.crt" ]; then
  echo "[*] Generuji self-signed certifikáty..."

  # CA key
  if [ ! -f "$CERT_DIR/ca.key" ]; then
    openssl genrsa -out "$CERT_DIR/ca.key" 4096
  fi

  # CA cert
  openssl req -new -x509 -days 3650 \
    -key "$CERT_DIR/ca.key" \
    -out "$CERT_DIR/ca.crt" \
    -subj "/C=CZ/ST=Prague/L=Prague/O=WazuhProxy/CN=SyslogNG CA"

  # server key
  openssl genrsa -out "$CERT_DIR/server.key" 2048

  # server CSR
  openssl req -new -key "$CERT_DIR/server.key" \
    -out "$CERT_DIR/server.csr" \
    -subj "/C=CZ/ST=Prague/L=Prague/O=WazuhProxy/CN=${SERVER_HOSTNAME:-localhost}"

  # podepiš CSR
  openssl x509 -req -in "$CERT_DIR/server.csr" \
    -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
    -out "$CERT_DIR/server.crt" -days 365

  rm -f "$CERT_DIR/server.csr"

  # práva
  chown -R ${PUID}:${PGID} "${CERT_DIR}"
  chmod 640 "${CERT_DIR}/server.key" "${CERT_DIR}/ca.key"
  chmod 644 "${CERT_DIR}/server.crt" "${CERT_DIR}/ca.crt"

  echo "[*] Certy vygenerovány: $CERT_DIR/server.crt, $CERT_DIR/server.key, $CERT_DIR/ca.crt"
else
  echo "[*] Certy už existují, přeskakuji generaci."
fi

# ===== Vytvoření log adresáře =====
echo "[*] Ensuring log directory exists: ${LOG_DIR}"
mkdir -p "${LOG_DIR}"
chown -R ${PUID}:${PGID} "${LOG_DIR}"

# ===== Vytvoření remote log adresáře =====
echo "[*] Ensuring remote log directory exists: ${REMOTE_LOG_DIR}"
mkdir -p "${REMOTE_LOG_DIR}"
chown -R ${PUID}:${PGID} "${REMOTE_LOG_DIR}"
# chown root:root "${REMOTE_LOG_DIR}"
# chmod 750 "${REMOTE_LOG_DIR}"

# # ===== Spuštění syslog-ng =====
# echo "[*] Startuji syslog-ng..."
# exec syslog-ng -F --no-caps

echo "[*] Startuji syslog-ng..."
exec /init