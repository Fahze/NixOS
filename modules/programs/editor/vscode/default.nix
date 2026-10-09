{
  lib,
  pkgs,
  self,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" ];
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        programs.vscode = {
          enable = true;
          mutableExtensionsDir = true;
          # package = pkgs.vscodium;
          package = pkgs.vscode;
          profiles.default = {
            extensions = with pkgs.vscode-extensions; [
              arrterian.nix-env-selector
              jnoortheen.nix-ide
              eamodio.gitlens
              github.vscode-github-actions
              yzhang.markdown-all-in-one
              catppuccin.catppuccin-vsc
              catppuccin.catppuccin-vsc-icons

              mkhl.direnv

              vue.volar
              dbaeumer.vscode-eslint
              esbenp.prettier-vscode
              bradlc.vscode-tailwindcss

              ms-azuretools.vscode-docker
              redhat.vscode-yaml
              ms-kubernetes-tools.vscode-kubernetes-tools

              rust-lang.rust-analyzer
              ms-python.python
              # asvetliakov.vscode-neovim
              # vscodevim.vim
              # tamasfe.even-better-toml
              # vadimcn.vscode-lldb
              # ms-vscode.cpptools
              # ms-vscode.cmake-tools
              # ms-vscode.makefile-tools
              # ziglang.vscode-zig
              # ms-dotnettools.csharp
              # pkief.material-icon-theme
              # equinusocio.vsc-material-theme
              # dracula-theme.theme-dracula
            ];

            # settings.json and keybindings.json are plain files in this directory,
            # edited live from VS Code (out-of-store symlink below), not generated
            # from this Nix attrset. Putting a userSettings/keybindings value back
            # here would make them collide with that symlink and fail activation --
            # home-manager's vscode module refuses to overwrite a target file that
            # changed outside its control (see modules/programs/vscode/mkVscodeModule.nix
            # in the home-manager source, immutableUserSettingsOperation).
            userSettings = config.lib.file.mkOutOfStoreSymlink "${self}/modules/programs/editor/vscode/settings.json";
            keybindings = config.lib.file.mkOutOfStoreSymlink "${self}/modules/programs/editor/vscode/keybindings.json";
          };
        };
      }
    )
  ];
}
