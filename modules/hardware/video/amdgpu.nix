{ pkgs, ... }:

{
  services.xserver = {
    # enable = true;  # Already enabled in display manager
    videoDrivers = [ "amdgpu" ];
  };
  # environment.systemPackages = with pkgs; [ rocmPackages.amdsmi ]; # disabled: heavy, no GPU compute use
  hardware.amdgpu = {
    opencl.enable = false; # disabled: ROCm OpenCL is heavy and unused on this iGPU
  };
}
