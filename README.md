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
git clone https://github.com/germanex3000dev/Automated-Powerlevel10k-Installation
```
```bash
cd Automated-Powerleveleok-Installation
```
```bash
sh install.sh
```

---

The script provides an interacive menu for:
 - Installation method
 - Nerd Font installation
 - Confirmation before applying changes

---

## ✔ Installation Methods
### Oh My Zsh (Recommended)
Installs OMZ, Powerlevel10k, plugins and configures everything automatically

### Antigen
Lightweight plugin manager
The script auto-generates:
```bash
antigen bundle romkatv/powerlevel10k
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
```

### Manual
For advanced users
The script clones repos and adds:
```bash
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/zsh-autosuggestions/zsh-sutosuggestions.zsh
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

---

## Nerd Font Installation
If enabled, the script installs the recommended font:
 - MesloLGS Regular
 - MesloLGS Bold
 - MesloLGS Italic
 - MesloLGS Bold Italic
On Linux, `fc-cache` is refreshed automatically.

You must manually select MesloLGS NF in your termianl profile.

---

## After Installation
 1. Log out and log back in
 2. Change your terminal font to **MesloLGS NF**
 3. Run:
    ```bash
    p10k configure
    ```
This luanches the Powerlevel10k setup wizard

---

## Uninstallation
Your original `.zshrc` was backed up as:
```bash
~/.zshrc.back_p10k
```
Restore it manually:
```bash
mv ~/.zshrc.back_p10k ~/.zshrc
```

## Message from me
Hey it's me, Germanex3000. I'm planning on publishing more automation scripts and also other scripts to make your linux life easier. Other than that I'm planning on making other projects, too. So, I would really appreciate it, if you could star this repo and support me. That was all. Have fun and don't forget to touch grass :D

Yours
Germanex3000
