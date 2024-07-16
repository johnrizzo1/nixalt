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

    catppuccin.url = "github:catppuccin/nix";
    nix-colors.url = "github:misterio77/nix-colors";
    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    ez-configs.url = "github:ehllie/ez-configs";
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  outputs = inputs: let
    # Default user settings
    user_config = {
      users = {
        jrizzo = {
          shell = "zsh";
          isNormalUser = true;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvMhfDwNu09O52SU7iftNAypNfPgQ8M8FQewdumQApW"
          ];
          extraGroups = ["networkmanager" "wheel" "docker"];
        };

        jrizzo_info = {
          username = "jrizzo";
          fullname = "John D. Rizzo";
          useremail = "johnrizzo1@gmail.com";
          environment.sessionVariables = {
            NIXOS_OZONE_WL = "1";
          };
          git.default_branch = "main";
        };
      };
    };

    host_config = {
      coda = {
        hostname = "coda";
        nix.settings.trusted-users = ["root" "@wheel"];
        networking.firewall.allowedTCPPorts = [22];
        networking.firewall.allowedUDPPorts = [];
        time.timeZone = "America/New_York";
      };
    };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.ez-configs.flakeModule
        inputs.devenv.flakeModule
      ];

      systems = ["x86_64-linux"];

      ezConfigs = {
        root = ./.;
        globalArgs = {inherit inputs user_config host_config;};

        home = {
          # configurationsDirectory = ./home;
          # modulesDirectory = ./modules;
          users = {
            jrizzo = {importDefault = true;};
            root = {importDefault = false;};
          };
        };

        nixos = {
          # configurationsDirectory = ./host;
          # modulesDirectory = ./host;
          hosts = {
            # coda = {
            #   userHomeModules = ["jrizzo"];
            # };
          };
        };

        # darwin.configurationsDirectory = ./host;
        # darwin.modulesDirectory = ./modules/host/darwin;
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
        # _module.args.pkgs = import inputs.nixpkgs {
        #   inherit system;
        #   # overlays = [ inputs.sops-nix.overlays.default ];
        # };

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;
        formatter = pkgs.alejandra;

        devenv.shells.default = {
          devenv.root = let
            devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
          in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
          # devenv.root = ./.;

          name = "my nix config";

          imports = [
            # This is just like the imports in devenv.nix.
            # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            # ./devenv-foo.nix
          ];

          # https://devenv.sh/reference/options/
          packages = [config.packages.default];

          enterShell = ''
            hello
          '';

          processes.hello.exec = "hello";
        };
      };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
