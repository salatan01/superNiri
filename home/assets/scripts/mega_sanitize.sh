#!/usr/bin/env bash

mega_sanitize() {
  local target_dir="${1:-.}"

  # Strict dependency check
  if ! command -v exiftool &>/dev/null || ! command -v magick &>/dev/null; then
    echo "Error: Both 'exiftool' and 'imagemagick' must be installed." >&2
    return 1
  fi

  # Interactive prompt: Ask ONCE at the beginning if running in a terminal
  local DELETE_ORIGINALS=false
  if [[ -t 0 ]]; then
    echo -n "Do you want to delete the original files after successful sanitization? (y/N): "
    read -r choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      DELETE_ORIGINALS=true
      echo "[!] Originals WILL be deleted upon successful sanitization."
    else
      echo "[*] Keeping original files. Cleaned versions will use '-safe'."
    fi
    echo "--------------------------------------------------------"
  fi

  echo "=== Starting Hardened Mega Sanitize in: $target_dir ==="

  # Track both working files globally for flawless cleanup on interrupt
  local CURRENT_TMP=""
  local CURRENT_SAFE=""

  # Precise signal trapping with conventional POSIX exit codes
  trap '
        echo -e "\n[!] Interrupted via Ctrl+C. Cleaning up working files..." >&2
        [[ -n "$CURRENT_TMP" ]] && rm -f -- "$CURRENT_TMP"
        [[ -n "$CURRENT_SAFE" ]] && rm -f -- "$CURRENT_SAFE"
        exit 130
    ' SIGINT

  trap '
        echo -e "\n[!] Termination signal received. Cleaning up working files..." >&2
        [[ -n "$CURRENT_TMP" ]] && rm -f -- "$CURRENT_TMP"
        [[ -n "$CURRENT_SAFE" ]] && rm -f -- "$CURRENT_SAFE"
        exit 143
    ' SIGTERM

  # Process substitution prevents the subshell trap isolation bug
  while IFS= read -r -d '' img; do

    if [[ "$img" == *-safe.* ]]; then
      continue
    fi

    # Pure Bash parameter expansion prevents thousands of costly subprocess forks
    local filename="${img##*/}"
    local dir="${img%/*}"
    [[ "$dir" == "$img" ]] && dir="."

    local base="${filename%.*}"
    local ext="${filename##*.}"
    local safe_img="$dir/${base}-safe.${ext}"

    if [[ -e "$safe_img" ]]; then
      echo "[-] Skipping (Safe copy already exists): $filename"
      continue
    fi

    echo "[+] Processing: $filename"

    # Register the safe image for trap cleanup before creating it
    CURRENT_SAFE="$safe_img"

    if ! cp -- "$img" "$safe_img"; then
      echo "  └─ [ERROR] Failed to create working copy for $filename" >&2
      CURRENT_SAFE=""
      continue
    fi

    if ! exiftool -all= -overwrite_original "$safe_img" &>/dev/null; then
      echo "  └─ [ERROR] ExifTool failed on $filename. Cleaning up partial file." >&2
      rm -f -- "$safe_img"
      CURRENT_SAFE=""
      continue
    fi

    # Create temp file in the SAME directory to guarantee an ATOMIC 'mv'
    if ! CURRENT_TMP=$(mktemp -p "$dir" --suffix=".$ext" .sanitize_XXXXXX); then
      echo "  └─ [ERROR] Failed to create temp file for $filename" >&2
      rm -f -- "$safe_img"
      CURRENT_SAFE=""
      continue
    fi

    local magick_status=0
    if [[ "${ext,,}" == "png" ]]; then
      # PNG32: forces maximum pixel sanitization over layout optimization
      magick "$safe_img" -strip PNG32:"$CURRENT_TMP" &>/dev/null
      magick_status=$?
    else
      magick "$safe_img" -strip "$CURRENT_TMP" &>/dev/null
      magick_status=$?
    fi

    # Verify execution and swap atomically (safeguarded with --)
    if [[ $magick_status -eq 0 ]] && mv -- "$CURRENT_TMP" "$safe_img"; then

      # Explicit verification of timestamp preservation
      if ! touch -r "$img" "$safe_img" &>/dev/null; then
        echo "  └─ [WARNING] Failed to preserve original timestamp." >&2
      fi

      echo "  └─ Cleaned: ${base}-safe.${ext}"

      # Clear state trackers; the file is now safely finalized
      CURRENT_TMP=""
      CURRENT_SAFE=""

      # Verified deletion path protecting against filenames starting with '-'
      if [[ "$DELETE_ORIGINALS" == true ]]; then
        if rm -f -- "$img"; then
          echo "  └─ Removed original file."
        else
          echo "  └─ [WARNING] Failed to remove original file: $filename" >&2
        fi
      fi
    else
      echo "  └─ [ERROR] ImageMagick re-encoding failed for $filename" >&2
      rm -f -- "$CURRENT_TMP" "$safe_img"
      CURRENT_TMP=""
      CURRENT_SAFE=""
    fi

  done < <(
    find "$target_dir" -type f \
      \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) \
      -print0
  )

  trap - SIGINT SIGTERM
  echo "=== Mega Sanitize Complete! ==="
}

mega_sanitize "${1:-.}"
