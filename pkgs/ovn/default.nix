{ pkgs, ... }:
let
  inherit (pkgs) stdenv fetchFromGitHub nix-update-script lib writeShellApplication;
  inherit (pkgs.lib) licenses maintainers platforms;
  inherit (pkgs.stdenv) mkDerivation;

in
mkDerivation rec {

  pname = "ovn";
  version = "24.09.1";

  src = pkgs.fetchFromGitHub {
    owner = "ovn-org";
    repo = "ovn";
    rev = "refs/tags/v${version}";
    hash = "sha256-Fz/YNEbMZ2mB4Fv1nKE3H3XrihehYP7j0N3clnTJ5x8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    autoreconfHook
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = with pkgs; [
    libbpf
    libcap_ng
    numactl
    openssl
    unbound
    xdp-tools
  ];

  # need to build the ovs submodule first
  preConfigure = ''
    pushd ovs
    ./boot.sh
    ./configure
    make -j $NIX_BUILD_CORES
    popd
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--runstatedir=/run"
    "--sysconfdir=/etc"
    "--with-logdir=/var/log/ovn"
  ];

  enableParallelBuilding = true;

  # disable tests due to networking issues and because individual tests can't be skipped easily
  doCheck = false;

  nativeCheckInputs = with pkgs; [
    makeWrapper
    gnused
    procps
  ];

  postInstall = ''
    cp $out/share/ovn/scripts/ovn-ctl $out/bin/ovn-ctl
  '';
  # wrapProgram $out/share/ovn/scripts/ovn-ctl --prefix PATH : $out/share/ovn/scripts

  # https://docs.ovn.org/en/latest/topics/testing.html
  preCheck = ''
    export TESTSUITEFLAGS="-j$NIX_BUILD_CORES"
    # allow rechecks to retry flaky tests
    export RECHECK=yes

    # hack to stop tests from trying to read /etc/resolv.conf
    export OVS_RESOLV_CONF="$PWD/resolv.conf"
    touch $OVS_RESOLV_CONF
  '';

  passthru.updateScript = nix-update-script { };

  # writeShellApplication = {
  #   name = "ovn-ctl";
  #   text = ''
  #     $out/share/ovn/scripts/ovn-ctl
  #   '';
  # };

  meta = {
    description = "Open Virtual Network";
    longDescription = ''
      OVN (Open Virtual Network) is a series of daemons that translates virtual network configuration into OpenFlow, and installs them into Open vSwitch.
    '';
    homepage = "https://github.com/ovn-org/ovn";
    changelog = "https://github.com/ovn-org/ovn/blob/${src.rev}/NEWS";
    license = licenses.asl20;
    maintainers = with maintainers; [ adamcstephens ];
    platforms = platforms.linux;
  };
}
