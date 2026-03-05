#!/bin/bash
# YumiOS Minecraft — script de démarrage serveur PaperMC
# Télécharge le jar PaperMC au premier démarrage s'il est absent

set -euo pipefail

ENV_FILE="/opt/minecraft/server.env"
JAR="/opt/minecraft/server.jar"
LOG="/opt/minecraft/start-server.log"

# Charger les variables d'environnement (heap, flags JVM, version MC)
if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
fi

# Valeurs par défaut si server.env absent ou incomplet
: "${MC_VERSION:=1.21.4}"
: "${MINECRAFT_XMS:=512M}"
: "${MINECRAFT_XMX:=700M}"
: "${JVM_FLAGS:=}"

log() {
    echo "[YumiOS Minecraft] $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${LOG}"
}

# Téléchargement PaperMC avec retry
download_papermc() {
    local max_retries=3
    local retry_delay=10
    local attempt

    for attempt in $(seq 1 ${max_retries}); do
        log "Téléchargement PaperMC ${MC_VERSION} (tentative ${attempt}/${max_retries})..."

        # Récupérer le numéro de build
        local build
        build=$(curl -sf --connect-timeout 10 --max-time 30 \
            "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds" \
            | python3 -c "import sys,json; builds=json.load(sys.stdin)['builds']; print(builds[-1]['build'])" 2>/dev/null) || true

        if [ -z "${build}" ] || ! [[ "${build}" =~ ^[0-9]+$ ]]; then
            log "Échec récupération du numéro de build (tentative ${attempt})"
            [ "${attempt}" -lt "${max_retries}" ] && sleep "${retry_delay}"
            continue
        fi

        # Télécharger le JAR
        wget -q --show-progress --connect-timeout=10 --timeout=120 -O "${JAR}.tmp" \
            "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${build}/downloads/paper-${MC_VERSION}-${build}.jar" || true

        # Valider le téléchargement (> 1 Mo)
        local filesize
        filesize=$(stat -c%s "${JAR}.tmp" 2>/dev/null || echo 0)
        if [ "${filesize}" -gt 1048576 ]; then
            mv "${JAR}.tmp" "${JAR}"
            echo "eula=true" > /opt/minecraft/eula.txt
            log "Téléchargement terminé (build ${build}, ${filesize} octets)."
            return 0
        fi

        log "Fichier téléchargé trop petit (${filesize} octets), invalide."
        rm -f "${JAR}.tmp"
        [ "${attempt}" -lt "${max_retries}" ] && sleep "${retry_delay}"
    done

    log "ERREUR: Impossible de télécharger PaperMC après ${max_retries} tentatives."
    log "Vérifiez la connexion internet et réessayez: systemctl restart minecraft"
    return 1
}

# Premier démarrage : télécharger PaperMC
if [ ! -f "${JAR}" ]; then
    log "Premier démarrage — serveur JAR absent."
    download_papermc
fi

# Vérifier que le JAR existe avant de lancer Java
if [ ! -f "${JAR}" ]; then
    log "ERREUR: ${JAR} introuvable. Arrêt."
    exit 1
fi

log "Démarrage du serveur Minecraft (heap: ${MINECRAFT_XMS}/${MINECRAFT_XMX})..."

# shellcheck disable=SC2086
exec java \
    -Xms"${MINECRAFT_XMS}" \
    -Xmx"${MINECRAFT_XMX}" \
    ${JVM_FLAGS} \
    -jar "${JAR}" nogui
