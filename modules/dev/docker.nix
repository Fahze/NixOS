{ pkgs, ... }:
{
  # Rootful Docker. Members of the "docker" group are effectively root.
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      # Keep container logs from growing without bound
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
    # Weekly: dangling images, stopped containers, unused networks (volumes are kept)
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker # TUI for containers
    dive # explore image layers
  ];
}
