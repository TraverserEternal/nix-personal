{ config, lib, pkgs, username, hostname, ... }:

{
  imports = [
    ./hardware.nix
  ] ++ lib.optionals (builtins.pathExists ../modules/generated/hardware.nix) [
    ../modules/generated/hardware.nix
  ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  time.timeZone = "UTC";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  users.users.${username} = {
    isNormalUser = true;
    description = "Main user account";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
    neofetch
    hyprland
    lightdm
    xdg-utils
    wl-clipboard
    grim
    slurp
    wofi
    mako
    foot
    xfce.thunar
  ];

  services.openssh.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Basic firewall
  networking.firewall.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking changes. This should be set to the
  # same value as the nixpkgs flake input.
  system.stateVersion = "24.05";
}
