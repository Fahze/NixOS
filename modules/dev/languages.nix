{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Node.js (current LTS in the pinned nixpkgs)
    nodejs_24
    pnpm

    # Rust from nixpkgs (one global toolchain). For nightly or other targets,
    # use the per-project template: dev-shells/rust (fenix).
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    gcc # linker used by rustc

    # Python: interpreter plus uv (projects, venvs, pip, tools) and ruff (lint/format).
    # Libraries belong in a project venv (uv) or in dev-shells/python.
    python3
    uv
    ruff
  ];

  # rust-analyzer needs the standard library sources
  environment.variables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  # Run prebuilt, dynamically linked binaries (npm native modules, VS Code extensions...)
  programs.nix-ld.enable = true;
}
