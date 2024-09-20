#!/bin/bash

# Langkah 1: Buat Folder Proyek
mkdir tora
cd tora

# Langkah 2: Masukkan Private Key
echo "Masukkan private key untuk transaksi aplikasi:"
read PRIV_KEY

# Langkah 3: Buat File .env
echo "Masukkan nilai untuk MAINNET_WSS:"
read MAINNET_WSS
echo "Masukkan nilai untuk MAINNET_HTTP:"
read MAINNET_HTTP
echo "Masukkan nilai untuk SEPOLIA_WSS:"
read SEPOLIA_WSS
echo "Masukkan nilai untuk SEPOLIA_HTTP:"
read SEPOLIA_HTTP

cat <<EOL > .env
############### Sensitive config ###############

# private key for sending out app-specific transactions
PRIV_KEY="${PRIV_KEY}"

############### General config ###############

# general - execution environment
TORA_ENV=production

# general - provider url
MAINNET_WSS="${MAINNET_WSS}"
MAINNET_HTTP="${MAINNET_HTTP}"
SEPOLIA_WSS="${SEPOLIA_WSS}"
SEPOLIA_HTTP="${SEPOLIA_HTTP}"

# redis global ttl, comment out -> no ttl limit
REDIS_TTL=86400000 # 1 day in ms 

############### App specific config ###############

# confirm - general
CONFIRM_CHAINS='["sepolia","mainnet"]'
CONFIRM_MODELS='[13]' # 13: OpenLM ,now only 13 supported

# confirm - crosscheck
CONFIRM_USE_CROSSCHECK=true
CONFIRM_CC_POLLING_INTERVAL=3000 # 3 sec in ms
CONFIRM_CC_BATCH_BLOCKS_COUNT=300 # default 300 means blocks in 1 hour on eth

# confirm - store ttl
CONFIRM_TASK_TTL=2592000000
CONFIRM_TASK_DONE_TTL=2592000000 # comment out -> no ttl limit
CONFIRM_CC_TTL=2592000000 # 1 month in ms
EOL

echo ".env file created successfully."

# Langkah 4: Buat File docker-compose.yml
cat <<EOL > docker-compose.yml
version: '3'
services:
  confirm:
    image: oraprotocol/tora:confirm
    container_name: ora-tora
    depends_on:
      - redis
      - openlm
    command: 
      - "--confirm"
    env_file:
      - .env
    environment:
      REDIS_HOST: 'redis'
      REDIS_PORT: 6379
      CONFIRM_MODEL_SERVER_13: 'http://openlm:5000/'
    networks:
      - private_network

  redis:
    image: oraprotocol/redis:latest
    container_name: ora-redis
    restart: always
    networks:
      - private_network

  openlm:
    image: oraprotocol/openlm:latest
    container_name: ora-openlm
    restart: always
    networks:
      - private_network

  diun:
    image: crazymax/diun:latest
    container_name: diun
    command: serve
    volumes:
      - "./data:/data"
      - "/var/run/docker.sock:/var/run/docker.sock"
    environment:
      - "TZ=Asia/Shanghai"
      - "LOG_LEVEL=info"
      - "LOG_JSON=false"
      - "DIUN_WATCH_WORKERS=5"
      - "DIUN_WATCH_JITTER=30"
      - "DIUN_WATCH_SCHEDULE=0 0 * * *"
      - "DIUN_PROVIDERS_DOCKER=true"
      - "DIUN_PROVIDERS_DOCKER_WATCHBYDEFAULT=true"
    restart: always

networks:
  private_network:
    driver: bridge
EOL

echo "docker-compose.yml file created successfully."

# Langkah 5: Jalankan Layanan Menggunakan Docker Compose
docker compose up -d

echo "All services are up and running!"
