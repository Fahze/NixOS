# NixOS configuration for a ThinkPad P14s Gen 5 (AMD)

Personal NixOS flake for my Lenovo ThinkPad P14s Gen 5 AMD (host `thinkpad-fahze`, user `fahze`).

This repository is a fork of [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) (MIT),
reworked for a single laptop. See [Credits](#credits).

> **Status:** work in progress. The configuration evaluates, but the host has not been installed yet.

## What it sets up

- **System:** NixOS (`nixos-unstable`), flakes, GRUB with os-prober, LUKS2 + btrfs.
- **Desktop:** Hyprland (Lua configuration), waybar, hyprlock/hypridle, swaync, rofi, SDDM.
- **Theme:** Catppuccin, driven by two variables (`catppuccinFlavor`, `catppuccinAccent`) through
  [`modules/themes/palette.nix`](../modules/themes/palette.nix). Currently Macchiato / mauve.
- **Laptop:** TLP tuned for AMD (amd-pstate, charge thresholds 82-90 %), lid and power key handling
  with logind, fingerprint reader (fprintd, also used by hyprlock), fwupd.
- **Dev:** Docker, Node.js and pnpm, Rust, `nix-ld`, VS Code / Zed / Neovim, tmux, lazygit.
- **Secrets:** [sops-nix](https://github.com/Mic92/sops-nix) with age. The user password is stored
  encrypted in `secrets/secrets.yaml`, `root` is locked and users are immutable.
- **Home:** home-manager as a NixOS module.

## Layout

| Path | Content |
| --- | --- |
| `flake.nix` | Inputs and the `thinkpad-fahze` host |
| `hosts/thinkpad-fahze/` | `variables.nix`, `configuration.nix`, `hardware-configuration.nix`, `host-packages.nix` |
| `modules/core/` | System basics: boot, users, secrets, network, shell, services |
| `modules/hardware/` | Laptop, GPU drivers |
| `modules/desktop/` | Desktop environments (Hyprland is the one in use) |
| `modules/programs/` | Applications, selected by variables (terminal, editor, browser...) |
| `modules/themes/` | Catppuccin palette, GTK/Qt theme, wallpapers |
| `modules/dev/` | Docker and language toolchains |
| `secrets/`, `.sops.yaml` | Encrypted secrets and their recipients |
| `docs/INSTALL.md` | Installation guide (French) |
| `old/` | Upstream assets kept for later |

Most choices are variables in [`hosts/thinkpad-fahze/variables.nix`](../hosts/thinkpad-fahze/variables.nix)
(desktop, bar, terminal, editor, browser, keyboard layouts, locale, theme...).

## Install

Follow [`docs/INSTALL.md`](../docs/INSTALL.md). `install.sh` and `live-install.sh` come from the
upstream repository, still refer to its example hosts and **do not work** with this fork yet.

## Daily use

```bash
rebuild                                   # nixos-rebuild switch for this host
sudo nixos-rebuild switch --flake .#thinkpad-fahze
nix fmt                                   # format the tree
```

Nix only sees files tracked by git: `git add` new files before rebuilding.

## Credits

Based on [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) by Harvey Jacobs-Grant, released
under the MIT license (see [`LICENSE`](../LICENSE)). Catppuccin colors come from the
[Catppuccin](https://github.com/catppuccin/catppuccin) project.
