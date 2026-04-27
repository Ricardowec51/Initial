#!/bin/bash
# ==============================================================================
# Script Post-Instalación macOS (Apple Silicon & Intel)
# Ricardo Wagner & AntiGravity
# ==============================================================================

# Colores
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# Estado de pasos
declare -A STEP_STATUS
for i in $(seq 1 10); do STEP_STATUS[$i]="--"; done

log()  { echo -e "${GREEN}[OK]${NC}  $1"; }
warn() { echo -e "${YELLOW}[>>]${NC}  $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; }
sep()  { echo -e "\n${CYAN}── $1${NC}"; }

# No correr como root
[[ $EUID -eq 0 ]] && echo -e "${RED}No ejecutar como root.${NC}" && exit 1

# Activar Homebrew en la sesión actual
_brew_init() {
    if [[ $(uname -m) == 'arm64' ]]; then
        [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
    fi
}
_brew_init

CURRENT_USER=$(whoami)

# ------------------------------------------------------------------------------
# Resumen
# ------------------------------------------------------------------------------
print_summary() {
    echo -e "\n${BLUE}${BOLD}┌──────────────────────────────────────────────────────────┬────────────┐${NC}"
    echo -e "${BLUE}${BOLD}│ Paso                                                     │  Estado    │${NC}"
    echo -e "${BLUE}${BOLD}├──────────────────────────────────────────────────────────┼────────────┤${NC}"
    local steps=(
        "1|Instalar Homebrew"
        "2|Actualizar sistema y paquetes"
        "3|Instalar herramientas base"
        "4|Instalar utilitarios modernos (eza, bat, fzf, zoxide)"
        "5|Ajustar hora (Ecuador)"
        "6|Instalar Zsh Pro (p10k + herramientas)"
        "7|Añadir nuevo usuario"
        "8|Tweaks de macOS (Finder, Dock, etc.)"
        "9|Instalar Docker (OrbStack)"
        "10|Instalar Portainer CE"
    )
    for entry in "${steps[@]}"; do
        local num="${entry%%|*}"
        local desc="${entry##*|}"
        local status="${STEP_STATUS[$num]}"
        if [[ "$status" == "OK" ]]; then
            printf "│ %-56s │ ${GREEN}%-10s${NC} │\n" "$desc" "✔ OK"
        elif [[ "$status" == "ERR" ]]; then
            printf "│ %-56s │ ${RED}%-10s${NC} │\n" "$desc" "✘ Error"
        else
            printf "│ %-56s │ %-10s │\n" "$desc" "  --"
        fi
    done
    echo -e "${BLUE}${BOLD}└──────────────────────────────────────────────────────────┴────────────┘${NC}"
}

print_sysinfo() {
    echo -e "\n${GREEN}${BOLD}══════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}        Resumen del Sistema               ${NC}"
    echo -e "${GREEN}${BOLD}══════════════════════════════════════════${NC}"
    echo "  Hostname:    $(hostname)"
    echo "  Usuario:     $CURRENT_USER"
    echo "  S.O.:        $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "  Chip:        $(uname -m) — $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'Apple Silicon')"
    echo -e "\n  Disco (/):"
    df -h / | tail -1 | awk '{printf "    Tamaño: %s | Usado: %s | Libre: %s | Uso: %s\n",$2,$3,$4,$5}'
    echo -e "\n  Memoria:"
    local mem_total=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    echo "    Total: ${mem_total}GB"
    echo -e "\n  Red:"
    echo "    IP Local:   $(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo 'N/A')"
    echo "    IP Externa: $(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo 'N/A')"
    echo -e "${GREEN}${BOLD}══════════════════════════════════════════${NC}\n"
}

run_step() {
    local num="$1"
    "paso${num}" && STEP_STATUS[$num]="OK" || { STEP_STATUS[$num]="ERR"; err "El paso $num falló."; }
}

# ------------------------------------------------------------------------------
# Pasos
# ------------------------------------------------------------------------------
paso1() {
    sep "Paso 1: Homebrew"
    if command -v brew &>/dev/null; then
        log "Homebrew ya instalado ($(brew --version | head -1))."
    else
        warn "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        _brew_init
        log "Homebrew instalado."
    fi
}

paso2() {
    sep "Paso 2: Actualizar sistema"
    _brew_init
    warn "Actualizando Homebrew y paquetes..."
    brew update && brew upgrade
    brew cleanup
    log "Sistema actualizado."
}

paso3() {
    sep "Paso 3: Herramientas base"
    _brew_init
    local tools=(git wget curl htop fastfetch jq tree watch)
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null 2>&1; then
            log "$tool ya instalado"
        else
            warn "Instalando $tool..."
            brew install "$tool"
        fi
    done
    log "Herramientas base listas."
}

paso4() {
    sep "Paso 4: Utilitarios modernos"
    _brew_init
    local tools=(eza bat fzf zoxide)
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null 2>&1; then
            log "$tool ya instalado"
        else
            warn "Instalando $tool..."
            brew install "$tool"
        fi
    done
    log "Utilitarios modernos listos."
}

paso5() {
    sep "Paso 5: Zona horaria (Ecuador)"
    sudo systemsetup -settimezone America/Guayaquil 2>/dev/null \
        || sudo ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime
    sudo systemsetup -setusingnetworktime on 2>/dev/null || true
    log "Hora → $(date)"
}

paso6() {
    sep "Paso 6: Zsh Pro (Oh My Zsh + Powerlevel10k + eza/bat/fzf/zoxide)"
    local ZSH_SCRIPT_URL="https://raw.githubusercontent.com/Ricardowec51/DevOps/main/bin/setup-zsh-mac.sh"
    local TMP_ZSH="/tmp/setup-zsh-mac.sh"

    warn "Descargando script de configuración Zsh..."
    curl -fsSL "$ZSH_SCRIPT_URL" -o "$TMP_ZSH"
    chmod +x "$TMP_ZSH"
    bash "$TMP_ZSH"
    rm -f "$TMP_ZSH"
    log "Zsh Pro instalado. Ejecuta 'p10k configure' en la próxima sesión."
}

paso7() {
    sep "Paso 7: Nuevo usuario"
    read -rp "  Nombre del nuevo usuario: " newuser
    if [[ -z "$newuser" ]]; then
        warn "No se ingresó nombre. Paso omitido."; return 0
    fi
    if id "$newuser" &>/dev/null; then
        log "El usuario '$newuser' ya existe."
    else
        local uid_next=$(( $(dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1) + 1 ))
        sudo dscl . -create /Users/"$newuser"
        sudo dscl . -create /Users/"$newuser" UserShell /bin/zsh
        sudo dscl . -create /Users/"$newuser" RealName "$newuser"
        sudo dscl . -create /Users/"$newuser" UniqueID "$uid_next"
        sudo dscl . -create /Users/"$newuser" PrimaryGroupID 20
        sudo dscl . -create /Users/"$newuser" NFSHomeDirectory /Users/"$newuser"
        sudo createhomedir -c -u "$newuser" 2>/dev/null
        sudo dscl . -append /Groups/admin GroupMembership "$newuser"
        sudo dscl . -passwd /Users/"$newuser" "$newuser"
        log "Usuario '$newuser' creado como admin. Contraseña inicial: $newuser"
    fi
}

paso8() {
    sep "Paso 8: Tweaks de macOS"
    warn "Aplicando configuraciones del sistema..."

    # Finder: mostrar extensiones y archivos ocultos
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true

    # Dock: velocidad de animación y auto-hide
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5

    # Capturas de pantalla en ~/Desktop/Screenshots
    mkdir -p "$HOME/Desktop/Screenshots"
    defaults write com.apple.screencapture location "$HOME/Desktop/Screenshots"

    # Teclado: más rápido
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Deshabilitar autocorrección
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Reiniciar Finder y Dock para aplicar
    killall Finder 2>/dev/null || true
    killall Dock   2>/dev/null || true

    log "Tweaks aplicados."
}

paso9() {
    sep "Paso 9: Docker (OrbStack)"
    _brew_init
    if command -v orbctl &>/dev/null || [[ -d "/Applications/OrbStack.app" ]]; then
        log "OrbStack ya instalado."
    elif command -v docker &>/dev/null; then
        log "Docker ya disponible ($(docker --version))."
    else
        warn "Instalando OrbStack (Docker + Linux en macOS)..."
        brew install --cask orbstack
        log "OrbStack instalado. Ábrelo desde Applications para activar."
    fi
}

paso10() {
    sep "Paso 10: Portainer CE"
    if ! command -v docker &>/dev/null; then
        err "Docker no disponible. Ejecuta el Paso 9 y abre OrbStack primero."
        return 1
    fi
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q '^portainer$'; then
        log "Portainer ya instalado."
        docker start portainer 2>/dev/null || true
        return 0
    fi
    docker volume create portainer_data
    docker run -d \
        -p 8000:8000 -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    local local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo 'localhost')
    log "Portainer CE activo → https://${local_ip}:9443"
}

