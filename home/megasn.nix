{ pkgs, ... }:

let
  megasn = pkgs.writeShellApplication {
    name = "megasn";

    runtimeInputs = with pkgs; [
      exiftool
      imagemagick
      findutils
      coreutils
    ];

    # Reads the file directly from the relative directory path.
    # No more escaping tricks (''${}) needed here, as the text is handled raw.
    text = builtins.readFile ./assets/scripts/mega_sanitize.sh;
  };
in
{
  home.packages = [ megasn ];
}
