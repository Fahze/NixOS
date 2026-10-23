{ pkgs, defaultWallpaper, ... }:
let
  awww = "${pkgs.awww}/bin/awww";
  wallpaperDir = "${../../../themes/wallpapers}";
in
pkgs.writeShellScriptBin "wallpaper" ''

  # The daemon is supervised by the awww.service user unit (services.awww).
  # Wait for it (about 10s at most: a failing `awww query` takes ~0.5s itself)
  # instead of starting a second one: that one aborts on the busy socket and
  # systemd would respawn the unit every 10s.
  for _ in {1..14}; do
    ${awww} query &> /dev/null && break
    ${pkgs.coreutils}/bin/sleep 0.2
  done

  # Pick a random wallpaper every session instead of restoring the last one.
  CHOICE=$(${pkgs.findutils}/bin/find "${wallpaperDir}" -type f \
    \( -iname '*.webp' -o -iname '*.jxl' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) \
    | ${pkgs.coreutils}/bin/shuf -n 1)
  [ -z "$CHOICE" ] && CHOICE="${../../../themes/wallpapers/${defaultWallpaper}}"

  ${awww} img "$CHOICE" --transition-step 90 --transition-duration 1 --transition-fps 60 --transition-type wipe
''
