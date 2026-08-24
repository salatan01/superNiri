{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "qdl";

      # Hermetic binary dependencies guaranteed by Nix
      runtimeInputs = with pkgs; [
        yt-dlp
        ffmpeg
        gnused
        coreutils
        wl-clipboard
      ];

      text = ''
        set -euo pipefail

        DEST_DIR="$PWD"
        TEMP_FILE=""

        # Color Formatting
        GREEN='\033[0;32m'
        BLUE='\033[0;34m'
        YELLOW='\033[1;33m'
        RED='\033[0;31m'
        NC='\033[0m'

        # Signal Cleanup Trap
        cleanup() {
          if [[ -n "''${TEMP_FILE}" && -f "''${TEMP_FILE}" ]]; then
            echo -e "\n''${YELLOW}[!] Cleaning up temporary download files...''${NC}"
            rm -f "''${TEMP_FILE}"
          fi
        }
        trap cleanup EXIT SIGINT SIGTERM

        # --- Interactive URL Resolution ---
        URL="''${1:-}"

        if [[ -z "''${URL}" ]]; then
          CLIP_URL=""
          if command -v wl-paste >/dev/null 2>&1; then
            CLIP_URL=$(wl-paste 2>/dev/null || true)
          fi

          if [[ "''${CLIP_URL}" =~ ^https?:// ]]; then
            echo -e "''${YELLOW}[!] Detected URL in Wayland clipboard!''${NC}"
            read -e -r -p "URL: " -i "''${CLIP_URL}" URL
          else
            echo -e "''${BLUE}[?] Enter Video URL:''${NC}"
            read -r -p "URL: " URL
          fi
        fi

        if [[ -z "''${URL}" ]]; then
          echo -e "''${RED}Error:''${NC} No URL provided." >&2
          exit 1
        fi

        # --- 1. Fetch Metadata ---
        echo -e "''${BLUE}==> Fetching metadata...''${NC}"
        RAW_TITLE=$(yt-dlp --no-playlist --print title "$URL" 2>/dev/null || echo "qml_loop_video")

        # --- 2. QML-Safe Path Sanitization ---
        # Strips emojis, brackets, quotes, #, %, ?, and replaces spaces/special chars with underscores
        SAFE_TITLE=$(echo "$RAW_TITLE" \
          | tr -d '[:cntrl:]' \
          | sed -E 's/[#%?\x22\x27`\\\/[\]()!:=]/ /g' \
          | sed -E 's/[^a-zA-Z0-9._-]/_/g' \
          | sed -E 's/_+/_/g' \
          | sed -E 's/^_|_$//g')

        if [[ -z "$SAFE_TITLE" ]]; then
          SAFE_TITLE="qml_video"
        fi

        # --- 3. Interactive Rename Prompt ---
        echo -e "\n''${BLUE}[?] Edit Filename''${NC} (Use backspace/arrow keys, or press Enter):"
        if [[ -t 0 ]]; then
          read -e -r -p "Name: " -i "$SAFE_TITLE" USER_TITLE
        else
          USER_TITLE="$SAFE_TITLE"
        fi

        FINAL_BASE="''${USER_TITLE:-$SAFE_TITLE}"
        TEMP_FILE="/tmp/qdl_''${RANDOM}_raw.mp4"
        FINAL_FILE="''${DEST_DIR}/''${FINAL_BASE}.mp4"

        # Overwrite Safeguard
        if [[ -f "$FINAL_FILE" ]]; then
          echo -e "''${YELLOW}[!] Warning:''${NC} Destination file '$FINAL_FILE' already exists."
          read -r -p "Overwrite? [y/N]: " -n 1 OVERWRITE_CHOICE
          echo ""
          if [[ ! "$OVERWRITE_CHOICE" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
          fi
        fi

        # --- 4. Audio Option ---
        echo -e "\n''${BLUE}[?] Audio Preference:''${NC}"
        echo "  1) Keep Audio (AAC 192k)"
        echo "  2) Strip Audio (Silent UI Loop)"
        read -r -p "Choice [1/2] (Default 1): " -n 1 AUDIO_CHOICE
        echo ""

        FFMPEG_AUDIO_FLAGS=("-c:a" "aac" "-b:a" "192k")
        if [[ "''${AUDIO_CHOICE:-1}" == "2" ]]; then
          FFMPEG_AUDIO_FLAGS=("-an")
        fi

        # --- 5. Download Stream ---
        echo -e "\n''${BLUE}==> Downloading raw video stream (capped at 1440p)...''${NC}"
        yt-dlp \
          --no-playlist \
          -f "bv*[height<=1440]+ba/b[height<=1440]/b" \
          --merge-output-format mp4 \
          -o "$TEMP_FILE" \
          "$URL"

        if [[ ! -f "$TEMP_FILE" ]]; then
          echo -e "''${RED}Error:''${NC} Download failed to generate temporary file." >&2
          exit 1
        fi

        # --- 6. FFmpeg Re-encoding for QML Seamless Looping ---
        echo -e "\n''${BLUE}==> Encoding H.264 / Faststart / Fixed GOP for QML...''${NC}"
        ffmpeg -y -hide_banner -loglevel error -stats \
          -i "$TEMP_FILE" \
          -c:v libx264 -preset slow -crf 18 \
          -g 30 -keyint_min 30 -sc_threshold 0 \
          "''${FFMPEG_AUDIO_FLAGS[@]}" \
          -movflags +faststart \
          "$FINAL_FILE"

        echo -e "\n''${GREEN}==> Success!''${NC} Saved clean QML loop to:\n    ''${FINAL_FILE}"
      '';
    })
  ];
}
