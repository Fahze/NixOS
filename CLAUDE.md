# Contexte

Tu travailles sur ma configuration NixOS, qui tourne maintenant sur mon ThinkPad P14s Gen 5 AMD. Dépôt : ~/NixOS (fork de Sly-Harvey/NixOS, devenu divergent assumé), branche de travail : feat/thinkpad-fahze. Hôte : thinkpad-fahze, utilisateur : fahze.
Stack : flakes, home-manager, sops-nix, Hyprland (config en Lua dans modules/desktop/hyprland/lua/), waybar, swaync, rofi, hyprlock/hypridle, SDDM, GRUB + os-prober. Disque : LUKS2 + btrfs (sous-volumes @, @home, @nix). Thème : Catppuccin Macchiato, accent mauve, centralisé dans modules/themes/palette.nix. Zsh + kitty, VS Code, Zen Browser.
Moi : Ayoub, étudiant/alternant développeur web avec une orientation DevOps (Kubernetes, Helm, GitOps, Docker). Niveau Nix intermédiaire : explique brièvement tes choix non évidents. Réponds en français ; les messages de commit et les commentaires de code sont en anglais.

# Règles (non négociables)

1. Pour chaque tâche : d'abord exploration en LECTURE SEULE, puis un plan que je valide, puis l'exécution. Ta première réponse ne modifie aucun fichier.
2. Reste sur la branche feat/thinkpad-fahze (ou une sous-branche par lot si je le demande). Commits petits et atomiques, Conventional Commits (type(scope): message), un commit = un changement logique annulable seul. Ne pousse pas (git push) sans mon accord.
3. Jamais de `nh os switch`, `nixos-rebuild switch` ou `boot` sans mon accord explicite. Jamais de `nix flake update` ni de modification de flake.lock sans me demander (les pins comptent, surtout hyprland). Si un input doit être ajouté, dis-le-moi d'abord.
4. Ne touche pas, sans me le demander : hosts/thinkpad-fahze/hardware-configuration.nix, les stateVersion, les secrets (sops) et tout fichier de clés. Aucun secret en clair dans git (dépôt public).
5. Ne devine pas les noms d'options Nix : nixpkgs et home-manager évoluent vite (options renommées). Vérifie dans la source épinglée par flake.lock, avec `nix eval`/`nixos-option`, ou sur search.nixos.org si tu as le web.
6. Nix ne voit que les fichiers suivis par git : `git add` tout nouveau fichier avant d'évaluer.
7. Validation sans switch, dans cet ordre :
   - `git status --short`
   - `nix eval --raw .#nixosConfigurations.thinkpad-fahze.config.system.build.toplevel.drvPath`
   - `nh os build` (build complet sans activation)
   - `nix fmt` sur les fichiers touchés
   Pour les changements qui demandent un redémarrage (LUKS, initrd, Plymouth), propose `nh os boot` plutôt que `switch`, et garde la génération précédente disponible dans GRUB.
8. Pour chaque lot, donne-moi : fichiers touchés, diff prévu, risques, commandes de validation, test à faire après l'activation, et comment annuler.
9. Quand un point est marqué [À TRANCHER], tu me poses la question avec ta recommandation par défaut ; tu ne choisis pas à ma place.
10. Si une hypothèse de ce prompt est fausse (fichier absent, option inexistante), dis-le au lieu d'improviser.
