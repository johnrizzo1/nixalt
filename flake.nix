{
  description = "My multi-os/user, flake-parts, home-manager, darwin, linux";
  # sudo nixos-rebuild switch --flake .#hostname
  # home-manager switch --flake .#username@hostname

  # The settings here only affect the flake itself
  nixConfig = {
    substitutors = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # darwin = {
    #   url = "github:lnl7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs-darwin";
    # };

    nix-colors.url = "github:misterio77/nix-colors";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-colors,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Default user settings
    user_config = {
      username = "jrizzo";
      useremail = "johnrizzo1@gmail.com";
      fullname = "John Rizzo";
    };

    defaultSpecialArgs = { inherit inputs outputs user_config; };
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/host;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = let
      specialArgs = defaultSpecialArgs // { inherit nix-colors; };
    in {
      coda = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            # > Our main nixos configuration file <
            ./host/coda.nix
          ];
        };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = let
      user_config = {
        username = "jrizzo";
        fullname = "John D. Rizzo";
      };
      specialArgs = defaultSpecialArgs // { inherit user_config nix-colors; };
    in {
      "jrizzo@coda" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = specialArgs;
          # specialArgs // { inherit user_config nix-colors; };
        modules = [
          ./home/jrizzo.nix
        ];
      };
    };
  };
}
