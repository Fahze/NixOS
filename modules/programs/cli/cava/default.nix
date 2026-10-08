{ host, lib, ... }:
let
  palette = import ../../../themes/palette.nix { inherit host lib; };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.cava = {
        enable = true;
        settings = {
          general = {
            framerate = 60;
            sensitivity = 100; # Default
            autosens = 1;
          };
          color = {
            gradient = 1;

            gradient_color_1 = "'${palette.hex.teal}'";
            gradient_color_2 = "'${palette.hex.sky}'";
            gradient_color_3 = "'${palette.hex.sapphire}'";
            gradient_color_4 = "'${palette.hex.blue}'";
            gradient_color_5 = "'${palette.hex.mauve}'";
            gradient_color_6 = "'${palette.hex.pink}'";
            gradient_color_7 = "'${palette.hex.maroon}'";
            gradient_color_8 = "'${palette.hex.red}'";
          };
        };
      };
    })
  ];
}
