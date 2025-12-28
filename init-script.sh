#!/bin/bash
# Script reestructurado para post-instalación de la VM con resumen final "nice"
# y "Resumen del medio de trabajo"

<<<<<<< HEAD
##########################
# Variables globales (estado de cada paso)
##########################
step1_status="N"
step2_status="N"
step3_status="N"
step4_status="N"
step5_status="N"
step6_status="N"
step7_status="N"
step8_status="N"
step9_status="N"

##########################
# Funciones Auxiliares
##########################

# Imprime el cuadro de resumen de ejecución de pasos
print_summary() {
    echo ""
    echo "┌──────────────────────────────────────────────────────────────┬──────────────┐"
    echo "│ Actividad                                                   │ Ejecutado    │"
    echo "├──────────────────────────────────────────────────────────────┼──────────────┤"
    printf "│ %-60s │ %-10s │\n" "Configurar sudo sin pedir contraseña" "$step1_status"
    printf "│ %-60s │ %-10s │\n" "Instalación de qemu-guest-agent" "$step2_status"
    printf "│ %-60s │ %-10s │\n" "Actualización del servidor" "$step3_status"
    printf "│ %-60s │ %-10s │\n" "Instalación de utilitarios" "$step4_status"
    printf "│ %-60s │ %-10s │\n" "Sincronización de hora y activación de NTP" "$step5_status"
    printf "│ %-60s │ %-10s │\n" "Instalación de Docker" "$step6_status"
    printf "│ %-60s │ %-10s │\n" "Añadir nuevo usuario y agregarlo al grupo sudo" "$step7_status"
    printf "│ %-60s │ %-10s │\n" "Redimensionamiento y verificación del disco" "$step8_status"
    printf "│ %-60s │ %-10s │\n" "Instalación de Portainer CE" "$step9_status"
    echo "└──────────────────────────────────────────────────────────────┴──────────────┘"
}

# Imprime un resumen del entorno de trabajo
print_system_info() {
    echo ""
    echo "==========================================="
    echo "       Resumen del Medio de Trabajo       "
    echo "==========================================="

    # Nombre del Servidor
    echo "Nombre del Servidor:    $(hostname)"

    # Nombre del Usuario
    echo "Nombre del Usuario:     $(logname)"

    # Versión de Sistema Operativo
    if command -v lsb_release &>/dev/null; then
        os_version="$(lsb_release -ds)"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        os_version="$NAME $VERSION"
    else
        os_version="Desconocido"
    fi
    echo "Versión del S.O.:       $os_version"

    # Versión del Kernel
    echo "Versión del Kernel:     $(uname -r)"

    # Espacio en Disco (raíz /)
    echo ""
    echo "Datos del Espacio en Disco (raíz /):"
    # Obtenemos la línea que describe la raíz y la formateamos
    df -h / | tail -1 | awk '{ 
        print "  Tamaño: " $2 "\n  Usado: " $3 "\n  Disponible: " $4 "\n  Uso%: " $5 
    }'

    # Memoria del Servidor
    echo ""
    echo "Memoria del Servidor:"
    # Tomamos los valores de la segunda línea (Mem:) de free -h
    read mem_total mem_used mem_free < <(free -h | awk '/^Mem:/ {print $2, $3, $4}')
    echo "  Total: $mem_total"
    echo "  Usada: $mem_used"
    echo "  Libre: $mem_free"

    # Datos de Red
    echo ""
    echo "Datos de Red:"
    # IP local
    ip_local="$(hostname -I | awk '{print $1}')"
    # Default Gateway
    default_gw="$(ip route | awk '/default/ {print $3; exit}')"
    # DNS principal (toma la primera línea 'nameserver' de /etc/resolv.conf)
    dns_server="$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf)"
    # IP externa (requiere curl)
    ip_externa="$(curl -s ifconfig.me || echo "Desconocida")"

    echo "  IP del Servidor:    $ip_local"
    echo "  Default Gateway:     $default_gw"
    echo "  DNS principal:       $dns_server"
    echo "  IP Externa:          $ip_externa"
}

