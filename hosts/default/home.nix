# Home Manager Configuration for default host
# This file manages user-specific configurations and applications using
# Home Manager. It provides a clean separation between system-level
# (NixOS) and user-level configurations, allowing for per-user customization
# while maintaining system reproducibility.

{ config, lib, pkgs, username, hostname, ... }:

{
  # Home Manager basic setup
  # The home.stateVersion should match the NixOS stateVersion
  home.stateVersion = "24.05";

  # Basic user information
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Basic shell configuration
  # We start with bash as the default shell; this can be changed to zsh
  # or other shells in later phases when more advanced features are added
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Basic bash configuration
      # Additional shell customizations will be added in later phases
      export PATH="$HOME/.local/bin:$PATH"
      export EDITOR="vim"
    '';

    # Basic shell aliases for common tasks
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  # Basic git configuration
  # Essential development tool configuration
  programs.git = {
    enable = true;
    userName = "TraverserEternal";  # Should be customized per user
    userEmail = "kimball.bradford@gmail.com";  # Should be customized per user

    # Basic git settings for better development experience
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "vim";
    };
  };

  # Development Tools Configuration
  # Configure essential development tools with proper settings

  # VSCode Text Editor
  # Feature-rich code editor with extensions for various languages
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;  # Use open-source version

    # Essential extensions for development
    extensions = with pkgs.vscode-extensions; [
      # Language support
      ms-vscode.cpptools  # C/C++
      ms-python.python  # Python
      rust-lang.rust-analyzer  # Rust
      golang.go  # Go
      ms-vscode.vscode-json  # JSON
      redhat.vscode-yaml  # YAML
      ms-vscode.vscode-typescript-next  # TypeScript

      # Development tools
      ms-vscode.vscode-git-graph  # Git visualization
      eamodio.gitlens  # Git integration
      ms-vscode.vscode-terminal-here  # Terminal integration

      # Utilities
      ms-vscode.vscode-icons  # File icons
      ms-vscode.vscode-theme-seti  # Themes
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # Additional marketplace extensions
      {
        name = "nix-env-selector";
        publisher = "arrterian";
        version = "1.0.9";
        sha256 = "sha256-TkxqWZ8X+PAonzeXQDEsHwcYoLj4g7sF6inK8R+QW8=";
      }
      {
        name = "nix-ide";
        publisher = "jnoortheen";
        version = "0.2.1";
        sha256 = "sha256-yC4yb0kuE8oTg5V5G0b9EF8WNjLpHvPA9sLTpUe9R4c=";
      }
    ];

    # VSCode user settings
    userSettings = {
      # Editor settings
      "editor.fontSize" = 14;
      "editor.fontFamily" = "JetBrains Mono, Fira Code, monospace";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.wordWrap" = "on";
      "editor.minimap.enabled" = false;

      # Workbench
      "workbench.iconTheme" = "vscode-icons";
      "workbench.colorTheme" = "Seti";

      # Terminal
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.fontFamily" = "JetBrains Mono";

      # Git
      "git.autofetch" = true;
      "git.confirmSync" = false;

      # Extensions
      "nixEnvSelector.suggestion" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";

      # Files
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
    };
  };

  # Foot Terminal Emulator
  # Fast, lightweight Wayland terminal with good configuration options
  programs.foot = {
    enable = true;

    settings = {
      main = {
        term = "xterm-256color";
        font = "JetBrains Mono:size=11";
        dpi-aware = "yes";
      };

      colors = {
        alpha = 0.9;
        background = "1e1e2e";  # Catppuccin background
        foreground = "cdd6f4";  # Catppuccin foreground

        # Basic colors
        regular0 = "45475a";   # black
        regular1 = "f38ba8";   # red
        regular2 = "a6e3a1";   # green
        regular3 = "f9e2af";   # yellow
        regular4 = "89b4fa";   # blue
        regular5 = "f5c2e7";   # magenta
        regular6 = "94e2d5";   # cyan
        regular7 = "bac2de";   # white

        bright0 = "585b70";   # bright black
        bright1 = "f38ba8";   # bright red
        bright2 = "a6e3a1";   # bright green
        bright3 = "f9e2af";   # bright yellow
        bright4 = "89b4fa";   # bright blue
        bright5 = "f5c2e7";   # bright magenta
        bright6 = "94e2d5";   # bright cyan
        bright7 = "a6adc8";   # bright white
      };

      # Key bindings
      key-bindings = {
        scrollback-up-page = "Control+Shift+Page_Up";
        scrollback-down-page = "Control+Shift+Page_Down";
        clipboard-copy = "Control+Shift+c";
        clipboard-paste = "Control+Shift+v";
        search-start = "Control+Shift+r";
      };
    };
  };



  # Firefox Web Browser
  # Privacy-focused web browser with modern features
  programs.firefox = {
    enable = true;

    # Firefox profiles and settings
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # Firefox settings for better privacy and usability
      settings = {
        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;

        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;

        # Better security
        "dom.security.https_only_mode" = true;
        "security.ssl.require_safe_negotiation" = true;

        # UI improvements
        "browser.tabs.drawInTitlebar" = true;
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","sidebar-button","fxa-toolbar-menu-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["personal-bookmarks"],"sidebar-box":["sidebar-header","sidebar-panel"]},"seen":["save-to-pocket-button","developer-button","profiler-button"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","sidebar-box"],"currentVersion":18,"newElementCount":4}'';
      };

      # Firefox extensions - commented out due to NUR dependency issues
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   ublock-origin  # Ad blocker
      #   https-everywhere  # Force HTTPS
      #   privacy-badger  # Tracking protection
      #   decentralized-web  # IPFS support
      # ];
    };
  };

  # Wofi Application Launcher
  # Fast, lightweight application launcher for Wayland
  programs.wofi = {
    enable = true;

    # Wofi configuration
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };

    # Wofi styling
    style = ''
      window {
        margin: 0px;
        border: 1px solid #cdd6f4;
        background-color: #1e1e2e;
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #cdd6f4;
        background-color: #181825;
        border-radius: 5px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #cdd6f4;
      }

      #text:selected {
        color: #1e1e2e;
        background-color: #f38ba8;
      }

      #entry {
        border-radius: 5px;
      }

      #entry:selected {
        background-color: #f38ba8;
      }
    '';
  };

  # Mako Notification Daemon
  # Lightweight notification daemon for Wayland
  services.mako = {
    enable = true;

    # Mako configuration
    anchor = "top-right";
    defaultTimeout = 5000;
    ignoreTimeout = true;
    borderSize = 2;
    borderRadius = 10;
    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    progressColor = "over #313244";
    font = "JetBrains Mono 10";

    # Notification grouping
    groupBy = "app-name,summary";

    # Custom formatting
    format = "<b>%s</b>\n%b";
    markup = true;

    # Action buttons
    actions = true;
    actionButtons = true;
    actionKeybindings = [ "button1" "button2" "button3" ];

    # Extra configuration
    extraConfig = ''
      [urgency=low]
      border-color=#a6e3a1

      [urgency=normal]
      border-color=#89b4fa

      [urgency=high]
      border-color=#f38ba8
      default-timeout=0
    '';
  };

  # Basic packages available to the user
  # These are user-specific packages that complement the system packages
  home.packages = with pkgs; [
    # Development tools
    vim
    git
    curl
    wget
    gcc  # C compiler
    gnumake  # Make
    python3  # Python interpreter
    nodejs  # Node.js runtime
    rustc  # Rust compiler
    cargo  # Rust package manager
    go  # Go programming language

    # System utilities
    htop
    neofetch
    tree
    ripgrep
    fd
    bat
    jq  # JSON processor
    yq  # YAML processor

  # Basic productivity
    firefox  # Web browser

    # UI Polish applications
    eww  # Status bar widgets
    overskride  # Bluetooth UI
    cliphist  # Clipboard manager
    pywal  # Dynamic theming

    # Additional utilities
    pavucontrol  # Audio control GUI
    blueman  # Bluetooth manager
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

  # Hyprland Window Manager Configuration
  # We configure Hyprland with basic keybindings, workspaces, and window rules
  # for a productive desktop environment. Advanced features will be added
  # in later phases as applications are integrated.
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Monitor configuration
      # Basic monitor setup; multi-monitor will be configured in Phase 6
      monitor = ",preferred,auto,auto";

      # Environment variables for Wayland session
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt6ct"  # Qt theme integration
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0;
      };

      # Basic keybindings
      # Essential navigation and window management shortcuts
      "$mainMod" = "SUPER";  # Use Super/Windows key as main modifier

      bind = [
        # Application launching
        "$mainMod, Q, exec, foot"  # Terminal
        "$mainMod, C, killactive,"  # Close window
        "$mainMod, M, exit,"  # Exit Hyprland
        "$mainMod, E, exec, thunar"  # File manager
        "$mainMod, F, togglefloating,"  # Toggle floating
        "$mainMod, R, exec, wofi --show drun"  # Application launcher
        "$mainMod, P, pseudo,"  # Toggle pseudo tile
        "$mainMod, J, togglesplit,"  # Toggle split

        # Screenshots
        ", Print, exec, grim - | wl-copy"  # Screenshot to clipboard
        "$mainMod, Print, exec, grim -g \"$(slurp)\" - | wl-copy"  # Area screenshot to clipboard
        "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"  # Area screenshot (alternative)

        # Clipboard manager
        "$mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"  # Clipboard history

        # Workspace navigation
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move windows to workspaces
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Window rules
      # Basic window management rules for common applications
      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(blueman-manager)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(wpa_gui)$"
      ];

      # Layout configuration
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Basic theming
      # Colors and appearance will be enhanced in Phase 5 with Pywal
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Startup applications
      # Essential applications to launch with Hyprland
      exec-once = [
        "mako"  # Notification daemon
        "wl-paste --type text --watch cliphist store"  # Clipboard manager (Phase 5)
        "wl-paste --type image --watch cliphist store"  # Image clipboard
      ];
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
