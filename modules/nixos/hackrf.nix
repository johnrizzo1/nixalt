{ pkgs, lib, config, ... }: {
  options.services.hackrf = {
    enable = lib.mkEnableOption "setup tools for hackrf";
  };

  config = lib.mkIf config.services.hackrf.enable {
    environment.systemPackages = with pkgs; [
      urh
      hackrf
      gqrx
      inspectrum
    ];
  };
}