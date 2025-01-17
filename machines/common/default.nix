{ pkgs, inputs, config, lib, ... }: {
  imports = [ ./nix.nix ./nixpkgs.nix ];
  users.users = {
    root =
      if pkgs.stdenv.isLinux then {
        isSystemUser = true;
        hashedPassword = "$y$j9T$huQi//1srOgV4dSHFgVrh/$mZbJwRhMuqOTAPWssVxlL1d9YCjDxugoQejlN8I4K70";
      } else { };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    shells = [ pkgs.zsh ];
    pathsToLink = [ "/share/zsh" ];
    # systemPackages = with pkgs; [ ];
  };

  time.timeZone = "America/New_York";

  fonts = {
    packages = with pkgs; [
      cascadia-code
      nerd-fonts.caskaydia-mono
    ];
  };
}
