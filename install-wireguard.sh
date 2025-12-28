#!/bin/bash

# ==============================================================================
# Script de Instalación y Configuración de WireGuard - Ubuntu 22.04/24.04
# Autor: Ricardo (Optimizado por AntiGravity)
# ==============================================================================

set -euo pipefail

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Iniciando instalación y configuración de WireGuard...${NC}"

# Función para validar formato de IPv4
validar_ip() {
  local ip=$1
  if [[ ! $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    return 1
  fi
  IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
  for octeto in "$o1" "$o2" "$o3" "$o4"; do
    if (( octeto < 0 || octeto > 255 )); then
      return 1
    fi
  done
  return 0
}

# 1. Habilitar IP Forwarding (Crítico para que el tráfico pase por la VPN)
echo -e "${BLUE}1. Habilitando IP Forwarding...${NC}"
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p

# 2. Obtener la IP pública por defecto
DEFAULT_IP=$(curl -s ifconfig.me || echo "0.0.0.0")

# 3. Detectar Interfaz de Red principal automáticamente
DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

echo -e "\n--- Configuración de Red ---"
# Prompt IP Pública
while true; do
  read -p "Ingrese la IP pública del servidor [$DEFAULT_IP]: " input
  WG_PUBLIC_IP="${input:-$DEFAULT_IP}"
  if validar_ip "$WG_PUBLIC_IP"; then break; else echo -e "${RED}IP inválida.${NC}"; fi
done

# Prompt Puerto
read -p "Ingrese el puerto de escucha [51820]: " input_port
WG_LISTEN_PORT="${input_port:-51820}"

# Prompt Interfaz
read -p "Ingrese la interfaz de red para NAT [$DEFAULT_INTERFACE]: " input_iface
WG_INTERFACE="${input_iface:-$DEFAULT_INTERFACE}"

echo -e "\n${YELLOW}Resumen:${NC} IP=$WG_PUBLIC_IP, Puerto=$WG_LISTEN_PORT, Interfaz=$WG_INTERFACE\n"

# 4. Instalación de paquetes
echo -e "${BLUE}4. Instalando paquetes...${NC}"
sudo apt update
sudo apt install -y wireguard iptables resolvconf qrencode

# 5. Generar Claves
echo -e "${BLUE}5. Generando claves de seguridad...${NC}"
sudo mkdir -p /etc/wireguard
sudo chmod 700 /etc/wireguard
cd /etc/wireguard

# Generar claves con permisos restringidos
sudo bash -c "umask 077; wg genkey | tee server.key | wg pubkey > server.pub"
SERVER_PRIV_KEY=$(sudo cat server.key)
SERVER_PUB_KEY=$(sudo cat server.pub)

# 6. Crear Configuración wg0.conf
echo -e "${BLUE}6. Creando configuración wg0.conf...${NC}"
sudo bash -c "cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = $WG_LISTEN_PORT
PrivateKey = $SERVER_PRIV_KEY
# Reglas de Firewall para NAT (Usando interfaz $WG_INTERFACE)
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $WG_INTERFACE -j MASQUERADE
EOF"

# 7. Iniciar Servicio
echo -e "${BLUE}7. Iniciando servicio WireGuard...${NC}"
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# 8. Guardar info para facilitar creación de clientes
sudo bash -c "cat <<EOF > /etc/wireguard/server_info.conf
WG_PUBLIC_IP=$WG_PUBLIC_IP
WG_LISTEN_PORT=$WG_LISTEN_PORT
WG_INTERFACE=$WG_INTERFACE
SERVER_PUB_KEY=$SERVER_PUB_KEY
EOF"

echo -e "\n${GREEN}✅ ¡INSTALACIÓN COMPLETADA!${NC}"
echo "--------------------------------------------------------"
echo "Clave Pública del Servidor: $SERVER_PUB_KEY"
echo -e "Recordatorio: Asegúrate de que el puerto ${YELLOW}$WG_LISTEN_PORT/UDP${NC} esté abierto en tu router/firewall."
echo "--------------------------------------------------------"
