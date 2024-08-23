{pkg, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = 
      pkg: builtins.elem (lib.getName pkg) [
        "1password-gui"
        "_1password"
        "_1password-cli"
      ];
  };

  homebrew = {
    masApps = {
      "1Password for Safari" = 1569813296;
    };
    casks = [
      "1password"
    ];
  };
}