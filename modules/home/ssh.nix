{ pkgs, lib, ... }: {
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "coda" = lib.hm.dag.entryBefore ["*"] {
        hostname = "coda";
        forwardAgent = true;
      };
      "irl" = lib.hm.dag.entryBefore ["coda"] {
        hostname = "irl";
        forwardAgent = true;
      };
    };

    # startAgent = true;
    controlMaster = "auto";
    forwardAgent = false;
    compression = true;

    extraConfig = 
      if pkgs.stdenv.isDarwin
      then "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
      else "";
  };
}