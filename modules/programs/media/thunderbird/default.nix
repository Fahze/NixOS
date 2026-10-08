{
  inputs,
  host,
  lib,
  ...
}:
let
  palette = import ../../../themes/palette.nix { inherit host lib; };
  extensions = [
    # Theme
    "${inputs.thunderbird-catppuccin}/themes/${palette.flavor}/${palette.flavor}-${palette.accent}.xpi"
    # "https://addons.thunderbird.net/thunderbird/downloads/latest/dracula-theme-for-thunderbird/addon-987962-latest.xpi"
    # "https://addons.thunderbird.net/thunderbird/downloads/latest/luminous-matter/addon-988120-latest.xpi"
    # "https://addons.thunderbird.net/thunderbird/downloads/latest/dark-black-theme/addon-988343-latest.xpi"

    # "https://addons.thunderbird.net/thunderbird/downloads/latest/grammar-and-spell-checker/addon-988138-latest.xpi"
    # "https://addons.thunderbird.net/thunderbird/downloads/latest/external-editor-revived/addon-988342-latest.xpi"
  ];
in
{
  programs.thunderbird = {
    enable = true;
    policies = {
      Extensions.Install = extensions;
    };
    preferences = {
      "privacy.donottrackheader.enabled" = true;
    };
  };
}
