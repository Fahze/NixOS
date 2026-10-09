{ ... }:
{
  home-manager.sharedModules = [
    (_: {
      programs.git = {
        enable = true;
        settings = {
          user.name = "Fahze";
          user.email = "ayoub.moutawakil@proton.me";
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        };
        # SSH commit signing, prepared but not enforced yet: signByDefault
        # stays unset (false), so sign manually with `git commit -S` until
        # this is validated, then set signByDefault = true.
        signing = {
          format = "ssh";
          key = "~/.ssh/id_ed25519_github.pub";
        };
      };

      programs.delta.enable = true;
      programs.delta.enableGitIntegration = true;

      # gitCredentialHelper.enable defaults to true already.
      programs.gh.enable = true;
      programs.gh.settings.git_protocol = "ssh";
    })
  ];
}
