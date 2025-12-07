{
  description = "Personal NixOS configuration with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Helper function to create NixOS configurations
      mkNixosConfig = { hostname, username ? "user" }: nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit self nixpkgs home-manager username hostname;
        };

        modules = [
          ./hosts/${hostname}/configuration.nix
          ./hosts/${hostname}/hardware.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
            home-manager.extraSpecialArgs = {
              inherit self nixpkgs home-manager username hostname;
            };
          }
        ];
      };

    in {
      nixosConfigurations = {
        default = mkNixosConfig {
          hostname = "default";
          username = "kimba";  # Replace with actual username
        };
      };

      # Development shell for testing configurations
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixos-generators
          git
          vim
        ];

        shellHook = ''
          echo "NixOS Configuration Development Environment"
          echo "Available commands:"
          echo "  nixos-rebuild build-vm --flake .#default  # Build VM for testing"
          echo "  home-manager switch --flake .#default     # Test home-manager config"
        '';
      };
    };
}
