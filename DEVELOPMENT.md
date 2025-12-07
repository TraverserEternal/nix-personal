# Development Notes for nix-personal

This document outlines the development plan, technologies, and implementation details for the personal NixOS configuration.

## Project Overview

This project aims to create a fully declarative NixOS system configuration using Nix Flakes, with Hyprland as the primary window manager for a modern, productive desktop environment.

## Core Technologies

- **NixOS**: Base operating system with declarative configuration
- **Nix Flakes**: For reproducible builds and dependency management
- **Home Manager**: User environment and application configuration management
- **Hyprland**: Wayland compositor for window management
- **Additional Technologies**:
  - **Terminal emulator**: Foot
  - **Status bar and widgets**: Eww
  - **Application launcher**: Wofi
  - **Text editor**: VSCode
  - **Audio system**: PipeWire
  - **Notification daemon**: Mako
  - **File manager**: Thunar
  - **Dynamic theming**: Pywal (for background-based theme synchronization)
  - **Display manager**: LightDM
  - **Screenshot tool**: Grim + Slurp
  - **Clipboard manager**: Cliphist
  - **Bluetooth UI**: Overskride (modern GTK4/libadwaita interface)

## Planned Features

### Desktop Environment
- Hyprland configuration with custom keybindings
- Multiple monitor support
- Workspace management
- Window rules and animations

### System Configuration
- User management
- Networking setup
- Hardware configuration (GPU, audio, etc.)
- **Full Disk Encryption**: LUKS encryption for complete drive security
- Security settings
- Service management
- **Auto-configuration tool**: Hardware detection and config generation for new systems

### Applications
- **Terminal**: Foot with custom configuration
- **Text Editor**: VSCode with extensions and settings
- **File Manager**: Thunar with custom actions
- **Application Launcher**: Wofi with custom themes
- **Status Bar**: Eww with custom widgets and layouts
- **Notifications**: Mako with custom styling
- **Audio**: PipeWire with audio tools
- Development tools (git, compilers, IDEs)
- Productivity software
- Media applications
- System utilities

### Theming
- **Dynamic Background System**: Random wallpaper selection on login with Pywal integration
- **Theme Synchronization**: Automatic color scheme generation from background for all applications
- Consistent color scheme across applications (Foot, VSCode, Mako, Eww, Wofi, Thunar)
- Custom wallpapers collection
- Font configuration
- Icon themes

## Auto-Configuration Tool

A key feature of this project is an automated hardware detection and configuration generation tool that can set up NixOS on any computer with minimal manual intervention.

### Functionality
- **GPU Detection**: Identify NVIDIA, AMD, or Intel GPUs and apply appropriate drivers and configuration
- **Display Detection**: Auto-detect connected monitors and configure display settings (resolution, refresh rate, positioning)
- **Hardware Profiling**: Generate hardware.nix with detected components (CPU, RAM, storage, network interfaces)
- **Encryption Setup**: Configure LUKS full disk encryption with user-defined passwords
- **NixOS Config Generation**: Create initial configuration.nix with sane defaults based on detected hardware
- **Flake Integration**: Seamlessly integrate generated configs into the flake structure

### Implementation Approach
- Shell script using `lspci`, `lshw`, `xrandr`, and other system utilities for hardware detection
- Nix flake app for easy execution: `nix run .#generate-config`
- Template-based config generation with hardware-specific modules
- User prompts for confirmation and customization options

### Usage
```bash
# Run on a new system to generate configuration
sudo nix run .#generate-config -- --output hosts/new-host

# Review and customize generated files
# Then build the system
sudo nixos-rebuild switch --flake .#new-host
```

## Home Manager Integration

Home Manager will be integrated to manage user-specific configurations for all applications and tools. This provides a clean separation between system-level (NixOS) and user-level (Home Manager) configurations.

### Configuration Areas
- **Application Settings**: Custom configurations for Foot, VSCode, Mako, Eww, Wofi, Thunar
- **Shell Environment**: Zsh/bash configuration, aliases, environment variables
- **Development Tools**: Git configuration, editor settings, language-specific tools
- **Theming Integration**: Pywal color scheme application to user applications
- **Keyboard Shortcuts**: Application-specific keybindings
- **File Associations**: Default applications for different file types

### Structure
Home Manager configurations will be stored in `home.nix` files within each host directory, allowing for host-specific user configurations while maintaining reusability through shared modules.

## Full Disk Encryption

For complete drive security requiring password authentication, the system will implement LUKS (Linux Unified Key Setup) full disk encryption.

### Implementation Approach
- **LUKS on LVM**: Encrypted logical volumes for root, home, and swap partitions
- **Initrd Secrets**: Store encryption key in initrd for seamless boot process
- **TPM Integration**: Optional TPM 2.0 support for hardware-backed key storage
- **Auto-configuration Integration**: Encryption setup included in the generate-config tool

### Security Features
- **PBKDF2/Argon2**: Strong key derivation functions
- **AES-XTS**: Military-grade encryption cipher
- **Anti-forensic Features**: Multiple encryption passes and secure erase
- **Key Management**: Secure key storage and rotation capabilities

### Configuration
```nix
# Example LUKS configuration in hardware.nix
boot.initrd.luks.devices = {
  "root" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX-XXXX-XXXX";
    preLVM = true;
    allowDiscards = true;
  };
};
```

