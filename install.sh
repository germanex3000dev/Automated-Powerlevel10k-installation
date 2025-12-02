#!/usr/bin/env bash
# Automated Powerlevel10k installation script
# By: Germanex3000 (completed)
set -u
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default behavior (fully automatic)
AUTO="no"
DEFAULT_METHOD="oh-my-zsh"
DEFAULT_INSTALL_FONT="yes"

# Platform detection
PLATFORM="unknown"
case "$(uname -s)" in
    Linux*)  PLATFORM="Linux" ;;
    Darwin*) PLATFORM="macOS" ;;
    CYGWIN*) PLATFORM="Cygwin" ;;
    MINGW*)  PLATFORM="MinGW" ;;
    *)       PLATFORM="Other" ;;
esac

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Lightweight detection of common package managers
detect_pkgmgr() {
    if command_exists apt; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists zypper; then
        echo "zypper"
    elif command_exists brew; then
        echo "brew"
    else
        echo ""
    fi
}

install_package() {
    local package=$1
    local pm
    pm="$(detect_pkgmgr)"
    if [ -z "$pm" ]; then
        print_error "No supported package manager detected. Please install ${package} manually."
        return 1
    fi

    print_status "Installing ${package} using ${pm}..."

    case "$pm" in
        apt)
            sudo apt update -y
            sudo apt install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        yum)
            sudo yum install -y "$package"
            ;;
        pacman)
            sudo pacman -Syu --noconfirm "$package"
            ;;
        zypper)
            sudo zypper install -y "$package"
            ;;
        brew)
            brew install "$package"
            ;;
        *)
            print_error "Unsupported package manager: $pm"
            return 1
            ;;
    esac
}

ensure_prereqs() {
    # Ensure git and curl (or wget) exist
    if ! command_exists git; then
        print_status "git not found. Attempting to install git..."
        install_package git || { print_error "git installation failed."; return 1; }
    fi

    if ! command_exists curl && ! command_exists wget; then
        print_status "curl/wget not found. Attempting to install curl..."
        install_package curl || { print_error "curl installation failed."; return 1; }
    fi

    # font cache utilities on Linux
    if [ "$PLATFORM" = "Linux" ] && ! command_exists fc-cache; then
        install_package fontconfig || print_warning "Unable to install fontconfig (fc-cache may be missing)."
    fi

    return 0
}

install_zsh() {
    if command_exists zsh; then
        print_success "Zsh already installed: $(zsh --version)"
        return 0
    fi

    print_status "Zsh not found. Installing..."
    case "$PLATFORM" in
        Linux|macOS)
            install_package zsh || return 1
            ;;
        *)
            print_warning "Automatic Zsh installation is not supported on platform: $PLATFORM"
            return 1
            ;;
    esac

    if command_exists zsh; then
        print_success "Zsh installed: $(zsh --version)"
        return 0
    else
        print_error "Zsh installation failed."
        return 1
    fi
}

set_zsh_default() {
    local zsh_path
    zsh_path="$(which zsh 2>/dev/null || true)"
    if [ -z "$zsh_path" ]; then
        print_warning "zsh binary not found; cannot set default shell."
        return 1
    fi

    if [ "$SHELL" = "$zsh_path" ]; then
        print_success "Zsh is already the default shell: $SHELL"
        return 0
    fi

    print_status "Trying to set zsh ($zsh_path) as default shell for user $(whoami)..."
    if chsh -s "$zsh_path" "$(whoami)" >/dev/null 2>&1; then
        print_success "Default shell changed to zsh. You may need to log out/in."
        return 0
    else
        print_warning "Could not change default shell automatically. Try running:"
        print_warning "  chsh -s $(which zsh)"
        return 1
    fi
}

install_nerd_font() {
    local font_dir="${HOME}/.local/share/fonts"
    local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    mkdir -p "$font_dir"

    print_status "Downloading MesloLGS Nerd Font files to ${font_dir}..."
    # Use curl if available, otherwise try wget
    if command_exists curl; then
        curl -sL -o "${font_dir}/MesloLGS NF Regular.ttf" "${base_url}/MesloLGS%20NF%20Regular.ttf" || true
        curl -sL -o "${font_dir}/MesloLGS NF Bold.ttf" "${base_url}/MesloLGS%20NF%20Bold.ttf" || true
        curl -sL -o "${font_dir}/MesloLGS NF Italic.ttf" "${base_url}/MesloLGS%20NF%20Italic.ttf" || true
        curl -sL -o "${font_dir}/MesloLGS NF Bold Italic.ttf" "${base_url}/MesloLGS%20NF%20Bold%20Italic.ttf" || true
    elif command_exists wget; then
        wget -qO "${font_dir}/MesloLGS NF Regular.ttf" "${base_url}/MesloLGS%20NF%20Regular.ttf" || true
        wget -qO "${font_dir}/MesloLGS NF Bold.ttf" "${base_url}/MesloLGS%20NF%20Bold.ttf" || true
        wget -qO "${font_dir}/MesloLGS NF Italic.ttf" "${base_url}/MesloLGS%20NF%20Italic.ttf" || true
        wget -qO "${font_dir}/MesloLGS NF Bold Italic.ttf" "${base_url}/MesloLGS%20NF%20Bold%20Italic.ttf" || true
    else
        print_warning "Neither curl nor wget found. Cannot download fonts automatically."
        return 1
    fi

    if command_exists fc-cache; then
        print_status "Refreshing font cache..."
        fc-cache -f -v >/dev/null 2>&1 || true
    fi

    print_success "Fonts placed in ${font_dir}. Please select 'MesloLGS NF' in your terminal emulator settings."
    return 0
}

