{ ... }:
{
  home.username = "superkat01";
  home.homeDirectory = "/home/superkat01";
  home.stateVersion = "25.11";

  imports = [
    ./packages.nix
    ./mime.nix
    ./shell/zsh.nix
    ./shell/starship.nix
    ./shell/tools.nix
    ./terminals/ghostty.nix
    ./terminals/kitty.nix
    ./launcher/wofi.nix
    ./vcs/git.nix
    ./scripts/bromium.nix
    ./scripts/megasn.nix
  ];

  programs.home-manager.enable = true;
}
