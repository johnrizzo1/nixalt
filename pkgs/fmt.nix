{pkgs, ...}:
pkgs.writeShellApplication {
  name = "fmt";
  runtimeInputs = with pkgs; [
    deadnix
    nixfmt-rfc-style
    statix
  ];
  text = ''
    set -x
    deadnix --edit
    statix fix
    nixfmt .
  '';
}