install_oh_my_zsh() {
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already exists at ${HOME}/.oh-my-zsh"
        return 0
    fi

    print_status "Installing Oh My Zsh (unattended)..."
    # The official installer accepts an --unattended argument; we pass empty args to avoid modifying shell immediately
    # Use curl or wget
    if command_exists curl; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    elif command_exists wget; then
        sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_error "curl/wget not found; cannot install Oh My Zsh."
        return 1
    fi

    if [ -d "${HOME}/.oh-my-zsh" ]; then
        print_success "Oh My Zsh installed"
        return 0
    else
        print_error "Oh My Zsh installation failed"
        return 1
    fi
}

install_antigen() {
    local antigen_path="${HOME}/antigen.zsh"
    if [ -f "$antigen_path" ]; then
        print_success "Antigen already installed at $antigen_path"
        return 0
    fi

    print_status "Installing Antigen..."
    if command_exists curl; then
        curl -sL git.io/antigen -o "$antigen_path" || return 1
    elif command_exists wget; then
        wget -qO "$antigen_path" git.io/antigen || return 1
    else
        print_error "curl/wget required to install antigen."
        return 1
    fi

    if [ -f "$antigen_path" ]; then
        print_success "Antigen installed to $antigen_path"
        return 0
    else
        print_error "Antigen installation failed"
        return 1
    fi
}

# Function to install Powerlevel10k + recommended plugins
install_powerlevel10k() {
    local method="$1"

    print_status "Installing Powerlevel10k via $method..."

    # Backup existing zshrc once per script run
    if [ ! -f "${HOME}/.zshrc.bak_p10k" ]; then
        cp "${HOME}/.zshrc" "${HOME}/.zshrc.bak_p10k" 2>/dev/null
    fi

    # Remove any previous P10K or plugin lines to avoid duplication
    sed -i '/powerlevel10k/d' "${HOME}/.zshrc" 2>/dev/null
    sed -i '/zsh-autosuggestions/d' "${HOME}/.zshrc" 2>/dev/null
    sed -i '/zsh-syntax-highlighting/d' "${HOME}/.zshrc" 2>/dev/null
    sed -i '/antigen theme/d' "${HOME}/.zshrc" 2>/dev/null
    sed -i '/antigen bundle/d' "${HOME}/.zshrc" 2>/dev/null

    case "$method" in
        "oh-my-zsh")
            # Install theme
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
                "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k" >/dev/null 2>&1

            # Install plugins
            git clone https://github.com/zsh-users/zsh-autosuggestions \
                "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" >/dev/null 2>&1

            git clone https://github.com/zsh-users/zsh-syntax-highlighting \
                "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" >/dev/null 2>&1

            # Update .zshrc
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "${HOME}/.zshrc"

            # Insert plugins
            sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "${HOME}/.zshrc"
            ;;

        "antigen")
            cat << 'EOF' >> "${HOME}/.zshrc"

# Antigen configuration
source ~/antigen.zsh
antigen bundle romkatv/powerlevel10k
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

EOF
            ;;

        "manual")
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
                "${HOME}/powerlevel10k"

            git clone https://github.com/zsh-users/zsh-autosuggestions \
                "${HOME}/zsh-autosuggestions"

            git clone https://github.com/zsh-users/zsh-syntax-highlighting \
                "${HOME}/zsh-syntax-highlighting"

            cat << 'EOF' >> "${HOME}/.zshrc"

# Manual Powerlevel10k setup
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

EOF
            ;;
    esac

    print_success "Powerlevel10k + plugins installed."
}


