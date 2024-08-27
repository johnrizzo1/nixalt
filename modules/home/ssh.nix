{ lib, ... }: {
  programs.ssh = {
    enable = true;
    # matchBlocks = {
    #   "irl" = lib.hm.dag.entryBefore ["*"] { 
    #     hostname = "irl";
    #     forwardAgent = true;  
    #     extraOptions = [
    #       "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
    #     ];
    #   };
    # };

    controlMaster = "auto";
    forwardAgent = false;    
    compression = true;
    # extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
    # startAgent = true;
    # knownHosts = {
      # "irl".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0ytDnaAabhxd1kVI7YCxG9A3VgW0hfwDGK20M/0MmW";
    # };    
  };
}