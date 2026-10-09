{
  host,
  lib,
  pkgs,
  ...
}:
let
  palette = import ../../../../themes/palette.nix { inherit host lib; };
  jsonFormat = pkgs.formats.json { };

  # New themes (8.3) need to be added here too.
  themeNames = [
    "minimal"
    "stylish"
  ];

  mkThemeFiles =
    homeDirectory: name:
    let
      theme = import ./${name}.nix {
        inherit
          host
          lib
          pkgs
          homeDirectory
          ;
      };
    in
    {
      "waybar/themes/${name}/config".source =
        jsonFormat.generate "waybar-${name}-config.json" theme.settings;
      "waybar/themes/${name}/style.css" =
        if builtins.isString theme.style then { text = theme.style; } else { source = theme.style; };
    };
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        programs.waybar.enable = true;

        xdg.configFile =
          # Colors shared by every theme's style.css via `@import`.
          # Regenerated from palette.nix on every build.
          {
            "waybar/palette.css".text = ''
              @define-color rosewater		${palette.hex.rosewater};
              @define-color flamingo		${palette.hex.flamingo};
              @define-color pink			${palette.hex.pink};
              @define-color mauve			${palette.hex.mauve};
              @define-color red			${palette.hex.red};
              @define-color maroon		${palette.hex.maroon};
              @define-color peach			${palette.hex.peach};
              @define-color yellow		${palette.hex.yellow};
              @define-color green			${palette.hex.green};
              @define-color teal			${palette.hex.teal};
              @define-color sky			${palette.hex.sky};
              @define-color sapphire		${palette.hex.sapphire};
              @define-color blue			${palette.hex.blue};
              @define-color lavender		${palette.hex.lavender};
              @define-color text			${palette.hex.text};
              @define-color subtext1		${palette.hex.subtext1};
              @define-color subtext0		${palette.hex.subtext0};
              @define-color overlay2		${palette.hex.overlay2};
              @define-color overlay1		${palette.hex.overlay1};
              @define-color overlay0		${palette.hex.overlay0};
              @define-color surface2		${palette.hex.surface2};
              @define-color surface1		${palette.hex.surface1};
              @define-color surface0		${palette.hex.surface0};
              @define-color base			${palette.hex.base};
              @define-color mantle		${palette.hex.mantle};
              @define-color crust			${palette.hex.crust};

              @define-color accent		${palette.accentHex};
              @define-color main-br		@subtext0;
              @define-color main-bg		@crust;
              @define-color main-fg		@text;
              @define-color hover-bg		@base;
              @define-color hover-fg		alpha(@main-fg, 0.75);
              @define-color outline		shade(@main-bg, 0.5);

              @define-color workspaces	@mantle;
              @define-color temperature	@mantle;
              @define-color memory		@base;
              @define-color cpu			@surface0;
              @define-color time			@surface0;
              @define-color date			@base;
              @define-color tray			@mantle;
              @define-color volume		@mantle;
              @define-color backlight		@base;
              @define-color battery		@surface0;

              @define-color warning		@yellow;
              @define-color critical		@red;
              @define-color charging		@green;
            '';
          }
          // lib.foldl' (acc: name: acc // mkThemeFiles config.home.homeDirectory name) { } themeNames;
      }
    )
  ];
}