# Place a default minimal .p10k.zsh if none exists (non-interactive fallback)
place_default_p10k() {
    if [ -f "${HOME}/.p10k.zsh" ]; then
        print_status ".p10k.zsh already exists; leaving it alone."
        return 0
    fi

    # If the theme repo contains a recommended config, try to copy it (oh-my-zsh path)
    local candidate1="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k/config/p10k-classic.zsh"
    local candidate2="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k/config/p10k.zsh"
    local candidate3="${HOME}/powerlevel10k/config/p10k-classic.zsh"

    if [ -f "$candidate1" ]; then
        cp "$candidate1" "${HOME}/.p10k.zsh"
        print_success "Copied default p10k config from $candidate1"
        return 0
    elif [ -f "$candidate2" ]; then
        cp "$candidate2" "${HOME}/.p10k.zsh"
        print_success "Copied default p10k config from $candidate2"
        return 0
    elif [ -f "$candidate3" ]; then
        cp "$candidate3" "${HOME}/.p10k.zsh"
        print_success "Copied default p10k config from $candidate3"
        return 0
    fi

    # If none available, create a very small safe config that disables interactive config
    cat > "${HOME}/.p10k.zsh" <<'EOF'
# Minimal fallback p10k config — very small and non-interactive.
# You can reconfigure later with `p10k configure`.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
# End minimal
EOF

    print_success "Wrote minimal fallback ~/.p10k.zsh (run 'p10k configure' later to customize)"
    return 0
}

main_installation() {
    local method="${1:-$DEFAULT_METHOD}"
    local install_font="${2:-$DEFAULT_INSTALL_FONT}"

    print_status "Automatic installation starting (platform: $PLATFORM). Method=${method}, InstallFont=${install_font}"

    ensure_prereqs || { print_error "Prereq installation failed"; exit 1; }
    install_zsh || { print_error "Zsh installation failed"; exit 1; }

    case "$method" in
        oh-my-zsh)
            install_oh_my_zsh || { print_error "Oh My Zsh install failed"; exit 1; }
            ;;
        antigen)
            install_antigen || { print_error "Antigen install failed"; exit 1; }
            ;;
        manual)
            # nothing special here, will clone later
            ;;
        *)
            print_error "Unsupported install method: $method"
            exit 1
            ;;
    esac

    install_powerlevel10k "$method" || { print_error "Powerlevel10k install failed"; exit 1; }

    if [ "${install_font}" = "yes" ]; then
        install_nerd_font || print_warning "Automatic font install had issues; please install a Nerd Font manually."
    fi

    place_default_p10k

    set_zsh_default || print_warning "Could not make zsh the default shell automatically."

    print_success "Installation finished. Some final notes:"
    print_warning " - If you changed your default shell you may need to log out and back in."
    print_warning " - If your terminal shows garbage symbols, set its font to 'MesloLGS NF' or another Nerd Font."
    print_warning " - To customize your prompt run: p10k configure"
    return 0
}

usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  -y, --yes            Run non-interactive (automatic) using defaults:
                       method=${DEFAULT_METHOD}, install_font=${DEFAULT_INSTALL_FONT}
  -m, --method <name>  Installation method: oh-my-zsh | antigen | manual
  --no-font            Do not install Nerd Font automatically
  -h, --help           Show this help
EOF
}

# Parse args
while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes) AUTO="yes"; shift ;;
        -m|--method) shift; method_arg="$1"; shift ;;
        --no-font) font_arg="no"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown arg: $1"; usage; exit 1 ;;
    esac
done

# Do not run as root
if [ "$(id -u)" -eq 0 ]; then
    print_error "Do NOT run this script as root. Run it as your normal user."
    exit 1
fi

# Determine effective args
INSTALL_METHOD="${method_arg:-$DEFAULT_METHOD}"
INSTALL_FONT="${font_arg:-$DEFAULT_INSTALL_FONT}"

if [ "$AUTO" = "yes" ]; then
    print_status "Running non-interactive with defaults (method=${INSTALL_METHOD}, font=${INSTALL_FONT})"
    main_installation "$INSTALL_METHOD" "$INSTALL_FONT"
    exit $?
fi

# If not automatic, ask interactive prompts (keeping backwards compatibility)
echo -e "${GREEN}=== Powerlevel10k Installation ===${NC}"
echo -e "Platform detected: ${YELLOW}$PLATFORM${NC}"
echo ""
echo "Choose installation method:"
echo "  1) Oh My Zsh (recommended)"
echo "  2) Antigen"
echo "  3) Manual"
echo "  4) Exit"
echo ""
read -r -p "Enter choice [1-4]: " choice
case "$choice" in
    1) INSTALL_METHOD="oh-my-zsh" ;;
    2) INSTALL_METHOD="antigen" ;;
    3) INSTALL_METHOD="manual" ;;
    4) exit 0 ;;
    *) print_error "Invalid selection"; exit 1 ;;
esac

read -r -p "Install Nerd Font automatically? [Y/n]: " yn
case "${yn:-Y}" in
    [Yy]* ) INSTALL_FONT="yes" ;;
    [Nn]* ) INSTALL_FONT="no" ;;
    * ) INSTALL_FONT="yes" ;;
esac

read -r -p "Proceed with installation? [Y/n]: " confirm
case "${confirm:-Y}" in
    [Yy]* ) main_installation "$INSTALL_METHOD" "$INSTALL_FONT";;
    * ) echo "Cancelled"; exit 0 ;;
esac

