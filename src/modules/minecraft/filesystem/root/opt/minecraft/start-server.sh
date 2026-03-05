#!/bin/bash
# YumiOS Minecraft — script de démarrage serveur PaperMC
# Télécharge le jar PaperMC au premier démarrage s'il est absent

JAR="/opt/minecraft/server.jar"

if [ ! -f "$JAR" ]; then
    echo "[YumiOS Minecraft] Premier démarrage — téléchargement de PaperMC..."
    MC_VERSION="1.21.4"

    BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds" \
        | python3 -c "import sys,json; builds=json.load(sys.stdin)['builds']; print(builds[-1]['build'])")

    wget -O "$JAR" \
        "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${BUILD}/downloads/paper-${MC_VERSION}-${BUILD}.jar"

    echo "eula=true" > /opt/minecraft/eula.txt
    echo "[YumiOS Minecraft] Téléchargement terminé."
fi

exec java -Xms512M -Xmx768M -jar "$JAR" nogui
