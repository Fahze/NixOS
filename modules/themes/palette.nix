# Central Catppuccin palette.
#
# The flavor and accent come from hosts/<host>/variables.nix
# (catppuccinFlavor / catppuccinAccent). Hosts that do not define them
# fall back to mocha / mauve.
#
# Usage in a module:
#   palette = import ../../themes/palette.nix { inherit host lib; };
#   palette.hex.base      -> "#24273a"
#   palette.colors.base   -> "24273a"
#   palette.flavor        -> "macchiato"
#   palette.flavorCap     -> "Macchiato"
#   palette.accent        -> "mauve"
#   palette.accentHex     -> "#c6a0f6"
#   palette.rgb.base      -> "rgb(36, 39, 58)"
#   palette.tuple.base    -> "36, 39, 58"
{ host, lib }:
let
  vars = import ../../hosts/${host}/variables.nix;

  flavor = vars.catppuccinFlavor or "mocha";
  accent = vars.catppuccinAccent or "mauve";

  flavors = {
    latte = {
      rosewater = "dc8a78";
      flamingo = "dd7878";
      pink = "ea76cb";
      mauve = "8839ef";
      red = "d20f39";
      maroon = "e64553";
      peach = "fe640b";
      yellow = "df8e1d";
      green = "40a02b";
      teal = "179299";
      sky = "04a5e5";
      sapphire = "209fb5";
      blue = "1e66f5";
      lavender = "7287fd";
      text = "4c4f69";
      subtext1 = "5c5f77";
      subtext0 = "6c6f85";
      overlay2 = "7c7f93";
      overlay1 = "8c8fa1";
      overlay0 = "9ca0b0";
      surface2 = "acb0be";
      surface1 = "bcc0cc";
      surface0 = "ccd0da";
      base = "eff1f5";
      mantle = "e6e9ef";
      crust = "dce0e8";
    };
    frappe = {
      rosewater = "f2d5cf";
      flamingo = "eebebe";
      pink = "f4b8e4";
      mauve = "ca9ee6";
      red = "e78284";
      maroon = "ea999c";
      peach = "ef9f76";
      yellow = "e5c890";
      green = "a6d189";
      teal = "81c8be";
      sky = "99d1db";
      sapphire = "85c1dc";
      blue = "8caaee";
      lavender = "babbf1";
      text = "c6d0f5";
      subtext1 = "b5bfe2";
      subtext0 = "a5adce";
      overlay2 = "949cbb";
      overlay1 = "838ba7";
      overlay0 = "737994";
      surface2 = "626880";
      surface1 = "51576d";
      surface0 = "414559";
      base = "303446";
      mantle = "292c3c";
      crust = "232634";
    };
    macchiato = {
      rosewater = "f4dbd6";
      flamingo = "f0c6c6";
      pink = "f5bde6";
      mauve = "c6a0f6";
      red = "ed8796";
      maroon = "ee99a0";
      peach = "f5a97f";
      yellow = "eed49f";
      green = "a6da95";
      teal = "8bd5ca";
      sky = "91d7e3";
      sapphire = "7dc4e4";
      blue = "8aadf4";
      lavender = "b7bdf8";
      text = "cad3f5";
      subtext1 = "b8c0e0";
      subtext0 = "a5adcb";
      overlay2 = "939ab7";
      overlay1 = "8087a2";
      overlay0 = "6e738d";
      surface2 = "5b6078";
      surface1 = "494d64";
      surface0 = "363a4f";
      base = "24273a";
      mantle = "1e2030";
      crust = "181926";
    };
    mocha = {
      rosewater = "f5e0dc";
      flamingo = "f2cdcd";
      pink = "f5c2e7";
      mauve = "cba6f7";
      red = "f38ba8";
      maroon = "eba0ac";
      peach = "fab387";
      yellow = "f9e2af";
      green = "a6e3a1";
      teal = "94e2d5";
      sky = "89dceb";
      sapphire = "74c7ec";
      blue = "89b4fa";
      lavender = "b4befe";
      text = "cdd6f4";
      subtext1 = "bac2de";
      subtext0 = "a6adc8";
      overlay2 = "9399b2";
      overlay1 = "7f849c";
      overlay0 = "6c7086";
      surface2 = "585b70";
      surface1 = "45475a";
      surface0 = "313244";
      base = "1e1e2e";
      mantle = "181825";
      crust = "11111b";
    };
  };

  colors =
    flavors.${flavor}
      or (throw "catppuccinFlavor must be one of: ${lib.concatStringsSep ", " (builtins.attrNames flavors)} (got \"${flavor}\")");

  # "c6a0f6" -> "198, 160, 246"
  hexToTuple =
    c:
    let
      channel = i: toString (lib.fromHexString (builtins.substring i 2 c));
    in
    "${channel 0}, ${channel 2}, ${channel 4}";
  hexToRgb = c: "rgb(${hexToTuple c})";

  capitalize = s: lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (-1) s;
in
{
  inherit flavor accent colors;
  flavorCap = capitalize flavor;
  accentCap = capitalize accent;

  # Same colors with a leading "#".
  hex = lib.mapAttrs (_: c: "#${c}") colors;

  # Same colors as "rgb(r, g, b)" (Hyprland / hyprlock syntax).
  rgb = lib.mapAttrs (_: hexToRgb) colors;
  # Bare "r, g, b" tuples, for CSS rgba(r, g, b, alpha).
  tuple = lib.mapAttrs (_: hexToTuple) colors;
  accentRgb = hexToRgb colors.${accent};

  accentColor =
    colors.${accent}
      or (throw "catppuccinAccent must be a Catppuccin accent color name (got \"${accent}\")");
  accentHex = "#${colors.${accent}}";

  # Light flavors need a light GTK/Qt color scheme, dark ones a dark scheme.
  isDark = flavor != "latte";
}