# ------------------------------------------------------------------------------
# Menú
# ------------------------------------------------------------------------------
show_menu() {
    clear
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║     POST-INSTALACIÓN macOS  —  Ricardo & AntiGravity    ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    local items=(
        "1) Instalar Homebrew"
        "2) Actualizar sistema (brew update + upgrade)"
        "3) Instalar herramientas base (git, wget, htop, fastfetch...)"
        "4) Instalar utilitarios modernos (eza, bat, fzf, zoxide)"
        "5) Ajustar hora → America/Guayaquil"
        "6) Instalar Zsh Pro (Oh My Zsh + Powerlevel10k + eza/bat/fzf/zoxide)"
        "7) Crear nuevo usuario admin"
        "8) Tweaks de macOS (Finder, Dock, teclado...)"
        "9) Instalar Docker (OrbStack)"
        "10) Instalar Portainer CE"
        "11) ★  EJECUTAR TODOS LOS PASOS"
        "0) Salir"
    )
    for item in "${items[@]}"; do
        local num="${item%%)*}"
        num="${num// /}"
        if [[ "${STEP_STATUS[$num]}" == "OK" ]]; then
            echo -e "  ${GREEN}✔${NC} $item"
        elif [[ "${STEP_STATUS[$num]}" == "ERR" ]]; then
            echo -e "  ${RED}✘${NC} $item"
        else
            echo "    $item"
        fi
    done
    echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
while true; do
    show_menu
    read -rp "  Selecciona una opción [0-11]: " opcion
    echo ""
    case $opcion in
        1)  run_step 1 ;;
        2)  run_step 2 ;;
        3)  run_step 3 ;;
        4)  run_step 4 ;;
        5)  run_step 5 ;;
        6)  run_step 6 ;;
        7)  run_step 7 ;;
        8)  run_step 8 ;;
        9)  run_step 9 ;;
        10) run_step 10 ;;
        11)
            for i in 1 2 3 4 5 6 8 9 10; do run_step $i; done
            warn "Paso 7 (crear usuario) requiere input manual. Ejecútalo por separado."
            ;;
        0)
            print_summary
            print_sysinfo
            exit 0
            ;;
        *)
            err "Opción no válida." ;;
    esac

    print_summary
    echo ""
    read -rp "  Presiona Enter para volver al menú..." _
done
