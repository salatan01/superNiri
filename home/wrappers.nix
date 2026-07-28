{ pkgs, ... }:

let
  # This is where the browser will save its "soul" (extensions, history)
  # but it remains isolated from your main configs.
  persistDir = "$HOME/.local/share/bromium";

  bromium = pkgs.writeShellScriptBin "bromium" ''
    # 1. Create the persistent folder if it doesn't exist
    mkdir -p "${persistDir}"

    # 2. Run the sandbox
    ${pkgs.bubblewrap}/bin/bwrap \
      --ro-bind /nix /nix \
      --ro-bind /run/current-system/sw /run/current-system/sw \
      --ro-bind /etc /etc \
      --dev /dev \
      --proc /proc \
      --tmpfs /tmp \
      --tmpfs $HOME \
      --bind "${persistDir}" $HOME \
      --unshare-all \
      --share-net \
      --die-with-parent \
      --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY" \
      --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
      --ro-bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" \
      --ro-bind /sys/dev /sys/dev \
      --ro-bind /sys/devices /sys/devices \
      --ro-bind /run/opengl-driver /run/opengl-driver \
      ${pkgs.chromium}/bin/chromium "$@"
  '';
in
{
  home.packages = [ bromium ];
}
