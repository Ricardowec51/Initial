#!/bin/bash
# Script reestructurado para post-instalación de la VM con resumen final "nice"
# y "Resumen del medio de trabajo"

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
    else
        echo "Error al configurar sudo."
    fi
    step1_status="S"
}

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
    else
        echo "Error en la instalación de utilitarios."
    fi
    step4_status="S"
}

step5() {
    echo "Paso 5: Sincronización de hora y activación de NTP."
    sudo timedatectl set-timezone America/Guayaquil
    sudo timedatectl set-ntp on
    if [ $? -eq 0 ]; then
        echo "Hora sincronizada y NTP activado correctamente."
    else
        echo "Error al sincronizar la hora o activar NTP."
    fi
    step5_status="S"
}

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
    else
        echo "Error al añadir el usuario o agregarlo al grupo sudo."
    fi
    step7_status="S"
}

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


