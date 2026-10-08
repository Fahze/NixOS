{ lib, ... }:
{
  # NetBird client (Ynov VPN). The module starts the "netbird" daemon (socket:
  # /var/run/netbird/sock) and installs the `netbird` and `netbird-ui` wrappers that talk
  # to it, so the plain netbird / netbird-ui packages must not be installed next to it.
  # First connection: `sudo netbird up`, then log in through the browser.
  services.netbird = {
    enable = true;
    # Network routes and exit nodes: loose reverse path filtering in the firewall.
    useRoutingFeatures = "client";
  };

  # Strict rp_filter (set in network.nix) drops the replies of routed networks reached
  # through wt0.
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = lib.mkForce 2;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 2;
  };
}
