#!/usr/bin/env bash

mega_sanitize() {
  local target_dir="${1:-.}"

  # Strict dependency check
  for tool in exiftool magick file find rm mv cp touch mktemp; do
    if ! command -v "$tool" &>/dev/null; then
      echo "Error: Required binary '$tool' is not installed." >&2
      return 1
    fi
  done

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

  local CURRENT_TMP=""
  local CURRENT_SAFE=""

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

  while IFS= read -r -d '' img; do
    if [[ "$img" == *-safe.* ]]; then
      continue
    fi

    local filename="${img##*/}"
    local dir="${img%/*}"
    [[ "$dir" == "$img" ]] && dir="."
    local base="${filename%.*}"

    # Detect real format via magic bytes instead of relying on extension
    local mime_type
    mime_type=$(file --mime-type -b -- "$img" 2>/dev/null)

    local real_ext=""
    case "$mime_type" in
    image/jpeg) real_ext="jpg" ;;
    image/png) real_ext="png" ;;
    image/webp) real_ext="webp" ;;
    *)
      echo "  └─ [ERROR] Unsupported or unrecognized MIME type '$mime_type' for $filename" >&2
      continue
      ;;
    esac

    local safe_img="$dir/${base}-safe.${real_ext}"

    if [[ -e "$safe_img" ]]; then
      echo "[-] Skipping (Safe copy already exists): ${base}-safe.${real_ext}"
      continue
    fi

    echo "[+] Processing: $filename (Detected: $real_ext)"

    CURRENT_SAFE="$safe_img"

    if ! cp -- "$img" "$safe_img"; then
      echo "  └─ [ERROR] Failed to create working copy for $filename" >&2
      CURRENT_SAFE=""
      continue
    fi

    # -m ignores minor EXIF errors (corrupted metadata tags)
    local exif_err
    if ! exif_err=$(exiftool -m -all= -overwrite_original "$safe_img" 2>&1); then
      echo "  └─ [ERROR] ExifTool failed on $filename: $exif_err" >&2
      rm -f -- "$safe_img"
      CURRENT_SAFE=""
      continue
    fi

    if ! CURRENT_TMP=$(mktemp -p "$dir" --suffix=".$real_ext" .sanitize_XXXXXX); then
      echo "  └─ [ERROR] Failed to create temp file for $filename" >&2
      rm -f -- "$safe_img"
      CURRENT_SAFE=""
      continue
    fi

    local magick_status=0
    local magick_err=""
    if [[ "$real_ext" == "png" ]]; then
      magick_err=$(magick "$safe_img" -strip PNG32:"$CURRENT_TMP" 2>&1)
      magick_status=$?
    else
      magick_err=$(magick "$safe_img" -strip "$CURRENT_TMP" 2>&1)
      magick_status=$?
    fi

    if [[ $magick_status -eq 0 ]] && mv -- "$CURRENT_TMP" "$safe_img"; then
      if ! touch -r "$img" "$safe_img" &>/dev/null; then
        echo "  └─ [WARNING] Failed to preserve original timestamp." >&2
      fi

      echo "  └─ Cleaned: ${base}-safe.${real_ext}"

      CURRENT_TMP=""
      CURRENT_SAFE=""

      if [[ "$DELETE_ORIGINALS" == true ]]; then
        if rm -f -- "$img"; then
          echo "  └─ Removed original file."
        else
          echo "  └─ [WARNING] Failed to remove original file: $filename" >&2
        fi
      fi
    else
      echo "  └─ [ERROR] ImageMagick re-encoding failed for $filename: $magick_err" >&2
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
