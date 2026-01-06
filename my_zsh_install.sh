#!/bin/bash

# ==============================================================================
# Script de Instalación de Zsh + Oh My Zsh + Honukai Theme
# Optimizado para Linux (Ubuntu 24.04)
# ==============================================================================

set -e  # Salir en caso de error

echo "🔄 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando dependencias básicas (Zsh, Git, Curl, Fuentes)..."
sudo apt install -y zsh git curl wget vim locales-all fonts-powerline

echo "✅ Verificando Zsh..."
if ! command -v zsh &> /dev/null; then
    sudo apt install -y zsh
fi
echo "Zsh versión: $(zsh --version)"

echo "🎨 Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # --unattended evita que el script de instalación cambie el shell y entre en el nuevo shell inmediatamente
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh ya existe."
fi

echo "📦 Instalando plugins y el tema Honukai..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
CUSTOM_PLUGINS="$ZSH_CUSTOM/plugins"
CUSTOM_THEMES="$ZSH_CUSTOM/themes"

# Crear carpetas si no existen
mkdir -p "$CUSTOM_PLUGINS"
mkdir -p "$CUSTOM_THEMES"

# Plugin: zsh-autosuggestions
if [ ! -d "$CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
    echo "📥 Descargando zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$CUSTOM_PLUGINS/zsh-autosuggestions"
fi

# Plugin: zsh-syntax-highlighting
if [ ! -d "$CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
    echo "📥 Descargando zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_PLUGINS/zsh-syntax-highlighting"
fi

# Plugin: zsh-completions
if [ ! -d "$CUSTOM_PLUGINS/zsh-completions" ]; then
    echo "📥 Descargando zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions.git "$CUSTOM_PLUGINS/zsh-completions"
fi

# Tema Honukai (Descarga manual ya que no es nativo de Oh My Zsh)
if [ ! -f "$CUSTOM_THEMES/honukai.zsh-theme" ]; then
    echo "📥 Descargando tema Honukai..."
    curl -o "$CUSTOM_THEMES/honukai.zsh-theme" https://raw.githubusercontent.com/oskarkrawczyk/honukai-iterm/master/honukai.zsh-theme
fi

echo "🎨 Configurando .zshrc..."
# Crear Backup de .zshrc si existe
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# Escribir configuración limpia en .zshrc
cat > ~/.zshrc << 'EOF'
# Configuración Zsh + Oh My Zsh + Honukai
export ZSH="$HOME/.oh-my-zsh"

# Aplicar Tema Honukai
ZSH_THEME="honukai"

# Definir Plugins instalados
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Cargar Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Configuración extra para zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -Uz compinit

# Optimización de carga y evitar errores de permisos
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

# Configuración de Historial
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY

# Alias útiles opcionales
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ============================================
# Alias Personalizados
# ============================================
alias myip='curl ifconfig.me'

EOF

echo "🔧 Cambiando shell por defecto a Zsh..."
# Detectar la ruta de zsh y cambiar el shell del usuario actual
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$USER"
fi

echo "✅ ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
echo "--------------------------------------------------------"
echo "Para activar los cambios ahora mismo, ejecuta:"
echo "source ~/.zshrc"
echo ""
echo "O simplemente reinicia tu sesión de terminal."
echo "--------------------------------------------------------"
