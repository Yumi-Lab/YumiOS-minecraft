# YumiOS Minecraft

Image OS préconfigurée pour serveur Minecraft sur **SmartPi One** (AllWinner H3, armhf).

Basée sur [SmartPi-armbian](https://github.com/Yumi-Lab/SmartPi-armbian) + [CustomPiOS-Yumi](https://github.com/Maxime3d77/CustomPiOS-Yumi).

---

## Hardware cible

| Hardware | SoC | Arch | RAM |
|----------|-----|------|-----|
| SmartPi One | AllWinner H3 (Cortex-A7) | armhf (32-bit) | 1 GB DDR3 |

---

## Serveur Minecraft

- **Type** : PaperMC (téléchargé au premier démarrage)
- **Java** : OpenJDK 21
- **Heap** : `-Xms512M -Xmx768M`
- **Swap** : 1 GB activé automatiquement

## Flash & connexion

```bash
# Flash
sudo dd if=<image>.img of=/dev/sdX bs=4M status=progress

# SSH (premier démarrage)
ssh pi@<ip>
# password: yumi

# Statut serveur
sudo systemctl status minecraft
```

## Build local

```bash
# Test build
gh workflow run BuildImages.yml

# Release
gh workflow run Release.yml -f version=X.Y.Z
```
