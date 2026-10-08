{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # obsidian
    # ludusavi
    # godot
    proton-vpn
    gitkraken
    # github-desktop
    # pokego # Overlayed
  ];
}
