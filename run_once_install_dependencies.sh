#!/bin/bash
# run_once_install_dependencies.sh
# This script installs all dependencies needed for the dotfiles configuration.
# It will only run once during the first `chezmoi apply`.

set -e

echo "🚀 Starting dotfiles dependency installation..."

# Detect OS
if [[ "$(uname)" == "Darwin" ]]; then
    OS="macos"
elif [[ "$(uname)" == "Linux" ]]; then
    OS="linux"
else
    echo "❌ Unsupported OS: $(uname)"
    exit 1
fi

echo "📦 Detected OS: $OS"

# Install Homebrew if not present (macOS)
if [[ "$OS" == "macos" ]] && ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages via Homebrew (macOS) or apt (Linux)
if [[ "$OS" == "macos" ]]; then
    echo "📦 Installing packages via Homebrew..."
    brew install neovim tmux yazi glow ripgrep fzf git zsh chezmoi
elif [[ "$OS" == "linux" ]]; then
    echo "📦 Installing packages via apt..."
    sudo apt update
    sudo apt install -y neovim tmux ripgrep fdfind git zsh curl
    # Install yazi and glow manually or via cargo if needed
    if ! command -v yazi &> /dev/null; then
        echo "📦 Installing yazi via cargo..."
        cargo install yazi-fm yazi-cli
    fi
    if ! command -v glow &> /dev/null; then
        echo "📦 Installing glow via snap or go..."
        sudo snap install glow --classic || go install github.com/charmbracelet/glow@latest
    fi
fi

# Install LunarVim if not present
if ! command -v lvim &> /dev/null; then
    echo "🌙 Installing LunarVim..."
    curl -sSf https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash
fi

# Install Nerd Font (optional but recommended for icons)
if [[ "$OS" == "macos" ]]; then
    echo "🔤 Installing Nerd Fonts..."
    brew install --cask font-jetbrains-mono-nerd-font
fi

echo "✅ Dependency installation complete!"
echo "📝 Please remember to create ~/.secrets file with your API keys."
echo "🔄 Run 'chezmoi apply' again to ensure all configurations are linked."
