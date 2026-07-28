# home.nix
{
  config,
  pkgs,
  unstable,
  pinned,
  inputs,
  ...
}:
{
  # Added 'inputs' here

  home.username = "nightkat01";
  home.homeDirectory = "/home/nightkat01";
  home.stateVersion = "25.11";

  imports = [

    ./home/megasn.nix
    ./home/starship.nix
    ./home/zsh.nix
    ./home/git.nix
    ./home/ghostty.nix
    ./home/wrappers.nix
  ];

  home.packages = [
    pkgs.atool
    pkgs.httpie
    pkgs.eza
    pkgs.zoxide
    #
    # Now you can use your bridges here too!
    #   unstable.discord
  ];

  programs.home-manager.enable = true;
}
