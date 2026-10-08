{
  username = "fahze";

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, noctalia, wayle
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "jake_the_dog"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "evening-sky.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "kurzgesagt-galaxies.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm
  editor = "vscode"; # nixvim, zed, vscode, helix, doom-emacs, nvchad, neovim
  browser = "zen-beta"; # zen-beta, firefox, floorp
  fileManager = "thunar"; # yazi, lf, thunar
  shell = "zsh"; # bash, zsh
  games = true; # Enable/Disable gaming module

  # Hardware (Lenovo ThinkPad P14s Gen 5 AMD)
  hostname = "thinkpad-fahze";
  videoDriver = "amdgpu"; # nvidia, amdgpu, intel
  bluetoothSupport = true; # Whether your motherboard supports bluetooth
  batterySupport = true; # Whether device has a battery (laptop)

  # Localization
  # NOTE: locale and keyboard values are still the upstream ones on purpose:
  # they are reworked in phase 2 (locale/keyboard) to isolate evaluation errors.
  timezone = "Europe/Paris";
  locale = "en_GB.UTF-8";
  clock24h = true;
  kbdLayout = "gb";
  kbdVariant = "extd";
  consoleKeymap = "uk";
  capslockAsESC = false;
}
