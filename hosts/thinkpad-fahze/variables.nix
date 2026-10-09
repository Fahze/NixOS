{
  username = "fahze";

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, noctalia, wayle
  waybarTheme = "stylish"; # stylish, minimal
  sddmTheme = "jake_the_dog"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  catppuccinFlavor = "macchiato"; # latte, frappe, macchiato, mocha
  catppuccinAccent = "mauve"; # rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
  defaultWallpaper = "evening-sky.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "kurzgesagt-galaxies.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm
  editor = "vscode"; # nixvim, zed, vscode, helix, doom-emacs, nvchad, neovim
  terminalEditor = "nvim"; # $EDITOR: used by git commit, sudoedit... (must run in a terminal)
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
  timezone = "Europe/Paris";
  locale = "en_US.UTF-8"; # system language (LANG)
  regionalLocale = "fr_FR.UTF-8"; # formats: date, currency, numbers, paper, units... (LC_*)
  clock24h = true;
  # Physical keyboard is English (UK). Layouts: gb (extd) first, fr second.
  # kbdLayout / kbdVariant are comma-separated lists, one entry per layout.
  kbdLayout = "gb,fr";
  kbdVariant = "extd,";
  kbdOptions = "grp:alt_shift_toggle"; # Alt+Shift switches layout
  consoleKeymap = "uk";
  capslockAsESC = false;
}
