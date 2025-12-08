# NixOS Configuration for default host
# This file defines the system-level configuration for NixOS, including
# networking, services, and package installations. We follow a modular
# approach where hardware-specific settings are separated into hardware.nix
# and user-specific configurations are handled via Home Manager in home.nix.

{ config, lib, pkgs, username, hostname, ... }:

{
  # Import hardware configuration - this file contains device-specific
  # settings like boot loaders, file systems, and hardware enablement
  imports = [
    ./hardware.nix
  ] ++ lib.optionals (builtins.pathExists ../modules/generated/hardware.nix) [
    ../modules/generated/hardware.nix
  ];

  # Basic system information
  # The hostname uniquely identifies this machine on the network
  networking.hostName = hostname;

  # Enable NetworkManager for easy network configuration
  # This provides a user-friendly way to manage wired and wireless connections
  networking.networkmanager.enable = true;

  # Time zone configuration - set to UTC as a default, can be overridden
  # for specific locations in host-specific configurations
  time.timeZone = "UTC";

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "us";

  # User account configuration
  # We create a user with basic privileges. Additional user configuration
  # like shell preferences, desktop environment settings, and application
  # installations are handled by Home Manager to keep system and user
  # configurations cleanly separated.
  users.users.${username} = {
    isNormalUser = true;
    description = "Main user account";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [
      # Basic utilities available system-wide
      vim
      git
      curl
      wget
    ];
  };

  # Allow unfree packages - necessary for some proprietary software
  # like GPU drivers or certain applications
  nixpkgs.config.allowUnfree = true;

  # Nix configuration
  # Enable flakes for reproducible builds and modern Nix workflows
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic garbage collection to prevent disk space issues
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # System packages - expanding with desktop environment basics
  # We add essential packages for the Hyprland desktop environment
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim
    git
    curl
    htop
    neofetch

    # Desktop environment packages
    hyprland  # Wayland compositor
    lightdm  # Display manager
    xdg-utils  # XDG utilities for desktop integration
    wl-clipboard  # Wayland clipboard utilities
    grim  # Screenshot tool for Wayland
    slurp  # Region selection for screenshots
    wofi  # Application launcher
    mako  # Notification daemon
    foot  # Terminal emulator (will be configured in Phase 4)
    thunar  # File manager (will be configured in Phase 4)
  ];

  # Enable basic services
  # SSH for remote access
  services.openssh.enable = true;

  # Display Manager and Desktop Environment
  # Configure LightDM as the display manager with Hyprland as the default session
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "hyprland";

  # Enable Hyprland Wayland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;  # Enable XWayland for X11 compatibility
  };

  # XDG Portal for desktop integration
  # Required for proper file manager and application integration in Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;  # wlroots portal for Hyprland
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk  # GTK portal for file dialogs
    ];
  };

  # PipeWire Audio System
  # Modern audio system replacing PulseAudio, providing better Wayland
  # integration and professional audio features
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;  # For professional audio applications
  };

  # Security Hardening
  # We implement comprehensive security measures to protect the system
  # from various threats while maintaining usability.

  # Firewall configuration
  # Enable strict firewall with explicit allow rules
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;  # Disable ping for reduced visibility

  # Security services
  # Enable basic security auditing and monitoring
  security.audit.enable = true;
  security.audit.rules = [
    "-a exit,always -F arch=b64 -S execve"
    "-a exit,always -F arch=b32 -S execve"
  ];

  # Sudo configuration
  # Require password for sudo, disable root login
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # Disable root login via SSH for security
  services.openssh.settings.PermitRootLogin = "no";

  # Enable security modules
  security.polkit.enable = true;

  # AppArmor for mandatory access control
  security.apparmor.enable = true;
  services.dbus.apparmor = "enabled";

  # Disable unnecessary services
  # Only enable services that are explicitly needed
  services.avahi.enable = false;  # mDNS discovery
  services.geoclue2.enable = false;  # Location services

  # Kernel hardening
  boot.kernel.sysctl = {
    # Disable core dumps for security
    "kernel.core_pattern" = "|/bin/false";

    # Network hardening
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Disable IPv6 if not needed (uncomment if IPv6 is not required)
    # "net.ipv6.conf.all.disable_ipv6" = 1;
    # "net.ipv6.conf.default.disable_ipv6" = 1;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking changes. This should be set to the
  # same value as the nixpkgs flake input.
  system.stateVersion = "24.05";
}
