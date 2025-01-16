{
  description = "My multi-os/user, flake-parts, home-manager, darwin, linux";
  # sudo nixos-rebuild switch --flake .#hostname
  # darwin-rebuild switch --flake .#hostname
  # nix run nix-darwin -- switch --flake ~/.config/nix-darwin
  # home-manager switch --flake .#username@hostname

  # The settings here only affect the flake itself
  nixConfig = {
    substitutors = [
      # Query the mirror of USTC first, and then the official cache.
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    # Nix
    # nix.url = "github:nixos/nix/2.24.7";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2405.0";

    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    # Build a custom WSL installer
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      # url = "github:nix-community/home-manager/master"; # This is unstable
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.flake-utils.follows = "flake-utils";
    };
    # SecureBoot
    lanzaboote = {
      # url = "github:nix-community/lanzaboote/v0.4.1";
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Virtualisation
    # proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VSCodium
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";

    flake-utils.url = "github:numtide/flake-utils";

    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    claude-desktop.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , flake-utils
    , ...
    }@inputs:
    let
      inherit (inputs.flake-schemas) schemas;

      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = import ./overlays { inherit inputs; };

      mkSystem = import ./lib/mksystem.nix {
        inherit overlays nixpkgs inputs;
      };

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
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
    in
    {
      nixosConfigurations = {
        #
        # Linux
        # sudo nixos-rebuild --flake .#coda switch
        # coda = mkSystem "coda" {
        #   system = "x86_64-linux";
        #   user = "jrizzo";
        # };

        # sudo nixos-rebuild --flake .#irl switch
        # irl = mkSystem "irl" {
        #   system = "x86_64-linux";
        #   user = "jrizzo";
        #   isHypervisor = true;
        # };

        # wsl = mkSystem "wsl" {
        #   system = "x86_64-linux";
        #   user = "jrizzo";
        #   isWSL = true;
        # };

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

      #
      # MacOS
      # nix run nix-darwin -- switch --flake .#tymnet
      # darwin-rebuild --flake .#tymnet
      # darwinConfigurations = {
      #   tymnet = mkSystem "tymnet" {
      #     system = "aarch64-darwin";
      #     user = "jrizzo";
      #   };
      # };

      #
      # Setup the packages
      # packages = forEachSupportedSystem (
      #   { pkgs }:
      #   rec {
      #     monitor = inputs.nixos-generators.nixosGenerate rec {
      #       format = "lxc";
      #       system = "x86_64-linux";
      #       specialArgs = { diskSize = toString (20 * 1024); };
      #       # modules = [ ./modules/nixos/monitor.nix ];
      #       modules = [
      #         ({
      #           environment.systemPackages = [ pkgs.man ];
      #           system.stateVersion = "24.05";
      #         })
      #       ];
      #     };

      #     default = monitor;
      #   }
      # );

      #
      # Setting up the formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      #
      # nix flake check
      checks = forEachSupportedSystem (
        { pkgs }:
        {
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              statix.enable = false;
            };
          };
        }
      );

      #
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
