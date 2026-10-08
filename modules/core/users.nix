{
  config,
  pkgs,
  inputs,
  host,
  ...
}:
let
  vars = import ../../hosts/${host}/variables.nix;
  inherit (vars)
    username
    editor
    terminal
    browser
    shell
    ;
  # $EDITOR must be a terminal editor. Hosts without terminalEditor keep the previous rule.
  terminalEditor =
    vars.terminalEditor or (
      if (editor == "nixvim" || editor == "neovim" || editor == "nvchad") then
        "nvim"
      else if editor == "vscode" then
        "code"
      else
        "nano"
    );
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./secrets.nix
  ];
  programs.dconf.enable = true; # Enable dconf for home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    overwriteBackup = true;
    backupFileExtension = "backup";
    users.${username} = {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      xdg.enable = true;

      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "26.05"; # Do not change!
        sessionVariables = {
          EDITOR = terminalEditor;
          BROWSER = "${browser}";
          TERMINAL = "${terminal}";
        };
      };
    };
  };
  users = {
    # Declarative accounts: passwords always come from the configuration (sops), so a
    # changed password or the locked root account survive every rebuild.
    mutableUsers = false;
    # root cannot log in with a password (console, su, ssh). Use sudo (group wheel).
    users.root.hashedPassword = "!";
    users.${username} = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."user-password".path;
      extraGroups = [
        "wheel" # sudo access
        "input"
        "networkmanager"
        "video"
        "audio"
        "docker" # NOTE: docker group is equivalent to root
      ];
      shell = pkgs.${shell};
      ignoreShellProgramCheck = true;
    };
  };
  nix.settings.allowed-users = [ "${username}" ];
}
