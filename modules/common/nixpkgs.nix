# { inputs, lib, ... }: {
{ pkgs, lib, ... }: {
  nixpkgs = {
    config = {
      # allowUnfree = true;
      hostPlatform = pkgs.stdenv.system;
      cudaSupport = true;
      android_sdk.accept_license = true;
      allowUnfreePredicate =
        pkg: builtins.elem (lib.getName pkg) [
          "_1password-cli"
          "1password"
          "1password-cli"
          "1password-gui"
          "cudnn"
          "cuda_cccl"
          "cuda_cudart"
          "cuda_cuobjdump"
          "cuda_cupti"
          "cuda_cuxxfilt"
          "cuda_gdb"
          "cuda_nvcc"
          "cuda_nvdisasm"
          "cuda_nvml_dev"
          "cuda_nvprune"
          "cuda_nvrtc"
          "cuda_nvtx"
          "cuda_profiler_api"
          "cuda_sanitizer_api"
          "cuda-merged"
          "discord"
          "gitkraken"
          "libcublas"
          "libcufft"
          "libcurand"
          "libcusolver"
          "libcusparse"
          "libnpp"
          "libnvjitlink"
          "nvidia-x11"
          "nvidia-settings"
          "obsidian"
          "synology-drive-client"
        ];
    };
  };
}
