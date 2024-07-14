{pkgs, ...}:
pkgs.writeShellApplication {
  name = "build-switch";
  runtimeInputs = with pkgs; [
    git
    deadnix
    nixfmt-rfc-style
    statix
  ];
  text = ''
    set -x
    nixfmt .
    # git add . && git stage . && sudo nixos-rebuild switch --flake .
    # git add . && git stage . && home-manager switch --flake .
  '';
}
