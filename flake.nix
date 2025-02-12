{
  description = "My multi-os/user, flake-parts, home-manager, darwin, linux";

  nixConfig = {
    # The settings here only affect the flake itself
    substitutors = [
      # Query the mirror of USTC first, and then the official cache.
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-darwin.url = "github:LnL7/nix-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url = "github:nix-community/home-manager";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/master";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixified-ai.url = "github:nixified-ai/flake/comfyui-unwrapped";
    dream2nix.url = "github:nix-community/dream2nix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    inputs@{ self
    , nix-darwin
    , nixpkgs
    , home-manager
    , pre-commit-hooks
    , flake-schemas
    , nixos-generators
    , ...
    }:
    let
      currentSystemUser = "jrizzo";
      supportedSystems =
        [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
      forAllSystems =
        f:
        builtins.listToAttrs (
          map
            (system: {
              name = system;
              value = f system;
            })
            supportedSystems
        );

      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs; };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#tymnet
      darwinConfigurations = {
        tymnet = mkSystem "tymnet" {
          system = "aarch64-darwin";
          user = currentSystemUser;
        };
      };

      nixosConfigurations = {
        coda = mkSystem "coda" {
          system = "x86_64-linux";
          user = currentSystemUser;
        };

        # sudo nixos-rebuild --flake .#irl switch
        irl = mkSystem "irl" {
          system = "x86_64-linux";
          user = currentSystemUser;
        };

        winnie = mkSystem "winnie" {
          system = "x86_64-linux";
          user = currentSystemUser;
          isWSL = true;
        };

        # Virtual Machines & Containers
        # nixos-rebuild --flake .#vm-intel build-vm
        # vm-intel = mkSystem "vm-intel" {
        #   system = "x86_64-linux";
        #   user = "jrizzo";
        # };
        # nixos-rebuild --flake .#vm-aarch64-prl build-vm
        # nixosConfigurations.vm-aarch64-prl = mkSystem "vm-aarch64-prl" {
        #   system = "aarch64-linux";
        #   user = "jrizzo";
        # };
      };

      inherit (inputs.flake-schemas) schemas;

      # Setup the packages
      packages = forEachSupportedSystem ({ pkgs }:
        rec {
          monitor = inputs.nixos-generators.nixosGenerate rec {
            format = "lxc";
            system = "x86_64-linux";
            specialArgs = { diskSize = toString (20 * 1024); };
            # modules = [ ./modules/nixos/monitor.nix ];
            modules = [
              ({
                environment.systemPackages = [ pkgs.man ];
                system.stateVersion = "24.11";
              })
            ];
          };

          default = monitor;
        }
      );

      # Setting up the formatter
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # nix flake check
      checks = forEachSupportedSystem (
        { pkgs }:
        {
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };
        }
      );

      # Setting up my dev shells
      # nix develop
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            # inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
            # buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
            packages = with pkgs; [
              git
              nixpkgs-fmt
              statix
            ];
          };
        }
      );
    };
}
