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

  # nixpkgs' waybar is a wrapper that execs into a binary named
  # ".waybar-wrapped" -- that's what ends up in /proc/<pid>/comm, so
  # `pkill -x waybar` (comm match) never finds it and old bars pile up.
  # Match on the full command line instead (always has our -c flag),
  # plus a plain `-x waybar` for a bare/unwrapped waybar with no args.
  waybar_pids() {
    (
      ${pkgs.procps}/bin/pgrep -f "/bin/waybar -c " 2>/dev/null
      ${pkgs.procps}/bin/pgrep -x waybar 2>/dev/null
      true
    ) | ${pkgs.coreutils}/bin/sort -u
  }

  pids=$(waybar_pids)
  if [ -n "$pids" ]; then
    echo "$pids" | ${pkgs.findutils}/bin/xargs -r kill -TERM
    for _ in $(${pkgs.coreutils}/bin/seq 1 20); do
      [ -z "$(waybar_pids)" ] && break
      ${pkgs.coreutils}/bin/sleep 0.05
    done
    pids=$(waybar_pids)
    [ -n "$pids" ] && echo "$pids" | ${pkgs.findutils}/bin/xargs -r kill -KILL
  fi

  exec ${pkgs.waybar}/bin/waybar -c "$THEMES_DIR/$theme/config" -s "$THEMES_DIR/$theme/style.css"
''
