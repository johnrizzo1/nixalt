{ pkgs
, lib
, config
, inputs
, currentSystemUser
, ...
}: {
  options.services.virt-client = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable my virtualisation stack";
    };
  };

  config = lib.mkIf config.services.virt-client.enable {
    users.users.${currentSystemUser}.extraGroups = [
      "docker"
      "gns3"
      "incus-admin"
      "libvirtd"
      "lxd"
    ];

    environment.systemPackages = with pkgs; [
      # swtpm-tpm2
      bridge-utils
      docker-compose
      gnome-boxes
      incus
      kind
      kubectl
      kubernetes-helm
      opentofu
      OVMFFull
      ovn
      podman
      podman-desktop
      podman-tui
      qemu_full
      quickemu
      spice
      spice-gtk
      spice-protocol
      swtpm
      terraform-providers.incus
      terragrunt
      virt-manager
      virt-viewer
    ];
  };
}
