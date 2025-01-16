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
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11";
    # nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
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

      coda_configuration = { pkgs, config, lib, ... }: {
        boot = {
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
        };

        # Host Specific Applications
        environment = {
          systemPackages = with pkgs; [
            _1password-gui
            # home-manager
            # kitty
            # smplayer
            # vscodium
            ##cudatoolkit
            ##jan
            alpaca # ollama GUI
            beeper
            cachix
            calibre
            chromium
            devenv
            direnv
            discord
            element-desktop
            firefox
            freetube
            gimp
            git
            gitkraken
            # inputs.claude-desktop.packages.${pkgs.stdenv.system}.claude-desktop
            kdenlive
            keybase
            keybase-gui
            localstack
            libreoffice
            lmstudio
            niv
            obs-studio
            obsidian
            ollama
            signal-desktop
            spotube
            synology-drive-client
            tmux
            tuba # fediverse client
            vlc
            vscode
            wget
            zoom-us

            # For hypervisors that support auto-resizing, this script forces it.
            # I've noticed not everyone listens to the udev events so this is a hack.
            (writeShellScriptBin "xrandr-auto" ''
              xrandr --output Virtual-1 --auto
            '')
          ];

          sessionVariables.NIXOS_OZONE_WL = "1";
        };

        #######################################################################
        # Hardware configuration
        hardware = {
          bluetooth.enable = true;
          bluetooth.powerOnBoot = true;

          nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true;
            powerManagement.finegrained = false;
            open = false;
            nvidiaSettings = true;
            # nvidiaPersistenced = true;
            # package = config.boot.kernelPackages.nvidiaPackages.stable;
          };
          graphics = {
            enable = true;
            enable32Bit = true;
          };
          logitech.wireless = {
            enable = true;
            enableGraphical = true;
          };
          hackrf.enable = true;
          flipperzero.enable = true;
        };

        #######################################################################
        # List services that you want to enable:
        services = {
          desktop.enable = true;
          # secureboot.enable = true;
          virt.enable = true;

          hardware.bolt.enable = true;
          printing.enable = true;
          colord.enable = true;
          xserver.videoDrivers = [ "nvidia" ];

          ollama = {
            enable = false;
            acceleration = "cuda";
          };

          # 
          # X/Wayland Config
          #- yubikey-agent.enable = true;
          displayManager.autoLogin.enable = true;
          displayManager.autoLogin.user = currentSystemUser;

          # Enable tailscale. We manually authenticate when we want with
          # "sudo tailscale up". If you don't use tailscale, you should comment
          # out or delete all of this.
          tailscale.enable = true;
          ##keybase.enable = true;
          openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = true;
              PermitRootLogin = "no";
            };
          };
        };
      };

      coda_hardware_configuration = { config, lib, pkgs, modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot = {
          initrd = {
            availableKernelModules = [
              "xhci_pci"
              "ahci"
              "nvme"
              "usb_storage"
              "usbhid"
              "sd_mod"
            ];
            kernelModules = [ ];
          };
          kernelModules = [ "kvm-intel" ];
          extraModulePackages = [ ];
        };

        fileSystems."/" =
          {
            device = "/dev/disk/by-uuid/b13dc6c5-97ae-400a-b273-d464dda9c3fb";
            fsType = "ext4";
          };

        fileSystems."/boot" =
          {
            device = "/dev/disk/by-uuid/F3F3-AEC4";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
          };

        swapDevices =
          [{ device = "/dev/disk/by-uuid/3076a975-0e7f-41ad-be10-7b0a0a79227a"; }];

        # swapDevices = [
        #  {
        #     device = "/var/lib/swapfile";
        #     size = 64 * 1024;
        #   }
        # ];
        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;
        # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
        # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

        # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
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

      nixosConfigurations."coda" = mkSystem "coda" {
        system = "x86_64-linux";
        user = "jrizzo";
      };

      # nixosConfigurations."coda" = inputs.nixpkgs.lib.nixosSystem {
      #   modules = [
      #     { nixpkgs.hostPlatform = "x86_64-linux"; }
      #     common_configuration
      #     common_linux_configuration
      #     coda_configuration
      #     coda_hardware_configuration
      #     inputs.home-manager.nixosModules.home-manager
      #     {
      #       home-manager.useGlobalPkgs = true;
      #       home-manager.useUserPackages = false;
      #       home-manager.users.jrizzo = user_configuration;
      #     }
      #     # Enable Virtualization Setup
      #     ({ pkgs, lib, config, ... }: {
      #       options.services.virt = {
      #         enable = lib.mkOption {
      #           type = lib.types.bool;
      #           default = false;
      #           example = true;
      #           description = "Enable my virtualisation stack";
      #         };
      #         # incus_over_lxd = lib.mkOption {
      #         #   type = lib.types.bool;
      #         #   default = false;
      #         #   example = true;
      #         #   description = "Enable incus over lxd";
      #         # };
      #         preseed = lib.mkOption {
      #           description = "Pre-seed to apply for incus setup";
      #           type = lib.types.attrs;
      #           default = { };
      #           example = {
      #             config = {
      #               "core.https_address" = ":8443";
      #             };
      #             networks = [
      #               {
      #                 config = {
      #                   "ipv4.address" = "10.10.10.1/24";
      #                   "ipv4.nat" = "true";
      #                 };
      #                 name = "incusbr0";
      #                 type = "bridge";
      #               }
      #             ];
      #             profiles = [
      #               {
      #                 devices = {
      #                   eth0 = {
      #                     name = "eth0";
      #                     network = "incusbr0";
      #                     type = "nic";
      #                   };
      #                   root = {
      #                     path = "/";
      #                     pool = "default";
      #                     size = "35GiB";
      #                     type = "disk";
      #                   };
      #                 };
      #                 name = "default";
      #               }
      #             ];
      #             storage_pools = [
      #               {
      #                 config = {
      #                   source = "/var/lib/incus/storage-pools/default";
      #                 };
      #                 driver = "dir";
      #                 name = "default";
      #               }
      #             ];
      #             cluster = {
      #               server_name = "coda";
      #               enabled = true;
      #             };
      #           };
      #         };
      #       };

      #       config = lib.mkIf config.services.virt.enable {
      #         users.users.jrizzo.extraGroups = [ "incus-admin" ];
      #         environment.systemPackages = with pkgs; [
      #           docker-compose
      #           bridge-utils
      #           spice
      #           spice-gtk
      #           spice-protocol
      #           virt-viewer
      #           virt-manager
      #           gnome-boxes
      #           kubernetes-helm
      #           podman-desktop
      #           kubectl
      #           kind
      #           qemu_full
      #           quickemu
      #           swtpm
      #           # swtpm-tpm2
      #           OVMFFull
      #           opentofu
      #           ovn
      #         ];

      #         virtualisation = {
      #           # vswitch.enable = true;
      #           libvirtd = {
      #             enable = true;
      #             allowedBridges = [ "virbr0" ];
      #             qemu = {
      #               package = pkgs.qemu_kvm;
      #               swtpm.enable = true;
      #               ovmf.enable = true;
      #               ovmf.packages = [ pkgs.OVMFFull.fd ];
      #             };
      #           };
      #           spiceUSBRedirection.enable = true;
      #           # containers.cdi.dynamic.nvidia.enable = true;
      #           # incus = lib.mkIf config.services.virt.incus_over_lxd {
      #           #   enable = true;
      #           #   package = pkgs.incus;
      #           #   ui.enable = true;
      #           #   inherit (config.services.virt) preseed;
      #           # };
      #           # lxd = lib.mkIf (! config.services.virt.incus_over_lxd) {
      #           lxd = {
      #             enable = true;
      #             # package = pkgs.lxd-lts;
      #             ui.enable = true;
      #             recommendedSysctlSettings = true;
      #             # inherit (config.services.virt) preseed;
      #           };
      #           # docker = {
      #           #   enable = true;
      #           #   enableOnBoot = true;
      #           # };
      #           podman = {
      #             enable = true;
      #             dockerSocket.enable = true;
      #             dockerCompat = true;
      #             # enableNvidia = true;
      #             autoPrune.enable = true;
      #           };
      #         };

      #         # This is to support nvidia cards on docker
      #         # enable this after you create an option for cuda/rocm
      #         # --device=nvidia.com/gpu=all
      #         hardware.nvidia-container-toolkit.enable = true;

      #         programs.virt-manager.enable = true;

      #         networking = {
      #           # Required for incus
      #           nftables.enable = true;

      #           # project: default
      #           # name: incusbr0
      #           # description: ''
      #           # type: bridge
      #           # config:
      #           #   bridge.driver: openvswitch
      #           #   dns.domain: technobable.com
      #           #   dns.search: tail577f.ts.net, technobable.com
      #           #   ipv4.address: 10.159.34.1/24
      #           #   ipv4.nat: 'true'
      #           #   ipv6.address: none

      #           # networking.vswitches = {
      #           #   "ovsbr0" = {
      #           #     interfaces = { }
      #           #   }
      #           # };

      #           # networking.firewall.enable = true;
      #           networkmanager.unmanaged = [
      #             "incusbr0"
      #             "virbr0"
      #             "docker0"
      #             "tailscale0"
      #           ];
      #           firewall.trustedInterfaces = [
      #             "incusbr0"
      #             "virbr0"
      #             "docker0"
      #           ];
      #           # "tailscale0"

      #           # networking.bridges.vmbr0.interfaces = [ "enp36s0" ];
      #           # networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
      #         };
      #       };
      #     })
      #     # Ease running dynamically linked executables
      #     ({ pkgs, lib, config, ... }: {
      #       options.services.nixld = {
      #         enable = lib.mkOption {
      #           type = lib.types.bool;
      #           default = false;
      #           example = true;
      #           description = "Enable nix-ld";
      #         };
      #       };

      #       config = lib.mkIf config.services.nixld.enable {
      #         nixpkgs.overlays = [
      #           inputs.nix-alien.overlays.default
      #         ];

      #         programs.nix-ld.enable = true;

      #         environment.systemPackages = with pkgs; [
      #           nix-alien
      #         ];
      #       };
      #     })
      #     # Setup secureboot
      #     inputs.lanzaboote.nixosModules.lanzaboote
      #     ({ pkgs, lib, config, ... }: {
      #       options.services.secureboot = {
      #         # enable = lib.mkEnableOption "secure boot";
      #         enable = lib.mkOption {
      #           type = lib.types.bool;
      #           default = false;
      #           example = true;
      #           description = "enable secure boot?";
      #         };
      #       };

      #       # https://nixos.wiki/wiki/Secure_Boot
      #       # Setup
      #       # * bootctl status should be using systemd, firmware=uefi, tpm2 support=yes
      #       # * sudo sbctl create-keys
      #       # * sudo sbctl verify
      #       # * sudo sbctl everything not windows, not bzimage.efi
      #       # * reboot
      #       # * sudo sbctl enroll-keys --microsoft
      #       # * reboot to enable UEFI+SecureBoot

      #       config = lib.mkIf config.services.secureboot.enable {
      #         environment.systemPackages = [
      #           pkgs.sbctl # for troubleshooting SecureBoot
      #         ];

      #         boot = {
      #           loader = {
      #             systemd-boot.enable = lib.mkForce false;
      #             efi.canTouchEfiVariables = true;
      #           };

      #           lanzaboote = {
      #             enable = true;
      #             pkiBundle = "/etc/secureboot";
      #           };
      #         };
      #       };
      #     })
      #     # Setup Desktop
      #     ({ pkgs, lib, config, ... }: {
      #       options.services.desktop = {
      #         enable = lib.mkOption {
      #           default = false;
      #           type = lib.types.bool;
      #           example = true;
      #           description = "Enable my custom desktop config";
      #         };
      #         desktopManager = lib.mkOption {
      #           default = "kde";
      #           type = lib.types.string;
      #           description = "The desktop manager you would like to use kde, gnome, etc.";
      #         };
      #         displayManager = lib.mkOption {
      #           default = "sddm";
      #           type = lib.types.string;
      #           example = "lightdm";
      #           description = "The display manager you would like to use sddm, lightdm, etc.";
      #         };
      #       };

      #       config = lib.mkIf config.services.desktop.enable {
      #         # if config.services.desktop.desktopManager == "kde"
      #         # then {

      #         environment.systemPackages = with pkgs; [
      #           kdePackages.konsole
      #           kdePackages.plasma-browser-integration
      #           # (lib.getBin qttools)
      #           ark
      #           elisa
      #           gwenview
      #           okular
      #           kate
      #           khelpcenter
      #           dolphin
      #           kdePackages.dolphin-plugins
      #           spectacle
      #           ffmpegthumbs
      #           # krdp
      #           kdePackages.yakuake
      #           # kdePackages.kwallet
      #           # kdePackages.kwallet-pam
      #           merkuro
      #         ];

      #         services = {
      #           displayManager.sddm.enable = true;
      #           displayManager.sddm.wayland.enable = true;
      #           desktopManager.plasma6.enable = true;
      #           desktopManager.plasma6.enableQt5Integration = true;

      #           xserver = {
      #             # Enable the X11 windowing system.
      #             enable = true;

      #             # Configure keymap in X11
      #             xkb.layout = "us";
      #             xkb.variant = "";
      #           };

      #           # Enable CUPS to print documents.
      #           printing.enable = true;
      #           pipewire = {
      #             enable = true;
      #             alsa.enable = true;
      #             alsa.support32Bit = true;
      #             pulse.enable = true;
      #             # If you want to use JACK applications, uncomment this
      #             #jack.enable = true;

      #             # use the example session manager (no others are packaged yet so this is enabled by default,
      #             # no need to redefine it in your config for now)
      #             #media-session.enable = true;
      #           };

      #           # Enable touchpad support (enabled default in most desktopManager).
      #           libinput.enable = true;
      #         };

      #         # Enable sound with pipewire.
      #         hardware.pulseaudio.enable = false;

      #         security.rtkit.enable = true;
      #       };
      #     })
      #   ];
      #   specialArgs = { inherit inputs; };
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

      # inherit (inputs.flake-schemas) schemas;

      #
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
