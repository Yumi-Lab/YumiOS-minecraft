#!/bin/bash
# YumiOS Minecraft — script de démarrage serveur PaperMC
# Le JAR est pré-téléchargé pendant le build de l'image

set -euo pipefail

ENV_FILE="/opt/minecraft/server.env"
JAR="/opt/minecraft/server.jar"
LOG="/opt/minecraft/start-server.log"

# Charger les variables d'environnement (heap, flags JVM)
if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
fi

# Valeurs par défaut si server.env absent ou incomplet
: "${MINECRAFT_XMS:=512M}"
: "${MINECRAFT_XMX:=700M}"
: "${JVM_FLAGS:=}"

log() {
    echo "[YumiOS Minecraft] $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${LOG}"
}

# Vérifier que le JAR existe
if [ ! -f "${JAR}" ]; then
    log "ERREUR: ${JAR} introuvable. L'image a peut-être été mal buildée."
    exit 1
fi

log "Démarrage du serveur Minecraft (heap: ${MINECRAFT_XMS}/${MINECRAFT_XMX})..."

# shellcheck disable=SC2086
exec java \
    -Xms"${MINECRAFT_XMS}" \
    -Xmx"${MINECRAFT_XMX}" \
    ${JVM_FLAGS} \
    -jar "${JAR}" nogui
