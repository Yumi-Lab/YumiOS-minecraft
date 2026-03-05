# YumiOS Minecraft

Image OS préconfigurée pour transformer un **SmartPi One** en serveur Minecraft plug-and-play, avec panel web de management.

Basée sur [SmartPi-armbian](https://github.com/Yumi-Lab/SmartPi-armbian) + [CustomPiOS-Yumi](https://github.com/Maxime3d77/CustomPiOS-Yumi).

---

## Features

- **Dual moteur** : PaperMC (Java, survie complète) ou Pumpkin (Rust, ultra-léger)
- **Panel web** : [PufferPanel](https://pufferpanel.com/) — console temps réel, start/stop, mise à jour, édition de fichiers
- **Plug-and-play** : flash → boot → ouvrir le panel web → jouer
- **Config sans SSH** : fichier `minecraft-config.txt` sur la partition boot (FAT32)
- **Optimisé** : flags JVM Aikar, Paper tuning, swap + I/O optimisés pour SD card
- **Robuste** : auto-restart, anti-boot-loop, log rotation, shutdown gracieux

---

## Hardware

| Board | SoC | Architecture | RAM |
|-------|-----|-------------|-----|
| SmartPi One | AllWinner H3 (Cortex-A7) | armhf (32-bit) | 1 GB DDR3 |

---

## Quick Start

### 1. Télécharger l'image

Depuis la page [Releases](../../releases), télécharger le fichier `.img.xz` le plus récent.

### 2. Flasher sur SD card

```bash
# Avec dd (Linux/macOS)
xz -d YumiOS-minecraft-*.img.xz
sudo dd if=YumiOS-minecraft-*.img of=/dev/sdX bs=4M status=progress

# Ou utiliser Balena Etcher / Raspberry Pi Imager
```

**Recommandation** : SD card 16 Go minimum, Class 10 / U1 ou mieux.

### 3. Configuration (optionnel)

Avant d'insérer la SD card, éditez `minecraft-config.txt` sur la partition boot :

```bash
SERVER_TYPE=papermc        # papermc ou pumpkin
SERVER_NAME=Mon Serveur
MAX_PLAYERS=5
GAME_MODE=survival
DIFFICULTY=normal
VIEW_DISTANCE=6
```

### 4. Démarrer

1. Insérer la SD card dans le SmartPi One
2. Brancher l'Ethernet et l'alimentation
3. Attendre ~3-5 minutes (premier démarrage : téléchargement PaperMC)
4. Ouvrir le panel web : `http://<IP>:8080`
   - Login : `admin` / `yumi`
5. Se connecter depuis Minecraft : `<IP>:25565`

---

## Panel Web (PufferPanel)

Accessible sur le port **8080**. Permet de :

- Voir la console serveur en temps réel
- Démarrer / arrêter / redémarrer le serveur
- Changer de moteur (PaperMC ↔ Pumpkin)
- Mettre à jour la version Minecraft
- Éditer `server.properties` et les fichiers de config
- Gérer les fichiers du serveur via SFTP (port 5657)

**Identifiants par défaut** : `admin` / `yumi` (à changer au premier login)

---

## Moteurs serveur

### PaperMC (Java) — recommandé

- Survie complète : combat, mobs, redstone, enchantements
- Compatible avec les plugins Bukkit/Spigot/Paper
- Heap JVM : 512M-700M (optimisé pour 1 Go RAM)
- 3-5 joueurs simultanés recommandés

### Pumpkin (Rust) — expérimental

- Ultra-léger : ~100 Mo RAM au lieu de ~1 Go
- Démarrage quasi-instantané
- Supporte Java et Bedrock
- **Attention** : survie encore en développement (combat, mobs, redstone WIP)

---

## SSH

```bash
ssh pi@<IP>
# Mot de passe : yumi
```

Le MOTD affiche automatiquement :
- Statut du serveur Minecraft
- Adresse du panel web
- Version et infos système

### Commandes utiles

```bash
# Statut du serveur
sudo systemctl status minecraft

# Logs en temps réel
sudo journalctl -u minecraft -f

# Redémarrer le serveur
sudo systemctl restart minecraft

# Statut PufferPanel
sudo systemctl status pufferpanel
```

---

## Performance

Le SmartPi One (1 Go RAM, Cortex-A7) est un hardware contraint. Recommandations :

- **Max 3-5 joueurs** en survie (PaperMC)
- **view-distance=6** (réduction majeure de la charge)
- **Éviter les fermes automatiques** massives (entités = lag)
- **Les mondes plats** sont plus performants que les mondes normaux
- **Pumpkin** est significativement plus léger si les features manquantes ne sont pas bloquantes

---

## Configuration avancée

### server.properties

Éditable via le panel web ou directement :
```bash
sudo nano /opt/minecraft/server.properties
sudo systemctl restart minecraft
```

### Flags JVM

Modifiez `/opt/minecraft/server.env` :
```bash
MINECRAFT_XMS="512M"
MINECRAFT_XMX="700M"
JVM_FLAGS="..."  # Flags Aikar pré-configurés
```

### Paper tuning

Fichiers dans `/opt/minecraft/config/` :
- `paper-global.yml` — threads, timings, packet limiter
- `paper-world-defaults.yml` — mobs, chunks, redstone

---

## Build depuis les sources

```bash
# Build de test
gh workflow run BuildImages.yml

# Release officielle
gh workflow run Release.yml -f version=X.Y.Z
```

Le CI cross-compile automatiquement PufferPanel (Go) et Pumpkin (Rust) pour armhf.

---

## Troubleshooting

| Problème | Solution |
|----------|---------|
| Le serveur ne démarre pas | `sudo journalctl -u minecraft -e` — vérifier les logs |
| Impossible de se connecter | Vérifier que le port 25565 est accessible : `ss -tlnp \| grep 25565` |
| Panel web inaccessible | `sudo systemctl status pufferpanel` — port 8080 |
| RAM insuffisante / freezes | Réduire `view-distance` à 4, ou passer à Pumpkin |
| Premier boot très long | Normal : téléchargement PaperMC (~40 Mo) + génération du monde |
| Erreur téléchargement JAR | Vérifier la connexion internet, puis `sudo systemctl restart minecraft` |

---

## License

GNU General Public License v3.0 — voir [LICENSE](LICENSE).
