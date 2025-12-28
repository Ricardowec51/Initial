# Server Initialization & Optimization Toolset

A comprehensive collection of automation scripts designed to transform a fresh Ubuntu installation into a production-ready environment with optimized shell, security hardening, and essential infrastructure.

---

## 🛠️ Script Documentation

### 1. `init-script.sh` (The Orchestrator)
This is the main post-installation script designed for Ubuntu 22.04/24.04. It uses a menu-driven interface to perform critical system optimizations.

*   **Key Features:**
    *   **LVM Disk Expansion**: Automatically detects if the system is using LVM and expands the root partition to use all available disk space.
    *   **Security & User Management**: Configures passwordless `sudo` and creates new administrative users.
    *   **System Core**: Installs `QEMU Guest Agent`, updates all packages, and synchronizes time/timezone.
    *   **Modern Utilities**: Installs `fastfetch`, `glances`, `cockpit`, and `htop` for professional monitoring.
    *   **Containerization**: One-click installation of `Docker Engine` and `Portainer CE`.
    *   **Zsh Integration**: Automatically calls the Zsh Pro installer as part of the setup.

*   **Pre-configuration Requirements:**
    *   A clean installation of Ubuntu (Server or Desktop).
    *   Initial `sudo` or `root` access.
    *   Active internet connection.

---

### 2. `my_zsh_install.sh` (Zsh Pro Setup)
An automated script to set up a premium terminal experience. It replaces the default Bash shell with a highly functional Zsh environment.

*   **Key Features:**
    *   **Oh My Zsh Framework**: Installs the industry-standard Zsh management framework.
    *   **Premium Theme**: Installs and configures the `Honukai` theme for high readability and aesthetics.
    *   **Power-User Plugins**:
        *   `zsh-autosuggestions`: Shell-completion based on history.
        *   `zsh-syntax-highlighting`: Real-time command validation.
        *   `zsh-completions`: Enhanced tab-completion for common tools.
    *   **Default Shell**: Automatically switches the user's shell to Zsh.

*   **Pre-configuration Requirements:**
    *   `curl` or `wget` installed (the script handles basic dependencies, but internet access is mandatory).

---

### 3. `install-wireguard.sh` (WireGuard VPN Installer)
A streamlined script to deploy a high-performance, secure WireGuard VPN server.

*   **Key Features:**
    *   **Automated Networking**: Self-detects the primary network interface (e.g., `ens18` or `eth0`).
    *   **IP Forwarding**: Automatically enables persistent IPv4 forwarding in the kernel.
    *   **Security**: Generates server/client keys and configures robust `iptables` NAT rules for internet routing.
    *   **Ready-to-Use**: Provides a clear summary of the public key and configuration steps for clients.

*   **Pre-configuration Requirements:**
    *   **Network Port**: You must open/forward the UDP port (default `51820`) in your firewall or router.
    *   **Public IP**: Ensure you know your public IP address (the script will prompt for it).

---

## 📋 General Requirements

*   **Operating System**: Ubuntu 22.04 LTS or 24.04 LTS.
*   **Permissions**: All scripts must be run with `sudo` or as the `root` user.
*   **Git**: Required to clone this repository.

## 🚀 How to Use

```bash
# 1. Clone the repository
git clone https://github.com/Ricardowec51/Initial.git
cd Initial

# 2. Make scripts executable
chmod +x *.sh

# 3. Run the main orchestrator
sudo ./init-script.sh
```

---

*Authored and optimized by Ricardo & AntiGravity.*
