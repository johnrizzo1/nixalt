{ pkgs
, inputs
, ...
}:
{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" "/share/zsh" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  environment.systemPackages = with pkgs; [
    distrobuilder
    lshw
  ];

  users = {
    mutableUsers = false;
    users.jrizzo = {
      isNormalUser = true;
      home = "/home/jrizzo";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "kubernetes"
        "incus-admin"
      ];
      shell = pkgs.zsh;
      hashedPassword = "$y$j9T$b5Q1pCL/pua.UUsOV3TKi/$8nkwFkKrHjUu5cr8b4TQnFgSpcYbVuFW63w88UppUF1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRWDuga9nU4wD0HFVQ1Xe66qSGZExVqWfhXWD7fk9E2"
      ];
    };
  };

  programs = {
    mosh.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
    };
    tmux = {
      enable = true;
    };
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "jrizzo" ];
    };
    # obs-studio = {
    #   enable = true;
    #   plugins = with pkgs.obs-studio-plugins; [
    #     input-overlay
    #     obs-backgroundremoval
    #     obs-composite-blur
    #     obs-freeze-filter
    #     obs-mute-filter
    #     obs-vkcapture
    #     wlrobs
    #   ];
    # };
  };

}
