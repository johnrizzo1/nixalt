{ config, lib, ... }: {
  imports = [
    inputs.nix-bitcoin.nixosModules.default
  ];
  # Bitcoin
  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  # Enable some services.
  # See ../configuration.nix for all available features.
  services.bitcoind = {
    enable = true;
    # listen = true;
    # # address = "0.0.0.0";
    # tor.enforce = false;
    # tor.proxy = false;

    # dbCache = lib.mkForce 16384;
    # extraConfig = ''
    #   mempoolfullrbf=1
    # '';
  };
  services.mempool = {
    enable = true;
    frontend = {
      enable = true;
      address = "0.0.0.0";
      # port = 3081;
    };
  };
  services.rtl = {
    enable = true;
    # address = "0.0.0.0";
    nodes.clightning.enable = true;
  };
  services.clightning.enable = true;
  services.electrs.enable = true;
  services.liquidd.enable = true;
  services.btcpayserver = {
    enable = true;
  #   # address = "0.0.0.0";
  };
  nix-bitcoin.operator = {
    enable = true;
    name = "jrizzo";
  };
  nix-bitcoin.nodeinfo.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.bitcoind.port ];

  # services.nginx = {
    # enable = true;
    # recommendedProxySettings = true;
    # virtualHosts = {
      # localhost = {
        # locations."/".proxyPass = "http://127.0.0.1:60845";
      # };
    # };
  # };

  # services.cgminer = {
  #   enable = true;
  #   pools = [{
  #     password = "";

  #   user = "jrizzo";
  #     url = "http://localhost:8999";
  #   }];
  # };

  # If you use a custom nixpkgs version for evaluating your system
  # (instead of `nix-bitcoin.inputs.nixpkgs` like in this example),
  # consider setting `useVersionLockedPkgs = true` to use the exact pkgs
  # versions for nix-bitcoin services that are tested by nix-bitcoin.
  # The downsides are increased evaluation times and increased system
  # closure size.
  #
  # nix-bitcoin.useVersionLockedPkgs = true;
}