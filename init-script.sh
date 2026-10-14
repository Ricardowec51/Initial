#!/bin/bash
# ==============================================================================
# Script Post-Instalación Ubuntu Desktop 26.04+
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

CURRENT_USER="${SUDO_USER:-${USER:-$(id -un)}}"

# ------------------------------------------------------------------------------
# Resumen
# ------------------------------------------------------------------------------
print_summary() {
    echo -e "\n${BLUE}${BOLD}┌──────────────────────────────────────────────────────────┬────────────┐${NC}"
    echo -e "${BLUE}${BOLD}│ Paso                                                     │  Estado    │${NC}"
    echo -e "${BLUE}${BOLD}├──────────────────────────────────────────────────────────┼────────────┤${NC}"
    local steps=(
        "1|Configurar sudo sin contraseña"
        "2|Instalar qemu-guest-agent"
        "3|Actualización del sistema"
        "4|Instalar utilitarios modernos"
        "5|Sincronizar hora (Ecuador)"
        "6|Instalar Zsh Pro (p10k + herramientas)"
        "7|Añadir nuevo usuario sudo"
        "8|Expansión automática disco LVM"
        "9|Instalar Docker CE"
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
    echo "  S.O.:        $(lsb_release -ds 2>/dev/null)"
    echo "  Kernel:      $(uname -r)"
    echo -e "\n  Disco (/):"
    df -h / | tail -1 | awk '{printf "    Tamaño: %s | Usado: %s | Libre: %s | Uso: %s\n",$2,$3,$4,$5}'
    echo -e "\n  Memoria:"
    free -h | awk '/^Mem:/ {printf "    Total: %s | Usada: %s | Libre: %s\n",$2,$3,$4}'
    echo -e "\n  Red:"
    echo "    IP Local:   $(hostname -I | awk '{print $1}')"
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
    sep "Paso 1: Sudo sin contraseña"
    if sudo -n true 2>/dev/null; then
        log "Sudo ya está configurado sin contraseña."
    else
        echo "$CURRENT_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$CURRENT_USER > /dev/null
        sudo chmod 0440 /etc/sudoers.d/$CURRENT_USER
        log "Sudo sin contraseña configurado para $CURRENT_USER."
    fi
}

paso2() {
    sep "Paso 2: qemu-guest-agent"
     if ! systemd-detect-virt >/dev/null 2>&1; then
         warn "Equipo físico detectado; qemu-guest-agent omitido."
         return 0
     fi
    if systemctl is-active --quiet qemu-guest-agent; then
        log "qemu-guest-agent ya está activo."
    else
        sudo apt update -q && sudo apt install -y qemu-guest-agent
        sudo systemctl enable --now qemu-guest-agent
        log "qemu-guest-agent instalado y activo."
    fi
}

paso3() {
    sep "Paso 3: Actualización del sistema"
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    log "Sistema actualizado."
}

paso4() {
    sep "Paso 4: Utilitarios modernos"
    # fastfetch en 24.04+, neofetch en versiones anteriores
    OS_VER=$(lsb_release -rs 2>/dev/null | cut -d. -f1)
    if [[ "$OS_VER" -ge 24 ]]; then
        FETCH_TOOL="fastfetch"
    else
        FETCH_TOOL="neofetch"
    fi
    sudo apt install -y "$FETCH_TOOL" glances cockpit net-tools htop curl git wget \
        build-essential unzip jq tree ffmpeg portaudio19-dev libopus0
    log "Utilitarios instalados ($FETCH_TOOL incluido)."
}

paso5() {
    sep "Paso 5: Zona horaria (Ecuador)"
    sudo timedatectl set-timezone America/Guayaquil
    sudo timedatectl set-ntp on
    log "Hora sincronizada → $(timedatectl | grep 'Local time')"
}

paso6() {
    sep "Paso 6: Zsh Pro (Oh My Zsh + Powerlevel10k + herramientas modernas)"
    local ZSH_SCRIPT_URL="https://raw.githubusercontent.com/Ricardowec51/DevOps/main/bin/setup-zsh-ubuntu.sh"
    local TMP_ZSH="/tmp/setup-zsh-ubuntu.sh"

    warn "Descargando script de configuración Zsh..."
    curl -fsSL "$ZSH_SCRIPT_URL" -o "$TMP_ZSH"
    chmod +x "$TMP_ZSH"
    bash "$TMP_ZSH"
    rm -f "$TMP_ZSH"
    log "Zsh Pro instalado. Ejecuta 'p10k configure' en la próxima sesión."
}

paso7() {
    sep "Paso 7: Nuevo usuario sudo"
    read -rp "  Nombre del nuevo usuario: " newuser
    if [[ -z "$newuser" ]]; then
        warn "No se ingresó nombre. Paso omitido."; return 0
    fi
    if id "$newuser" &>/dev/null; then
        log "El usuario '$newuser' ya existe."
    else
        sudo adduser --gecos "" --disabled-password "$newuser"
        echo "$newuser:$newuser" | sudo chpasswd
        sudo usermod -aG sudo "$newuser"
        log "Usuario '$newuser' creado. Contraseña inicial: $newuser (cámbiala con passwd)"
    fi
}

paso8() {
    sep "Paso 8: Expansión de disco LVM"
    ROOT_PART=$(findmnt / -no SOURCE)
    if [[ "$ROOT_PART" != /dev/mapper/* ]]; then
        warn "No se detectó volumen LVM en /. Paso omitido."; return 0
    fi
    DISK=$(lsblk -no pkname "$ROOT_PART" | head -1)
    PV_DEVICE=$(sudo pvs --noheadings -o pv_name | xargs)
    PART_NUM=$(echo "$PV_DEVICE" | grep -oE '[0-9]+$')
    LV_PATH=$(sudo lvs --noheadings -o lv_path | xargs)

    sudo swapoff -a 2>/dev/null || true
    sudo parted /dev/"$DISK" resizepart "$PART_NUM" 100%
    sudo pvresize "$PV_DEVICE"
    sudo lvextend -l +100%FREE "$LV_PATH"
    sudo resize2fs "$LV_PATH" 2>/dev/null || sudo xfs_growfs "$LV_PATH"
    log "Disco LVM expandido al 100%."
    df -h /
}

paso9() {
    sep "Paso 9: Docker CE"
    if command -v docker &>/dev/null; then
        log "Docker ya instalado ($(docker --version))."; return 0
    fi
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$CURRENT_USER"
    sudo systemctl enable --now docker
    log "Docker CE instalado. Re-login para usar sin sudo."
}

paso10() {
    sep "Paso 10: Portainer CE"
    if ! command -v docker &>/dev/null; then
        err "Docker no instalado. Ejecuta el Paso 9 primero."; return 1
    fi
    if docker ps -a --format '{{.Names}}' | grep -q '^portainer$'; then
        log "Portainer ya está instalado."
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
    log "Portainer CE activo → https://$(hostname -I | awk '{print $1}'):9443"
}

# ------------------------------------------------------------------------------
# Menú
# ------------------------------------------------------------------------------
show_menu() {
    clear
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║     POST-INSTALACIÓN UBUNTU  —  Ricardo & AntiGravity   ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    local items=(
        "1) Configurar sudo sin contraseña"
        "2) Instalar qemu-guest-agent"
        "3) Actualizar sistema"
        "4) Instalar utilitarios modernos (fastfetch, htop, glances...)"
        "5) Ajustar hora → America/Guayaquil"
        "6) Instalar Zsh Pro (Oh My Zsh + Powerlevel10k + eza/bat/fzf/zoxide)"
        "7) Crear nuevo usuario sudo"
        "8) Expandir disco LVM"
        "9) Instalar Docker CE"
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
