{
  pkgs,
  waybarTheme,
  ...
}:
pkgs.writeShellScriptBin "waybar-switch" ''
  set -euo pipefail

  CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
  STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
  THEMES_DIR="$CONFIG_HOME/waybar/themes"
  STATE_FILE="$STATE_HOME/waybar-theme"
  DEFAULT_THEME="${waybarTheme}"

  theme="''${1:-}"

  if [[ -z "$theme" && -r "$STATE_FILE" ]]; then
    theme=$(${pkgs.coreutils}/bin/cat "$STATE_FILE")
  fi

  if [[ -z "$theme" || ! -d "$THEMES_DIR/$theme" ]]; then
    theme="$DEFAULT_THEME"
  fi

  ${pkgs.coreutils}/bin/mkdir -p "$STATE_HOME"
  echo "$theme" > "$STATE_FILE"

  # -x: only the actual waybar binary, not this script.
  ${pkgs.procps}/bin/pkill -x waybar 2>/dev/null || true

  exec ${pkgs.waybar}/bin/waybar -c "$THEMES_DIR/$theme/config" -s "$THEMES_DIR/$theme/style.css"
''
