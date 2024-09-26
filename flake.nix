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
    nix.url = "github:nixos/nix/2.24.7";

    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Build a custom WSL installer
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # I think technically you're not supposed to override the nixpkgs
    # used by neovim but recently I had failures if I didn't pin to my
    # own. We can always try to remove that anytime.
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";

      # Only need unstable until the lpeg fix hits mainline, probably
      # not very long... can safely switch back for 23.11.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Other packages
    jujutsu.url = "github:martinvonz/jj";
    zig.url = "github:mitchellh/zig-overlay";
    
    # SecureBoot
    lanzaboote = {
      # url = "github:nix-community/lanzaboote/v0.4.1";
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Virtualisation
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # VSCodium
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";

    # Non-flakes
    nvim-conform.url = "github:stevearc/conform.nvim/v7.1.0";
    nvim-conform.flake = false;
    nvim-dressing.url = "github:stevearc/dressing.nvim";
    nvim-dressing.flake = false;
    nvim-gitsigns.url = "github:lewis6991/gitsigns.nvim/v0.9.0";
    nvim-gitsigns.flake = false;
    nvim-lspconfig.url = "github:neovim/nvim-lspconfig";
    nvim-lspconfig.flake = false;
    nvim-lualine.url ="github:nvim-lualine/lualine.nvim";
    nvim-lualine.flake = false;
    nvim-nui.url = "github:MunifTanjim/nui.nvim";
    nvim-nui.flake = false;
    nvim-plenary.url = "github:nvim-lua/plenary.nvim";
    nvim-plenary.flake = false;
    nvim-telescope.url = "github:nvim-telescope/telescope.nvim/0.1.8";
    nvim-telescope.flake = false;
    nvim-treesitter.url = "github:nvim-treesitter/nvim-treesitter/v0.9.2";
    nvim-treesitter.flake = false;
    nvim-web-devicons.url = "github:nvim-tree/nvim-web-devicons";
    nvim-web-devicons.flake = false;
    vim-copilot.url = "github:github/copilot.vim/v1.39.0";
    vim-copilot.flake = false;
    vim-misc.url = "github:mitchellh/vim-misc";
    vim-misc.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: let
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = import ./overlays { inherit inputs; };

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
    nixosConfigurations = {
      coda = mkSystem "coda" rec {
        system = "x86_64-linux";
        user   = "jrizzo";
      };
      irl = mkSystem "irl" rec {
        system = "x86_64-linux";
        user   = "jrizzo";
        isHypervisor = true;
      };
    };
  };
}
