#!/bin/bash
# ==============================================================================
# init.sh — Post-Install Setup
# Detecta el SO y lanza el script correspondiente (macOS o Ubuntu/Debian)
# Ricardo Wagner & AntiGravity
#
# Uso:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Ricardowec51/Initial/main/init.sh)
# ==============================================================================

set -e

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

BASE_URL="https://raw.githubusercontent.com/Ricardowec51/Initial/main"

echo -e "${GREEN}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║          POST-INSTALL SETUP — Ricardo & AntiGravity     ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

OS="$(uname -s)"

case "$OS" in
    Darwin)
        echo -e "${GREEN}[>>]${NC}  macOS detectado. Lanzando init-script-mac.sh..."
        SCRIPT_URL="$BASE_URL/init-script-mac.sh"
        ;;
    Linux)
        if [[ -f /etc/debian_version ]]; then
            echo -e "${GREEN}[>>]${NC}  Ubuntu/Debian detectado. Lanzando init-script.sh..."
            SCRIPT_URL="$BASE_URL/init-script.sh"
        else
            echo -e "${RED}[ERR]${NC} Distro Linux no soportada (solo Ubuntu/Debian)."
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}[ERR]${NC} Sistema operativo no soportado: $OS"
        exit 1
        ;;
esac

TMP_SCRIPT="$(mktemp /tmp/init-setup-XXXX.sh)"
echo -e "${YELLOW}[>>]${NC}  Descargando script..."
curl -fsSL "$SCRIPT_URL" -o "$TMP_SCRIPT"
chmod +x "$TMP_SCRIPT"
bash "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"
