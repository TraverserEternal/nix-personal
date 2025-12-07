# nix-personal

A personal NixOS configuration managed with Nix Flakes, featuring Hyprland as the window manager and other modern tools for a productive desktop environment.

## Technologies

- **NixOS**: Declarative Linux distribution
- **Nix Flakes**: Reproducible package management
- **Home Manager**: User environment configuration management
- **Hyprland**: Dynamic tiling Wayland compositor
- **Terminal**: Foot
- **Status Bar**: Eww
- **Application Launcher**: Wofi
- **Text Editor**: VSCode
- **Audio System**: PipeWire
- **Notifications**: Mako
- **File Manager**: Thunar
- **Dynamic Theming**: Pywal (background-based theme synchronization)

## Features

- Declarative system configuration
- Reproducible environment
- Modern desktop experience with Hyprland
- Modular configuration structure
- **Dynamic theming system**: Random wallpaper selection on login with automatic theme synchronization across all applications
- **Auto-configuration tool**: Automatically detects hardware (GPU, displays) and generates NixOS configuration for any computer

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/TraverserEternal/nix-personal.git
   cd nix-personal
   ```

2. Build and switch to the configuration:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

## Usage

After installation, the system will boot with Hyprland as the default window manager. Additional configuration and tools will be available as development progresses.

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development notes, planned features, and implementation roadmap.

## Contributing

This is a personal configuration, but feel free to open issues or PRs with suggestions.

## License

MIT License