### User Experience
- Password prompt during boot before initrd loads
- Secure hibernation with encrypted swap
- Automatic unlock for additional encrypted volumes
- Emergency recovery options for lost passwords

## Configuration Structure

The flake structure will follow NixOS best practices:

```
flake.nix                    # Main flake definition
flake.lock                   # Lock file for dependencies
hosts/                       # Host-specific configurations
  └── default/               # Default host configuration
      ├── configuration.nix  # NixOS configuration
      ├── hardware.nix       # Hardware-specific settings
      └── home.nix          # Home manager configuration
modules/                     # Reusable NixOS modules
  ├── desktop/               # Desktop environment modules
  ├── hardware/              # Hardware-specific modules
  └── apps/                  # Application modules
scripts/                     # Utility scripts and tools
  └── generate-config.sh     # Auto-configuration tool
overlays/                    # Nixpkgs overlays
```

## Development Roadmap

### Phase 1: Core Setup
- [ ] Initialize flake structure
- [ ] Basic NixOS configuration
- [ ] Hardware configuration
- [ ] User setup

### Phase 2: Desktop Environment
- [ ] Hyprland installation and basic config
- [ ] Display manager setup
- [ ] Basic window management

### Phase 3: Applications and Tools
- [ ] Terminal emulator
- [ ] Text editor
- [ ] Application launcher
- [ ] Status bar

### Phase 4: Customization
- [ ] Theming and appearance
- [ ] Keybindings optimization
- [ ] Performance tuning

### Phase 5: Advanced Features
- [ ] Multi-monitor setup
- [ ] Backup and restore
- [ ] Testing and validation

## Development Notes

### NixOS Best Practices
- Use `lib.mkDefault` for user-overridable options
- Separate host-specific and generic configurations
- Leverage home-manager for user-specific settings
- Keep configurations modular and reusable

### Hyprland Configuration
- Use hyprland.conf for main configuration
- Consider separate config files for different aspects
- Test configurations on a VM before applying to main system

### Testing Strategy
- Use NixOS containers for testing configurations
- Maintain separate branches for experimental features
- Document breaking changes and migration steps

### Security Considerations
- **Full Disk Encryption**: LUKS encryption for complete drive security requiring password on boot
- Enable firewall and basic security modules
- Use secure boot when possible
- Regularly update system and applications
- Implement proper user permissions and sudo configuration
- Enable security auditing and logging

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Hyprland Wiki](https://hyprland.org/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

## Development Task List (Layered Architecture Approach)

### Phase 1: Core Infrastructure Setup
- [ ] Initialize Nix Flakes structure with flake.nix and flake.lock
- [ ] Create basic hosts/default directory structure
- [ ] Set up Home Manager integration in flake.nix
- [ ] Create initial configuration.nix with minimal NixOS config
- [ ] Create initial home.nix with basic Home Manager setup
- [ ] Configure user accounts and basic permissions
- [ ] Test basic flake build and switch capability

### Phase 2: System Foundation
- [ ] Implement LUKS full disk encryption configuration
- [ ] Set up networking (NetworkManager or systemd-networkd)
- [ ] Configure hardware-specific modules (GPU drivers, audio, etc.)
- [ ] Implement security hardening (firewall, sudo, auditing)
- [ ] Set up system services and basic packages
- [ ] Configure boot process and initrd settings
- [ ] Test encrypted boot process and recovery options

### Phase 3: Desktop Base
- [ ] Install and configure Hyprland window manager
- [ ] Set up LightDM display manager with Hyprland session
- [ ] Implement basic Hyprland configuration (keybindings, workspaces)
- [ ] Configure display settings and multi-monitor support
- [ ] Set up basic window management rules
- [ ] Test desktop environment boot and basic functionality
- [ ] Configure basic theming (fonts, colors, GTK/Qt themes)

### Phase 4: Essential Applications
- [ ] Install and configure Foot terminal emulator
- [ ] Set up VSCode with essential extensions
- [ ] Configure Thunar file manager with custom actions
- [ ] Implement PipeWire audio system
- [ ] Set up basic development tools (git, compilers, etc.)
- [ ] Configure application defaults and MIME types
- [ ] Test application integration and basic workflows

### Phase 5: UI Polish
- [ ] Implement Eww status bar with custom widgets
- [ ] Configure Wofi application launcher with themes
- [ ] Set up Mako notification daemon with custom styling
- [ ] Install and configure Overskride Bluetooth UI
- [ ] Integrate Grim + Slurp for screenshots
- [ ] Implement Cliphist clipboard manager
- [ ] Polish theming consistency across all applications

### Phase 6: Smart Features
- [ ] Develop auto-configuration tool hardware detection
- [ ] Implement Pywal dynamic theming system
- [ ] Create wallpaper rotation script for login
- [ ] Configure theme synchronization across applications
- [ ] Implement multi-monitor advanced features
- [ ] Add backup and restore capabilities
- [ ] Performance tuning and optimization

### Phase 7: Testing & Documentation
- [ ] Create comprehensive testing strategy
- [ ] Test on multiple hardware configurations
- [ ] Document installation and usage procedures
- [ ] Create troubleshooting guides
- [ ] Implement automated testing where possible
- [ ] Final integration testing and validation

## Remaining Research Tasks

- Research optimal Hyprland configuration patterns
- Plan hardware-specific configurations for common GPUs/CPUs
- Set up development environment for testing (VM/container setup)
