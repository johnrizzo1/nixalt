{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = [pkgs.git];
  enterShell = ''
    git --version
  '';
  enterTest = ''
    echo "Running tests"
    git --version | grep "2.42.0"
  '';
  languages.nix.enable = true;
  difftastic.enable = true;
  # pre-commit.hooks.shellcheck.enable = true;
  pre-commit.hooks = {
    check-yaml.enable = true;
    check-json.enable = true;
    deadnix.enable = true;
    nixpkgs-fmt.enable = true;
  };
  # See full reference at https://devenv.sh/reference/options/
}
