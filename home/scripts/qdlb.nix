# qdlb.nix
{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "qdlb";

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

    # Color Formatting
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'

    MAX_VIDS=10
    urls=()
    preset_names=()
    names=()

    echo -e "''${BLUE}=== QDL Bulk Downloader (Max ''${MAX_VIDS} videos) ===''${NC}"

    # Helper function to parse 'name|URL' or 'URL|name' or plain 'URL'
    parse_and_add_input() {
      local raw_input="$1"
      local parsed_url=""
      local parsed_name=""

      if [[ "$raw_input" == *"|"* ]]; then
        local part1="''${raw_input%%|*}"
        local part2="''${raw_input#*|}"

        if [[ "$part1" =~ ^https?:// ]]; then
          parsed_url="$part1"
          parsed_name="$part2"
        elif [[ "$part2" =~ ^https?:// ]]; then
          parsed_url="$part2"
          parsed_name="$part1"
        fi
      elif [[ "$raw_input" =~ ^https?:// ]]; then
        parsed_url="$raw_input"
        parsed_name=""
      fi

      if [[ -n "$parsed_url" ]]; then
        urls+=("$parsed_url")
        preset_names+=("$parsed_name")
        return 0
      fi
      return 1
    }

    # --- Step 1: URL Collection Phase ---
    if [[ $# -gt 0 ]]; then
      echo -e "''${BLUE}==> Collecting URLs from CLI arguments...''${NC}"
      for arg in "$@"; do
        if [[ "''${#urls[@]}" -ge "$MAX_VIDS" ]]; then
          echo -e "''${YELLOW}[!] Hit limit of ''${MAX_VIDS} videos. Ignoring remaining arguments.''${NC}"
          break
        fi
        parse_and_add_input "$arg" || true
      done
    fi

    if [[ "''${#urls[@]}" -eq 0 ]]; then
      echo -e "Enter URLs (or ''${YELLOW}name|URL''${NC}). Press ''${YELLOW}Enter on a blank line''${NC} or type ''${YELLOW}done''${NC} to start processing.\n"
      
      CLIP_URL=""
      if command -v wl-paste >/dev/null 2>&1; then
        CLIP_URL=$(wl-paste 2>/dev/null || true)
      fi

      count=1
      while [[ "$count" -le "$MAX_VIDS" ]]; do
        PROMPT_DEFAULT=""
        if [[ "$count" -eq 1 && "''${CLIP_URL}" =~ ^https?:// ]]; then
          echo -e "''${YELLOW}[!] Detected URL in Wayland clipboard for URL #1''${NC}"
          PROMPT_DEFAULT="$CLIP_URL"
        fi

        if [[ -n "$PROMPT_DEFAULT" && -t 0 ]]; then
          read -e -r -p "URL [$count/$MAX_VIDS]: " -i "$PROMPT_DEFAULT" INPUT_LINE || break
        else
          read -r -p "URL [$count/$MAX_VIDS]: " INPUT_LINE || break
        fi

        if [[ -z "$INPUT_LINE" || "$INPUT_LINE" == "done" ]]; then
          break
        fi

        if ! parse_and_add_input "$INPUT_LINE"; then
          echo -e "''${RED}Invalid URL format! Skipping...''${NC}"
          continue
        fi

        count=$((count + 1))
      done
    fi

    TOTAL_QUEUE="''${#urls[@]}"
    if [[ "$TOTAL_QUEUE" -eq 0 ]]; then
      echo -e "\n''${RED}Error:''${NC} No valid URLs submitted. Exiting." >&2
      exit 1
    fi

    # --- Step 2: Metadata & Filename Staging Phase ---
    echo -e "\n''${BLUE}=== Staging Titles & Filenames ($TOTAL_QUEUE items) ===''${NC}"
    for idx in "''${!urls[@]}"; do
      item_num=$((idx + 1))
      target_url="''${urls[$idx]}"
      preset_name="''${preset_names[$idx]}"

      if [[ -n "$preset_name" ]]; then
        echo -e "\n''${BLUE}[$item_num/$TOTAL_QUEUE] Using preset custom title:''${NC} ''${YELLOW}$preset_name''${NC}"
        RAW_TITLE="$preset_name"
      else
        echo -e "\n''${BLUE}[$item_num/$TOTAL_QUEUE] Fetching metadata...''${NC}"
        RAW_TITLE=$(yt-dlp --no-playlist -j "$target_url" 2>/dev/null | jq -r '.title // empty' || true)
        if [[ -z "$RAW_TITLE" ]]; then
          RAW_TITLE=$(yt-dlp --cookies-from-browser firefox --no-playlist -j "$target_url" 2>/dev/null | jq -r '.title // "video"' || echo "video_$item_num")
        fi
      fi

      SAFE_TITLE=$(echo "$RAW_TITLE" \
        | tr -d '[:cntrl:]' \
        | sed -E 's/[#%?\x22\x27`\\\/[\]()!:=]/_/g' \
        | sed -E 's/_+/_/g' \
        | sed -E 's/^_|_$//g')

      SAFE_TITLE="''${SAFE_TITLE:-video_$item_num}"

      if [[ -z "$preset_name" && -t 0 ]]; then
        echo -e "''${BLUE}[?] Edit Filename''${NC} (Use backspace/arrow keys, or press Enter):"
        read -e -r -p "Filename: " -i "$SAFE_TITLE" USER_TITLE
        names+=("''${USER_TITLE:-$SAFE_TITLE}")
      else
        names+=("$SAFE_TITLE")
      fi
    done

    # --- Step 3: Global Batch Configuration ---
    echo -e "\n''${BLUE}=== Batch Options Setup ===''${NC}"

    # 1. Quality Choice
    echo -e "\n''${BLUE}[?] Quality Option:''${NC}"
    echo "  1) 1080p Max"
    echo "  2) Maximum Available Settings (Default)"
    QUALITY_CHOICE="2"
    if [[ -t 0 ]]; then
      read -r -p "Choice [1/2] (Default 2): " -n 1 USER_Q
      echo ""
      if [[ -n "$USER_Q" ]]; then QUALITY_CHOICE="$USER_Q"; fi
    fi

    FORMAT_SPEC="bv*+ba/b"
    if [[ "$QUALITY_CHOICE" == "1" ]]; then
      FORMAT_SPEC="bv*[height<=1080]+ba/b[height<=1080]/b"
    fi

    # 2. Transpose Filter
    echo -e "\n''${BLUE}[?] Transpose video (Rotate 90° CCW via transpose=2)?''${NC}"
    TRANSPOSE_CHOICE="n"
    if [[ -t 0 ]]; then
      read -r -p "Apply Transpose Filter? [y/N]: " -n 1 TRANSPOSE_CHOICE
      echo ""
    fi

    # 3. Overwrite / Duplicate Handling
    echo -e "\n''${BLUE}[?] Handle Existing Files:''${NC}"
    echo "  1) Auto-increment name if exists (e.g. video_01.mp4) (Default)"
    echo "  2) Overwrite existing files"
    OVERWRITE_MODE="1"
    if [[ -t 0 ]]; then
      read -r -p "Choice [1/2] (Default 1): " -n 1 USER_OW
      echo ""
      if [[ -n "$USER_OW" ]]; then OVERWRITE_MODE="$USER_OW"; fi
    fi

    # --- Step 4: Batch Processing & Error Isolation Loop ---
    echo -e "\n''${GREEN}=== Starting Batch Process ($TOTAL_QUEUE items) ===''${NC}\n"
    FAILED_ITEMS=()

    for idx in "''${!urls[@]}"; do
      item_num=$((idx + 1))
      target_url="''${urls[$idx]}"
      target_base="''${names[$idx]}"

      if [[ "$OVERWRITE_MODE" == "1" && -f "''${DEST_DIR}/''${target_base}.mp4" ]]; then
        inc=1
        while [[ -f "''${DEST_DIR}/''${target_base}_$(printf "%02d" $inc).mp4" ]]; do
          inc=$((inc + 1))
        done
        target_base="''${target_base}_$(printf "%02d" $inc)"
      fi

      final_file="''${DEST_DIR}/''${target_base}.mp4"

      echo -e "''${BLUE}[$item_num/$TOTAL_QUEUE] Processing:''${NC} $target_base"

      temp_file=$(mktemp --tmpdir qdlb_raw_XXXXXX.mp4)
      rm -f "$temp_file"

      # Attempt 1: Anonymous download
      echo -e "  ''${BLUE}==> Downloading raw stream (Anonymous)...''${NC}"
      set +e
      yt-dlp \
        --no-playlist \
        --force-overwrites \
        -f "$FORMAT_SPEC" \
        --merge-output-format mp4 \
        -o "$temp_file" \
        "$target_url"
      dl_status=$?
      set -e

      # Attempt 2: Fallback to Firefox cookies if anonymous failed
      if [[ $dl_status -ne 0 || ! -s "$temp_file" ]]; then
        echo -e "  ''${YELLOW}[!] Anonymous fetch failed. Retrying with Firefox cookies...''${NC}"
        rm -f "$temp_file"
        set +e
        yt-dlp \
          --no-playlist \
          --force-overwrites \
          --cookies-from-browser firefox \
          -f "$FORMAT_SPEC" \
          --merge-output-format mp4 \
          -o "$temp_file" \
          "$target_url"
        dl_status=$?
        set -e
      fi

      if [[ $dl_status -ne 0 || ! -s "$temp_file" ]]; then
        echo -e "  ''${RED}[X] Download failed for $target_url. Skipping to next...''${NC}\n"
        rm -f "$temp_file"
        FAILED_ITEMS+=("$target_base ($target_url)")
        continue
      fi

      echo -e "  ''${BLUE}==> Encoding H.264 / AAC / Faststart / Fixed GOP for QML...''${NC}"
      VF_FLAGS=()
      if [[ "$TRANSPOSE_CHOICE" =~ ^[Yy]$ ]]; then
        VF_FLAGS+=("-vf" "transpose=2")
      fi

      set +e
      ffmpeg -y -hide_banner -loglevel error -stats \
        -i "$temp_file" \
        "''${VF_FLAGS[@]}" \
        -c:v libx264 -preset slow -crf 18 \
        -g 60 -keyint_min 60 -sc_threshold 0 -flags +cgop \
        -c:a aac -b:a 192k \
        -movflags +faststart \
        "$final_file"
      ff_status=$?
      set -e

      rm -f "$temp_file"

      if [[ $ff_status -ne 0 ]]; then
        echo -e "  ''${RED}[X] FFmpeg encoding failed for $target_base''${NC}\n"
        FAILED_ITEMS+=("$target_base (FFmpeg Encoding Error)")
        continue
      fi

      echo -e "  ''${GREEN}[✓] Successfully saved:''${NC} ''${final_file}\n"
    done

    # --- Step 5: Summary Report ---
    FAILED_COUNT="''${#FAILED_ITEMS[@]}"
    SUCCESS_COUNT=$((TOTAL_QUEUE - FAILED_COUNT))

    echo -e "''${BLUE}=== Batch Processing Summary ===''${NC}"
    echo -e "Total Queued:  ''${TOTAL_QUEUE}"
    echo -e "  ''${GREEN}✓ Succeeded:''${NC} ''${SUCCESS_COUNT}"
    echo -e "  ''${RED}✗ Failed:''${NC}    ''${FAILED_COUNT}"

    if [[ "$FAILED_COUNT" -gt 0 ]]; then
      echo -e "\n''${RED}Failed Items Breakdown:''${NC}"
      for failed in "''${FAILED_ITEMS[@]}"; do
        echo -e "  - $failed"
      done
    fi
  '';
}