##########################
# Pasos Obligatorios (1-5)
##########################
step1() {
    echo "Paso 1: Configurar sudo sin pedir contraseña."
    read -sp "Ingresa tu contraseña de sudo: " sudo_password
    echo ""
    echo "$sudo_password" | sudo -S bash -c 'echo "$(logname) ALL=(ALL:ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)'
    if [ $? -eq 0 ]; then
        echo "Configuración de sudo completada exitosamente."
=======
# ==============================================================================
# Script Post-Instalación Ubuntu 24.04/22.04 - Optimizado por AntiGravity
# ==============================================================================

set -e  # Salir en caso de error

# Colores para mejor legibilidad
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Función: Configurar sudo sin contraseña
function paso1() {
    echo -e "${BLUE}Paso 1: Configurar sudo sin contraseña para el usuario actual.${NC}"
    # Si ya tiene acceso sin contraseña, no hacer nada
    if sudo -n true 2>/dev/null; then
        echo "Sudo ya está configurado sin contraseña."
>>>>>>> 0814813 (Update scripts for Ubuntu 24.04, add install-wireguard.sh, and modernize init-script.sh)
    else
        echo "Configurando acceso...'$(logname) ALL=(ALL) NOPASSWD: ALL'"
        echo "$(logname) ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$(logname) > /dev/null
        sudo chmod 0440 /etc/sudoers.d/$(logname)
        echo -e "${GREEN}Configuración completada.${NC}"
    fi
    step1_status="S"
}

<<<<<<< HEAD
step2() {
    echo "Paso 2: Instalación de qemu-guest-agent."
    sudo apt install -y qemu-guest-agent
    if [ $? -eq 0 ]; then
        echo "qemu-guest-agent instalado correctamente."
    else
        echo "Error en la instalación de qemu-guest-agent."
    fi
    step2_status="S"
}

step3() {
    echo "Paso 3: Actualización del servidor."
    sudo apt update && sudo apt upgrade -y
    if [ $? -eq 0 ]; then
        echo "Actualización completada correctamente."
    else
        echo "Error en la actualización."
    fi
    step3_status="S"
}

step4() {
    echo "Paso 4: Instalación de utilitarios."
    sudo apt install -y neofetch speedtest-cli glances cockpit net-tools
    if [ $? -eq 0 ]; then
        echo "Utilitarios instalados correctamente."
=======
# Función: Instalación de qemu-guest-agent
function paso2() {
    echo -e "${BLUE}Paso 2: Instalación de qemu-guest-agent.${NC}"
    sudo apt update && sudo apt install -y qemu-guest-agent
    sudo systemctl enable --now qemu-guest-agent
    echo -e "${GREEN}qemu-guest-agent instalado y activo.${NC}"
}

# Función: Actualización del servidor
function paso3() {
    echo -e "${BLUE}Paso 3: Actualización completa del sistema.${NC}"
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    echo -e "${GREEN}Sistema actualizado.${NC}"
}

# Función: Instalación de utilitarios (fastfetch en lugar de neofetch)
function paso4() {
    echo -e "${BLUE}Paso 4: Instalación de utilitarios modernos.${NC}"
    # Neofetch está muerto, usamos fastfetch si es 24.04 o superior
    OS_VERSION=$(lsb_release -rs)
    if (( $(echo "$OS_VERSION >= 24.04" | bc -l) )); then
        UTIL_FETCH="fastfetch"
>>>>>>> 0814813 (Update scripts for Ubuntu 24.04, add install-wireguard.sh, and modernize init-script.sh)
    else
        UTIL_FETCH="neofetch"
    fi
<<<<<<< HEAD
    step4_status="S"
}

step5() {
    echo "Paso 5: Sincronización de hora y activación de NTP."
=======
    
    sudo apt install -y $UTIL_FETCH speedtest-cli glances cockpit net-tools htop curl git
    echo -e "${GREEN}Utilitarios ($UTIL_FETCH, speedtest, etc.) instalados.${NC}"
}

# Función: Sincronización de hora
function paso5() {
    echo -e "${BLUE}Paso 5: Configuración de Zona Horaria y NTP.${NC}"
>>>>>>> 0814813 (Update scripts for Ubuntu 24.04, add install-wireguard.sh, and modernize init-script.sh)
    sudo timedatectl set-timezone America/Guayaquil
    sudo timedatectl set-ntp on
    timedatectl
}

# Función: Instalar Zsh + Oh My Zsh (Integración del script anterior)
function paso6() {
    echo -e "${BLUE}Paso 6: Instalación Pro de Zsh + Oh My Zsh + Honukai Theme.${NC}"
    # Simplemente llamamos a nuestro script de instalación
    SCRIPT_ZSH="/Volumes/Externo/my_zsh_install.sh/my_zsh_install.sh"
    if [ -f "$SCRIPT_ZSH" ]; then
        bash "$SCRIPT_ZSH"
    else
        echo -e "${YELLOW}No se encontró el script de Zsh en $SCRIPT_ZSH. Saltando...${NC}"
    fi
    step5_status="S"
}

<<<<<<< HEAD
##########################
# Pasos Opcionales (6-9)
##########################
step6() {
    echo "Paso 6: Instalación de Docker."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce
    if [ $? -eq 0 ]; then
        echo "Docker instalado correctamente."
    else
        echo "Error en la instalación de Docker."
    fi
    step6_status="S"
}

step7() {
    echo "Paso 7: Añadir nuevo usuario y agregarlo al grupo sudo."
    read -p "Ingresa el nombre del nuevo usuario: " newuser
    sudo adduser --gecos "" --disabled-password "$newuser"
    echo "$newuser:$newuser" | sudo chpasswd
    sudo usermod -aG sudo "$newuser"
    if [ $? -eq 0 ]; then
        echo "Usuario '$newuser' añadido y agregado al grupo sudo correctamente."
=======
# Función: Gestión de Usuario
function paso7() {
    echo -e "${BLUE}Paso 7: Crear nuevo usuario administrador.${NC}"
    read -p "Nombre del nuevo usuario: " newuser
    if id "$newuser" &>/dev/null; then
        echo -e "${YELLOW}El usuario ya existe.${NC}"
>>>>>>> 0814813 (Update scripts for Ubuntu 24.04, add install-wireguard.sh, and modernize init-script.sh)
    else
        sudo adduser --gecos "" --disabled-password "$newuser"
        echo "$newuser:$newuser" | sudo chpasswd
        sudo usermod -aG sudo "$newuser"
        echo -e "${GREEN}Usuario $newuser creado con privilegios sudo.${NC}"
    fi
    step7_status="S"
}

<<<<<<< HEAD
step8() {
    echo "Paso 8: Redimensionamiento y verificación del disco."
    echo "Desactivando swap..."
    sudo swapoff -a || { echo "Error al desactivar swap."; return 1; }
    echo "Eliminando /swap.img y entrada en /etc/fstab..."
    sudo rm -f /swap.img
    sudo sed -i '/swap.img/d' /etc/fstab
    echo "Redimensionando partición 3 en /dev/sda..."
    sudo parted /dev/sda resizepart 3 100% || { echo "Error al redimensionar la partición."; return 1; }
    echo "Redimensionando volumen físico en /dev/sda3..."
    sudo pvresize /dev/sda3 || { echo "Error al redimensionar el volumen físico."; return 1; }
    echo "Extendiendo el volumen lógico..."
    sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv || { echo "Error al extender el volumen lógico."; return 1; }
    echo "Redimensionando el sistema de archivos..."
    sudo resize2fs /dev/ubuntu-vg/ubuntu-lv || { echo "Error al redimensionar el sistema de archivos."; return 1; }
    echo "Mostrando información final del sistema:"
    sudo df -h /
    sudo lvdisplay /dev/ubuntu-vg/ubuntu-lv
    sudo vgdisplay ubuntu-vg
    echo "Redimensionamiento y verificación del disco completados."
    step8_status="S"
}

step9() {
    echo "Paso 9: Instalación de Portainer CE."
    sudo docker volume create portainer_data
    sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest
    if [ $? -eq 0 ]; then
        echo "Portainer CE instalado y en ejecución."
    else
        echo "Error en la instalación de Portainer CE."
    fi
    step9_status="S"
}

##########################
# Funciones de Ejecución
##########################
run_mandatory_steps() {
    echo "Ejecutando los pasos obligatorios (1-5)..."
    step1; step2; step3; step4; step5
}

run_optional_steps() {
    echo "Seleccione los pasos opcionales a ejecutar (ingrese los números separados por espacio, ej. 1 3):"
    echo "  1) Paso 6: Instalación de Docker"
    echo "  2) Paso 7: Añadir nuevo usuario"
    echo "  3) Paso 8: Redimensionamiento del disco"
    echo "  4) Paso 9: Instalación de Portainer CE"
    read -p "Ingrese su opción: " -a opts
    for opt in "${opts[@]}"; do
        case $opt in
            1) step6 ;;
            2) step7 ;;
            3) step8 ;;
            4) step9 ;;
            *) echo "Opción $opt no válida." ;;
        esac
    done
}

