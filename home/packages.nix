# User-level packages, including custom qdl/qdlb downloader scripts.
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ./scripts/qdl.nix { })
    (pkgs.callPackage ./scripts/qdlb.nix { })
    pkgs.atool
    pkgs.httpie
    pkgs.eza
    # zoxide — provided by programs.zoxide in shell/tools.nix
  ];
}
