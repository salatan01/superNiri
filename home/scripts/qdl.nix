# qdl.nix — single-video downloader
{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "qdl";

  runtimeInputs = with pkgs; [
    yt-dlp
    ffmpeg
    gnused
    coreutils
    jq
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

    cleanup() {
      if [[ -n "''${TEMP_FILE:-}" && -f "''${TEMP_FILE:-}" ]]; then
        rm -f "''${TEMP_FILE}"
      fi
    }
    trap cleanup EXIT

    # --- 1. Get URL ---
    URL="''${1:-}"
    if [[ -z "''${URL}" ]]; then
      CLIP_URL=""
      if command -v wl-paste >/dev/null 2>&1; then
        CLIP_URL=$(wl-paste 2>/dev/null || true)
      fi

      if [[ "''${CLIP_URL}" =~ ^https?:// ]]; then
        echo -e "''${YELLOW}[!] Detected URL in clipboard:''${NC} ''${CLIP_URL}"
        if [[ -t 0 ]]; then
          read -e -r -p "URL: " -i "''${CLIP_URL}" URL
        else
          URL="''${CLIP_URL}"
        fi
      elif [[ -t 0 ]]; then
        echo -e "''${BLUE}[?] Enter Video URL:''${NC}"
        read -r -p "URL: " URL
      fi
    fi

    if [[ -z "''${URL}" ]]; then
      echo -e "''${RED}Error:''${NC} No URL provided." >&2
      exit 1
    fi

    # --- 2. Rename First ---
    echo -e "''${BLUE}==> Fetching video metadata...''${NC}"
    RAW_TITLE=$(yt-dlp --no-playlist -j "$URL" 2>/dev/null | jq -r '.title // "video"' || echo "video")

    # UTF-8 safe filename sanitization
    SAFE_TITLE=$(echo "$RAW_TITLE" \
      | tr -d '[:cntrl:]' \
      | sed -E 's/[#%?\x22\x27`\\\/[\]()!:=]/_/g' \
      | sed -E 's/_+/_/g' \
      | sed -E 's/^_|_$//g')

    SAFE_TITLE="''${SAFE_TITLE:-video}"

    FINAL_BASE="$SAFE_TITLE"
    if [[ -t 0 ]]; then
      echo -e "\n''${BLUE}[?] Rename File''${NC} (Edit below or press Enter to accept):"
      read -e -r -p "Filename: " -i "$SAFE_TITLE" FINAL_BASE
    fi
    FINAL_BASE="''${FINAL_BASE:-$SAFE_TITLE}"
    FINAL_FILE="''${DEST_DIR}/''${FINAL_BASE}.mp4"

    # Overwrite Safeguard
    if [[ -f "$FINAL_FILE" ]]; then
      echo -e "''${YELLOW}[!] Warning:''${NC} '$FINAL_FILE' already exists."
      if [[ -t 0 ]]; then
        read -r -p "Overwrite? [y/N]: " -n 1 OVERWRITE_CHOICE
        echo ""
        if [[ ! "$OVERWRITE_CHOICE" =~ ^[Yy]$ ]]; then
          echo "Aborted."
          exit 0
        fi
      else
        echo "Non-interactive session detected. Aborting to prevent overwrite." >&2
        exit 1
      fi
    fi

    # --- 3. Quality Selection ---
    echo -e "\n''${BLUE}[?] Select Quality:''${NC}"
    echo "  1) 1080p Max"
    echo "  2) Maximum Available Settings (Default)"

    QUALITY_CHOICE="2"
    if [[ -t 0 ]]; then
      read -r -p "Choice [1/2] (Default 2): " -n 1 USER_Q
      echo ""
      if [[ -n "$USER_Q" ]]; then
        QUALITY_CHOICE="$USER_Q"
      fi
    fi

    FORMAT_SPEC="bv*+ba/b"
    if [[ "$QUALITY_CHOICE" == "1" ]]; then
      FORMAT_SPEC="bv*[height<=1080]+ba/b[height<=1080]/b"
    fi

    # --- 4. Download Stream ---
    TEMP_FILE=$(mktemp --tmpdir qdl_raw_XXXXXX.mp4)
    rm -f "$TEMP_FILE"

    echo -e "\n''${BLUE}==> Downloading video...''${NC}"
    yt-dlp \
      --no-playlist \
      --force-overwrites \
      -f "$FORMAT_SPEC" \
      --merge-output-format mp4 \
      -o "$TEMP_FILE" \
      "$URL"

    if [[ ! -s "$TEMP_FILE" ]]; then
      echo -e "''${RED}Error:''${NC} Download failed or temporary output file is empty." >&2
      exit 1
    fi

    # --- 5. Transpose / Quit Prompt ---
    TRANSPOSE_CHOICE="n"
    if [[ -t 0 ]]; then
      echo -e "\n''${BLUE}[?] Transpose video (Rotate 90° CCW via transpose=2)?''${NC}"
      read -r -p "Apply Transpose Filter? [y/N]: " -n 1 TRANSPOSE_CHOICE
      echo ""
    fi

    if [[ "$TRANSPOSE_CHOICE" =~ ^[Yy]$ ]]; then
      echo -e "\n''${BLUE}==> Re-encoding video with transpose=2...''${NC}"
      ffmpeg -y -hide_banner -loglevel error -stats \
        -i "$TEMP_FILE" \
        -vf "transpose=2" \
        -c:v libx264 -preset slow -crf 18 \
        -c:a copy \
        "$FINAL_FILE"

      echo -e "\n''${GREEN}==> Success!''${NC} Saved transposed video to:\n    ''${FINAL_FILE}"
    else
      echo -e "\n''${BLUE}==> Skipping transpose. Finalizing file...''${NC}"
      mv "$TEMP_FILE" "$FINAL_FILE"
      echo -e "\n''${GREEN}==> Success!''${NC} Saved original video to:\n    ''${FINAL_FILE}"
    fi
  '';
}