##########################
# Menú Principal
##########################
main() {
    echo "Bienvenido al script post-instalación de la VM, Ricardo."
    echo "Seleccione el modo de ejecución:"
    echo "  1) Ejecutar TODOS los pasos (Obligatorios + Opcionales)"
    echo "  2) Ejecutar solo los pasos obligatorios (1-5)"
    echo "  3) Ejecutar solo los pasos opcionales (6-9)"
    read -p "Ingrese su opción (1/2/3): " mode
    case $mode in
        1)
            # Ejecutar todos los pasos automáticamente
            step1; step2; step3; step4; step5; step6; step7; step8; step9
            ;;
        2)
            run_mandatory_steps
            ;;
        3)
            run_optional_steps
            ;;
        *)
            echo "Opción inválida."
            ;;
    esac

    # Al terminar, imprimimos el cuadro resumen de pasos
    print_summary

    # Luego, imprimimos el resumen del medio de trabajo
    print_system_info
}

# Iniciar el script
main


=======
# Función: Redimensionamiento dinámico de disco LVM
function paso8() {
    echo -e "${BLUE}Paso 8: Expansión de disco lógica y física (LVM).${NC}"
    
    # Detectar disco principal y partición root
    ROOT_PART=$(findmnt / -no SOURCE)
    DISK=$(lsblk -no pkname $ROOT_PART | head -n 1)
    # Si es LVM, el disco real está detrás del mapeo
    if [[ $ROOT_PART == /dev/mapper/* ]]; then
        PV_DEVICE=$(sudo pvs --noheadings -o pv_name | xargs)
        VG_NAME=$(sudo vgs --noheadings -o vg_name | xargs)
        LV_PATH=$(sudo lvs --noheadings -o lv_path | xargs)
        
        echo -e "${YELLOW}Detectado LVM:${NC} DISCO=/dev/$DISK, VG=$VG_NAME, LV=$LV_PATH"
        
        # Desactivar swap temporal si existe
        sudo swapoff -a || true
        
        # 1. Expandir partición física (el número de la part. se detecta del PV_DEVICE)
        PART_NUM=$(echo $PV_DEVICE | grep -o '[0-9]*$')
        echo "Expandiendo partición /dev/$DISK $PART_NUM..."
        sudo parted /dev/$DISK resizepart $PART_NUM 100%
        
        # 2. PV Resize
        sudo pvresize $PV_DEVICE
        
        # 3. LV Extend y Resize FS
        sudo lvextend -l +100%FREE $LV_PATH
        sudo resize2fs $LV_PATH
        
        echo -e "${GREEN}¡Expansión completada!${NC}"
        df -h /
    else
        echo -e "${RED}El sistema no parece usar LVM. Expansión manual requerida.${NC}"
    fi
}

# Menú Principal
clear
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}   SCRIPT POST-INSTALACIÓN UBUNTU - POR RICARDO       ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo "1) Configurar Sudo (Sin Contraseña)"
echo "2) Instalar QEMU Guest Agent"
echo "3) Actualización de Sistema"
echo "4) Instalar Utilitarios (Fastfetch, Cockpit, etc.)"
echo "5) Ajustar Hora (Ecuador)"
echo "6) Instalar Zsh Pro (Oh My Zsh + Honukai)"
echo "7) Crear nuevo Usuario"
echo "8) Expandir Disco LVM (Automático)"
echo "9) EJECUTAR TODO (Pulsar Enter para confirmar)"
echo "0) Salir"
echo "------------------------------------------------------"
read -p "Selecciona una opción [0-9]: " opcion

case $opcion in
    1) paso1 ;;
    2) paso2 ;;
    3) paso3 ;;
    4) paso4 ;;
    5) paso5 ;;
    6) paso6 ;;
    7) paso7 ;;
    8) paso8 ;;
    9)
        paso1; paso2; paso3; paso4; paso5; paso6; paso7; paso8
        ;;
    0) exit 0 ;;
    *) echo "Opción no válida";;
esac
>>>>>>> 0814813 (Update scripts for Ubuntu 24.04, add install-wireguard.sh, and modernize init-script.sh)
