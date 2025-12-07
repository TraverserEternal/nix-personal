# nix-personal

A comprehensive, declarative NixOS configuration featuring Hyprland as the window manager, modern Wayland tools, and automated hardware detection for seamless deployment across different systems.

## 🎯 Overview

This project provides a fully declarative NixOS system configuration that transforms any compatible hardware into a modern, productive desktop environment. Built with Nix Flakes for reproducibility and Home Manager for user environment management.

## 🛠️ Technologies

### Core System
- **NixOS**: Declarative Linux distribution with atomic updates
- **Nix Flakes**: Reproducible package and system management
- **Home Manager**: User environment and application configuration

### Desktop Environment
- **Hyprland**: Dynamic tiling Wayland compositor
- **LightDM**: Display manager with slick-greeter
- **XDG Portal**: Desktop integration for Wayland applications

### Applications
- **Terminal**: Foot (fast, lightweight Wayland terminal)
- **Text Editor**: VSCode with Nix and development extensions
- **File Manager**: Thunar with archive and volume management
- **Application Launcher**: Wofi with custom theming
- **Notifications**: Mako with urgency-based styling
- **Audio System**: PipeWire (professional audio with JACK support)
- **Browser**: Firefox with privacy extensions and custom configuration

### Utilities
- **Screenshot Tool**: Grim + Slurp for Wayland screenshots
- **Clipboard Manager**: Cliphist with history management
- **Bluetooth UI**: Overskride (modern GTK4 interface)
- **Dynamic Theming**: Pywal for background-based theme synchronization

## ✨ Key Features

### 🔒 Security First
- **Full Disk Encryption**: LUKS encryption with secure key management
- **Hardened Kernel**: Security-focused sysctl settings
- **Firewall**: Strict iptables rules with explicit allow policies
- **AppArmor**: Mandatory access control for applications
- **Secure Boot**: TPM-ready configuration

### 🎨 Dynamic Theming System
- Random wallpaper selection on login
- Automatic color palette generation from backgrounds
- Theme synchronization across all applications (Foot, VSCode, Mako, Wofi, etc.)
- Consistent Catppuccin-inspired color scheme

### 🤖 Auto-Configuration Tool
- **Hardware Detection**: Automatic GPU, CPU, and display detection
- **Driver Selection**: NVIDIA, AMD, or Intel GPU configuration
- **Partition Setup**: LUKS encryption and LVM configuration
- **One-Command Setup**: `./scripts/generate-config.sh` for new systems

### 📱 Modern Desktop Experience
- **Wayland Native**: True Wayland implementation with XWayland compatibility
- **Tiling WM**: Efficient window management with Hyprland
- **Smooth Animations**: Fluid transitions and visual effects
- **Multi-Monitor**: Advanced display configuration support

## 🚀 Quick Start

### Prerequisites
- NixOS installation media
- Internet connection
- UEFI-compatible system (recommended)

### Installation

1. **Boot into NixOS Live Environment**
   ```bash
   # Boot from NixOS installation media
   ```

2. **Clone Repository**
   ```bash
   git clone https://github.com/TraverserEternal/nix-personal.git
   cd nix-personal
   ```

3. **Generate Hardware-Specific Configuration**
   ```bash
   # For new systems - auto-detect hardware
   sudo ./scripts/generate-config.sh --output hosts/my-host

   # Edit generated files to customize (username, hostname, etc.)
   # Replace PLACEHOLDER UUIDs with actual partition UUIDs
   ```

4. **Build and Install**
   ```bash
   # Test the configuration
   sudo nixos-rebuild build --flake .#my-host

   # Install to disk
   sudo nixos-rebuild switch --flake .#my-host
   ```

5. **Reboot**
   ```bash
   # System will boot with Hyprland desktop environment
   reboot
   ```

### Alternative: Use Existing Configuration

For systems with similar hardware to the default configuration:

```bash
# Edit hosts/default/ files to match your system
# Update UUIDs, hostname, username in configuration.nix and home.nix

# Build and switch
sudo nixos-rebuild switch --flake .#default
```

## 📖 Usage Guide

### First Boot
After installation, you'll be greeted with:
- LightDM display manager
- Hyprland desktop environment
- Pre-configured applications and keybindings

### Essential Keybindings

| Keybinding | Action |
|------------|--------|
| `Super + Q` | Launch terminal (Foot) |
| `Super + E` | Launch file manager (Thunar) |
| `Super + R` | Application launcher (Wofi) |
| `Super + C` | Close active window |
| `Super + F` | Toggle floating mode |
| `Super + V` | Clipboard history |
| `Super + M` | Exit Hyprland |
| `Super + [1-0]` | Switch workspaces |
| `Super + Shift + [1-0]` | Move window to workspace |
| `Print` | Screenshot to clipboard |
| `Super + Print` | Area screenshot |

### Customization

#### User Configuration
Edit `hosts/default/home.nix` for user-specific settings:
- Git configuration
- Shell preferences
- Application settings

#### System Configuration
Edit `hosts/default/configuration.nix` for system-wide changes:
- Networking
- Services
- Package installations

#### Hardware Configuration
Edit `hosts/default/hardware.nix` for hardware-specific settings:
- GPU drivers
- Boot configuration
- Device-specific options

### Dynamic Theming
The system includes Pywal for dynamic theming. Wallpapers are randomly selected on login, and colors are automatically applied to:
- Foot terminal
- VSCode editor
- Mako notifications
- Wofi launcher
- System borders and accents

## 🔧 Development & Testing

### Development Environment
```bash
# Enter development shell with tools
nix develop

# Build VM for testing (requires nixos-generators)
nixos-rebuild build-vm --flake .#default
```

### Testing Strategy
- **VM Testing**: Use NixOS containers for configuration validation
- **Hardware Testing**: Test on multiple hardware configurations
- **Automated Testing**: Run `./scripts/test-config.sh` for basic validation

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make changes following the modular structure
4. Test thoroughly
5. Submit a pull request

## 🐛 Troubleshooting

### Common Issues

#### Build Fails
```bash
# Check for syntax errors
nix flake check

# Build without switching
sudo nixos-rebuild build --flake .#default
```

#### GPU Issues
- Ensure correct GPU drivers in `hardware.nix`
- Check Xorg/Hyprland logs: `journalctl -u display-manager`

#### Network Problems
- Verify NetworkManager: `nmcli device status`
- Check firewall rules: `iptables -L`

#### Permission Issues
- Ensure user is in correct groups: `groups $USER`
- Check sudo configuration: `sudo -l`

### Recovery Options
- **Emergency Mode**: Boot with `systemd.unit=emergency.target`
- **Single User**: Boot with `systemd.unit=rescue.target`
- **Live USB**: Boot from installation media for repairs

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Hyprland Wiki](https://hyprland.org/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)

## 📝 Development Roadmap

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development notes and implementation roadmap.

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

This is a personal configuration, but contributions are welcome! Please:
- Open issues for bugs or feature requests
- Submit PRs for improvements
- Follow the established code style and structure

---

**Happy Nixing!** 🎉
