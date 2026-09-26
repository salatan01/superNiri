{ pkgs, ... }:

let
  megasn = pkgs.writeShellApplication {
    name = "megasn";

    runtimeInputs = with pkgs; [
      exiftool
      imagemagick
      findutils
      coreutils
      file
    ];

    text = builtins.readFile ../assets/scripts/mega_sanitize.sh;
  };
in
{
  home.packages = [ megasn ];
}
