{ pkgs, defaultWallpaper, ... }:
let
  awww = "${pkgs.awww}/bin/awww";
  awww-daemon = "${pkgs.awww}/bin/awww-daemon";
  wallpaperDir = "${../../../themes/wallpapers}";
in
pkgs.writeShellScriptBin "wallpaper" ''

  if ! pgrep awww-daemon &> /dev/null; then
    ${awww-daemon} &
    sleep 0.5
  fi

  # Pick a random wallpaper every session instead of restoring the last one.
  CHOICE=$(${pkgs.findutils}/bin/find "${wallpaperDir}" -type f \
    \( -iname '*.webp' -o -iname '*.jxl' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) \
    | ${pkgs.coreutils}/bin/shuf -n 1)
  [ -z "$CHOICE" ] && CHOICE="${../../../themes/wallpapers/${defaultWallpaper}}"

  ${awww} img "$CHOICE" --transition-step 90 --transition-duration 1 --transition-fps 60 --transition-type wipe
''
