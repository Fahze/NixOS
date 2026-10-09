{
  description = "A Nix-flake-based Kubernetes/GitOps development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # unstable Nixpkgs

  outputs =
    { self, ... }@inputs:

    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              kubectl
              kubernetes-helm
              k9s
              kustomize
              fluxcd
              argocd
              kubeseal
              sops
              age
              kind
              kubeconform
              stern
              yq-go
              self.formatter.${system}
            ];

            shellHook = ''
              mkdir -p .kube
              export KUBECONFIG="$PWD/.kube/config"
            '';
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
