{
  host,
  lib,
  pkgs,
  ...
}:
let
  palette = import ../../../themes/palette.nix { inherit host lib; };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.btop = {
        enable = true;
        package = pkgs.btop.override {
          rocmSupport = true;
          cudaSupport = true;
        };
        settings = {
          color_theme = "catppuccin-${palette.flavor}";
          show_gpu_info = "on";
          cpu_sensor = "auto";
          vim_keys = true;
          rounded_corners = true;
          proc_tree = false;
          show_uptime = true;
          show_coretemp = true;
          show_disks = true;
          only_physical = true;
          io_mode = true;
          io_graph_combined = false;
        };
        themes."catppuccin-${palette.flavor}" = ''
          # Main background, empty for terminal default, need to be empty if you want transparent background
          theme[main_bg]="${palette.hex.base}"

          # Main text color
          theme[main_fg]="${palette.hex.text}"

          # Title color for boxes
          theme[title]="${palette.hex.text}"

          # Highlight color for keyboard shortcuts
          theme[hi_fg]="${palette.hex.blue}"

          # Background color of selected item in processes box
          theme[selected_bg]="${palette.hex.surface1}"

          # Foreground color of selected item in processes box
          theme[selected_fg]="${palette.hex.blue}"

          # Color of inactive/disabled text
          theme[inactive_fg]="${palette.hex.overlay1}"

          # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
          theme[graph_text]="${palette.hex.rosewater}"

          # Background color of the percentage meters
          theme[meter_bg]="${palette.hex.surface1}"

          # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
          theme[proc_misc]="${palette.hex.rosewater}"

          # CPU, Memory, Network, Proc box outline colors
          theme[cpu_box]="${palette.hex.mauve}" #Mauve
          theme[mem_box]="${palette.hex.green}" #Green
          theme[net_box]="${palette.hex.maroon}" #Maroon
          theme[proc_box]="${palette.hex.blue}" #Blue

          # Box divider line and small boxes line color
          theme[div_line]="${palette.hex.overlay0}"

          # Temperature graph color (Green -> Yellow -> Red)
          theme[temp_start]="${palette.hex.green}"
          theme[temp_mid]="${palette.hex.yellow}"
          theme[temp_end]="${palette.hex.red}"

          # CPU graph colors (Teal -> Lavender)
          theme[cpu_start]="${palette.hex.teal}"
          theme[cpu_mid]="${palette.hex.sapphire}"
          theme[cpu_end]="${palette.hex.lavender}"

          # Mem/Disk free meter (Mauve -> Lavender -> Blue)
          theme[free_start]="${palette.hex.mauve}"
          theme[free_mid]="${palette.hex.lavender}"
          theme[free_end]="${palette.hex.blue}"

          # Mem/Disk cached meter (Sapphire -> Lavender)
          theme[cached_start]="${palette.hex.sapphire}"
          theme[cached_mid]="${palette.hex.blue}"
          theme[cached_end]="${palette.hex.lavender}"

          # Mem/Disk available meter (Peach -> Red)
          theme[available_start]="${palette.hex.peach}"
          theme[available_mid]="${palette.hex.maroon}"
          theme[available_end]="${palette.hex.red}"

          # Mem/Disk used meter (Green -> Sky)
          theme[used_start]="${palette.hex.green}"
          theme[used_mid]="${palette.hex.teal}"
          theme[used_end]="${palette.hex.sky}"

          # Download graph colors (Peach -> Red)
          theme[download_start]="${palette.hex.peach}"
          theme[download_mid]="${palette.hex.maroon}"
          theme[download_end]="${palette.hex.red}"

          # Upload graph colors (Green -> Sky)
          theme[upload_start]="${palette.hex.green}"
          theme[upload_mid]="${palette.hex.teal}"
          theme[upload_end]="${palette.hex.sky}"

          # Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
          theme[process_start]="${palette.hex.sapphire}"
          theme[process_mid]="${palette.hex.sky}"
          theme[process_end]="${palette.hex.mauve}"
        '';
      };
    })
  ];
}
