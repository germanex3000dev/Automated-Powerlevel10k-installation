# Powerlevel10k Automated Installer

![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue)
![Shell](https://img.shields.io/badge/Shell-Zsh-green)
![Powerlevel10k](https://img.shields.io/badge/Theme-Powerlevel10k-purple)
![Status](https://img.shields.io/badge/Automation-100%25-success)

A fully automated installer for **Zsh**, **Powerlevel10k**, Nerd Fonts, and optional plugin frameworks (Oh My Zsh, Antigen, or manual setup).  
This script configures a complete Zsh environment with minimal user interaction.

---

## Features

### ✔ Automated Setup
- Installs Zsh and sets it as the default shell  
- Installs Powerlevel10k  
- Installs MesloLGS Nerd Fonts  
- Sets up plugins automatically  
- Writes and backs up `.zshrc`  
- Works on Linux and macOS  

### ✔ Plugin Support
Depending on installation method, the script installs and activates:

- `zsh-autosuggestions`  
- `zsh-syntax-highlighting`  

### ✔ Multiple Installation Methods
- **Oh My Zsh**  
- **Antigen**  
- **Manual setup**  

Choose what fits your workflow.

---

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/<yourname>/<reponame>.git
cd <reponame>
chmod +x install.sh
./install.sh
