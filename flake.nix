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

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    # Nix
    nix.url = "github:nixos/nix/2.24.1";
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    catppuccin.url = github:catppuccin/nix;
    nix-colors.url = github:misterio77/nix-colors;
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-schemas.url = github:DeterminateSystems/flake-schemas/v0.1.5;
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";
    # bitcoin
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {
    imports = [
      inputs.ez-configs.flakeModule
      inputs.devenv.flakeModule
    ];

    # systems = pkgs.lib.systems.flakeExpose;
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    ezConfigs = {
      root = ./.;
      darwin.configurationsDirectory = ./hosts/darwin;
      darwin.modulesDirectory = ./modules/darwin;
      home.configurationsDirectory = ./homes;
      home.modulesDirectory = ./modules/home;
      nixos.configurationsDirectory = ./hosts/nixos;
      nixos.modulesDirectory = ./modules/nixos;

      globalArgs = {inherit inputs;};
      home.users.jrizzo.importDefault = true;
      home.users.root.importDefault = false;
      # nixos.hosts.coda.userHomeModules = ["root" "jrizzo"];
      # darwin.hosts.tymnet.userHomeModules = ["jrizzo"];
    };
    
    perSystem = {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }: {
      # Per-system attributes can be defined here. The self' and inputs'
      # module parameters provide easy access to attributes of the same
      # system.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit inputs system;
        overlays = import ./overlays {inherit inputs system;};
        config.allowUnfree = true;
      };

      packages.default = pkgs.hello;
      formatter = pkgs.alejandra;

      # Set Git commit hash for darwin-version.
      # system.configurationRevision = self'.rev or self'.dirtyRev or null;
    };

    flake = {
      # The usual flake attributes can be defined here, including system-
      # agnostic ones like nixosModule and system-enumerating ones, although
      # those are more easily expressed in perSystem.
      schemas = inputs.flake-schemas.schemas;
      devenv.shells.default = import ./devenv.nix;
    };
  };
}
