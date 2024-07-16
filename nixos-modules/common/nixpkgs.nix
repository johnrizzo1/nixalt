{...}: {
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };
}
