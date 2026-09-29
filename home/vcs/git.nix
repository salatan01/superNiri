{ config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  gitEmail = "259588134+salatan01@users.noreply.github.com";
  # Inlined from ~/.ssh/id_ed25519.pub — eval-safe on fresh machines (no builtins.readFile).
  pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7KydNmHCWkiU4M9SrpmYuhlnlY6Jxex+rXYaPr9Ta6 superkat01@nixos
";
in
{
  home.file.".ssh/allowed_signers".text = ''
    ${gitEmail} ${pubKey}
  '';

  # Delta is now a standalone module in newer Home Manager versions
  programs.delta = {
    enable = true;
    enableGitIntegration = true; # Explicitly set to fix deprecation warning
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "base16";
    };
  };

  programs.git = {
    enable = true;

    signing = {
      key = "${homeDir}/.ssh/id_ed25519";
      signByDefault = true;
    };

    # extraConfig and user details have been moved into 'settings'
    settings = {
      user = {
        name = "salatan01";
        email = gitEmail;
      };

      gpg = {
        format = "ssh";
        ssh = {
          program = "${pkgs.openssh}/bin/ssh-keygen";
          allowedSignersFile = "${homeDir}/.ssh/allowed_signers";
        };
      };

      # Security & Automation
      init.defaultBranch = "master";
      push.autoSetupRemote = true;
      core.askPass = "";
      # The guardrail that prevents real email leaks
      user.useConfigOnly = true;
    };
  };
}
