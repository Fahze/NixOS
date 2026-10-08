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

    libreoffice
    hunspell
    hunspellDicts.fr-any
    hunspellDicts.en_GB-ise
    prismlauncher # Minecraft
    claude-code

    #Temporaire Ynov Netbird (VPN)
    netbird-ui
    netbird
  ];
}
