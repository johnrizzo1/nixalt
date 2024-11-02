# { inputs, lib, ... }: {
{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    hostPlatform = pkgs.stdenv.system;
    # allowUnfreePredicate =
    #   pkg: builtins.elem (lib.getName pkg) [
    #     "1password-gui"
    #     "_1password"
    #     "_1password-cli"
    #   ];
  };
}
