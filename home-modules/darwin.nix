{pkgs, ...}: {
  home = {
    packages = [pkgs._1password];
    sessionPath = [
      "/opt/homebrew/bin"
    ];
  };

  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';
}
