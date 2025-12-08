{ config, lib, pkgs, username, hostname, ... }:

{
  home.stateVersion = "24.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      export EDITOR="vim"
    '';
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  programs.git = {
    enable = true;
    userName = "TraverserEternal";
    userEmail = "kimball.bradford@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "vim";
    };
  };

  # Basic development tools - keeping it simple
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  # Foot Terminal Emulator - basic setup
  programs.foot = {
    enable = true;
  };



  # Firefox Web Browser - basic setup
  programs.firefox = {
    enable = true;
  };

  # Wofi Application Launcher - basic setup
  programs.wofi = {
    enable = true;
  };

  # Mako Notification Daemon - basic setup
  services.mako = {
    enable = true;
  };

  # Basic packages - keeping it minimal
  home.packages = with pkgs; [
    # Essential development tools
    vim
    git
    curl
    python3
    nodejs
  ];

  # Basic XDG configuration
  # Standardize user directories and configuration locations
  xdg = {
    enable = true;

    # User directories (Documents, Downloads, etc.)
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    # MIME type associations
    # Basic associations that will be expanded in later phases
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = "vim.desktop";
        "inode/directory" = "thunar.desktop";  # Will be configured in Phase 4
      };
    };
  };

  # Basic font configuration
  # Fonts will be expanded significantly in theming phases
  fonts.fontconfig.enable = true;

  # Hyprland Window Manager - basic setup
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Q, exec, foot"
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, E, exec, thunar"
        "$mainMod, R, exec, wofi --show drun"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
      ];

      monitor = ",preferred,auto,auto";
    };
  };

  # Basic theming placeholder
  # GTK/Qt themes and icon themes will be configured in Phase 5
  # along with dynamic theming via Pywal

  # Basic service configuration
  # User services will be added as needed (e.g., syncthing, dropbox)

  # Environment variables
  # Basic environment setup; will be expanded with development tools
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    BROWSER = "firefox";
  };

  # Basic session path
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
