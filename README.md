# Post-Install Setup — Ricardo Wagner & AntiGravity

Scripts de post-instalación para dejar un sistema recién instalado **listo para trabajar** en minutos.  
Soporta **macOS** (Apple Silicon e Intel) y **Ubuntu/Debian**.

---

## Uso rápido — un solo comando

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Ricardowec51/Initial/main/init.sh)
```

El script detecta el sistema operativo automáticamente y lanza el menú correspondiente.

---

## Los 10 pasos

| # | Ubuntu / Debian | macOS |
|---|---|---|
| 1 | Configurar sudo sin contraseña | Instalar Homebrew |
| 2 | Instalar qemu-guest-agent | Actualizar sistema (`brew upgrade`) |
| 3 | Actualizar sistema (`apt upgrade`) | Instalar herramientas base (git, htop, fastfetch…) |
| 4 | Instalar utilitarios (fastfetch, glances, htop…) | Instalar utilitarios modernos (eza, bat, fzf, zoxide) |
| 5 | Sincronizar hora → America/Guayaquil | Ajustar hora → America/Guayaquil |
| 6 | **Zsh Pro** (Oh My Zsh + Powerlevel10k + herramientas) | **Zsh Pro** (Oh My Zsh + Powerlevel10k + herramientas) |
| 7 | Crear nuevo usuario sudo | Crear nuevo usuario admin |
| 8 | Expansión automática de disco LVM | Tweaks de macOS (Finder, Dock, teclado) |
| 9 | Instalar Docker CE | Instalar Docker (OrbStack) |
| 10 | Instalar Portainer CE | Instalar Portainer CE |

> La opción **11** ejecuta todos los pasos en secuencia (excepto el 7, que requiere input manual).

---

## Zsh Pro — Paso 6

El corazón de la configuración del shell. Instala y configura:

| Componente | Descripción |
|---|---|
| [Oh My Zsh](https://ohmyz.sh) | Framework para gestionar Zsh |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Tema ultra-rápido con prompt informativo |
| zsh-autosuggestions | Sugerencias basadas en historial |
| zsh-syntax-highlighting | Colorea la sintaxis en tiempo real |
| zsh-completions | Completaciones extendidas para cientos de comandos |
| [eza](https://github.com/eza-community/eza) | Reemplazo moderno de `ls` con iconos |
| [bat](https://github.com/sharkdp/bat) | Reemplazo de `cat` con syntax highlighting |
| [fzf](https://github.com/junegunn/fzf) | Búsqueda difusa en historial y archivos |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Reemplazo de `cd` inteligente |
| MesloLGS Nerd Font | Fuente con iconos para Powerlevel10k |

**Aliases resultantes:**

```zsh
ls    → eza --icons
ll    → eza -alF --icons --git
la    → eza -a --icons
tree  → eza --tree --icons
cat   → bat --paging=never
cd    → z  (zoxide)
```

Al terminar, abre una nueva terminal y ejecuta `p10k configure` para personalizar el prompt.  
Asegúrate de configurar la fuente **MesloLGS NF Regular** en tu emulador de terminal.

---

## Estructura del repositorio

```
Initial/
├── init.sh                ← Punto de entrada único (detecta macOS/Ubuntu)
├── init-script.sh         ← Menú interactivo Ubuntu/Debian (10 pasos)
├── init-script-mac.sh     ← Menú interactivo macOS (10 pasos)
├── install-wireguard.sh   ← Instalación de WireGuard VPN
└── my_zsh_install.sh      ← Script Zsh legacy (Honukai — referencia)
```

Los instaladores Zsh del Paso 6 viven en:
[Ricardowec51/DevOps → bin/](https://github.com/Ricardowec51/DevOps/tree/main/bin)

---

## Uso por plataforma (script directo)

```bash
# Ubuntu/Debian
bash <(curl -fsSL https://raw.githubusercontent.com/Ricardowec51/Initial/main/init-script.sh)

# macOS
bash <(curl -fsSL https://raw.githubusercontent.com/Ricardowec51/Initial/main/init-script-mac.sh)
```

---

## Requisitos

| Plataforma | Requisito |
|---|---|
| Ubuntu/Debian | Ubuntu 22.04+ o Debian 11+, usuario con `sudo` |
| macOS | macOS 12 Monterey o superior, Apple Silicon o Intel |

No ejecutar como `root`. Los scripts solicitan `sudo` internamente cuando es necesario.

---

*Ricardo Wagner & AntiGravity*
