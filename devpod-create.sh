#!/usr/bin/env bash
set -euo pipefail

command -v gum >/dev/null 2>&1 || {
  echo "gum is required."
  echo "Install with:"
  echo "  brew install gum"
  exit 1
}

# Generic defaults
REPO_URL=""
PROVIDER="kubernetes"
WORKSPACE_ID=""
DOTFILES_URL=""
DOTFILES_SCRIPT=""
DEBUG="false"
RECREATE="false"
IDE=""
BRANCH=""

slugify() {
  echo "$1" \
    | sed 's#/$##' \
    | sed 's#.*[:/]##' \
    | sed 's#\.git$##' \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9-' '-' \
    | sed 's#^-##; s#-$##'
}

edit_value() {
  local label="$1"
  local current="${2:-}"

  gum input \
    --header "$label" \
    --placeholder "$current" \
    --value "$current"
}

toggle_bool() {
  local value="$1"

  if [[ "$value" == "true" ]]; then
    echo "false"
  else
    echo "true"
  fi
}

build_command() {
  CMD=(devpod up "$REPO_URL")

  [[ -n "$PROVIDER" ]] && CMD+=(--provider "$PROVIDER")
  [[ -n "$WORKSPACE_ID" ]] && CMD+=(--id "$WORKSPACE_ID")
  [[ -n "$DOTFILES_URL" ]] && CMD+=(--dotfiles "$DOTFILES_URL")
  [[ -n "$DOTFILES_SCRIPT" ]] && CMD+=(--dotfiles-script "$DOTFILES_SCRIPT")
  [[ -n "$IDE" ]] && CMD+=(--ide "$IDE")
  [[ -n "$BRANCH" ]] && CMD+=(--branch "$BRANCH")

  [[ "$DEBUG" == "true" ]] && CMD+=(--debug)
  [[ "$RECREATE" == "true" ]] && CMD+=(--recreate)
}

show_summary() {
  gum style \
    --border rounded \
    --padding "1 2" \
    --margin "1 0" \
    --foreground 212 \
    "Generic DevPod Launcher"

  gum format <<EOF
**Repository:** ${REPO_URL:-not set}
**Provider:** $PROVIDER
**Workspace ID:** ${WORKSPACE_ID:-auto}
**Dotfiles URL:** ${DOTFILES_URL:-none}
**Dotfiles script:** ${DOTFILES_SCRIPT:-none}
**IDE:** ${IDE:-default}
**Branch:** ${BRANCH:-default}
**Debug:** $DEBUG
**Recreate:** $RECREATE
EOF
}

ensure_required_values() {
  if [[ -z "$REPO_URL" ]]; then
    REPO_URL="$(edit_value "Repository URL or path" "")"
  fi

  if [[ -z "$WORKSPACE_ID" && -n "$REPO_URL" ]]; then
    WORKSPACE_ID="$(slugify "$REPO_URL")"
  fi
}

while true; do
  clear
  show_summary

  ACTION="$(gum choose \
    "Run devpod up" \
    "Edit repository" \
    "Edit provider" \
    "Edit workspace ID" \
    "Edit dotfiles URL" \
    "Edit dotfiles script" \
    "Edit IDE" \
    "Edit branch" \
    "Toggle debug" \
    "Toggle recreate" \
    "Show command" \
    "Quit")"

  case "$ACTION" in
    "Run devpod up")
      ensure_required_values
      build_command

      clear
      show_summary

      gum style --bold "Command:"
      printf '%q ' "${CMD[@]}"
      echo
      echo

      if gum confirm "Run this command?"; then
        "${CMD[@]}"
        exit $?
      fi
      ;;

    "Edit repository")
      REPO_URL="$(edit_value "Repository URL or local path" "$REPO_URL")"

      if [[ -z "$WORKSPACE_ID" ]]; then
        WORKSPACE_ID="$(slugify "$REPO_URL")"
      fi
      ;;

    "Edit provider")
      PROVIDER="$(gum choose \
        --header "Provider" \
        "kubernetes" \
        "docker" \
        "ssh" \
        "custom")"

      if [[ "$PROVIDER" == "custom" ]]; then
        PROVIDER="$(edit_value "Custom provider" "")"
      fi
      ;;

    "Edit workspace ID")
      WORKSPACE_ID="$(edit_value "Workspace ID" "$WORKSPACE_ID")"
      ;;

    "Edit dotfiles URL")
      DOTFILES_URL="$(edit_value "Dotfiles URL" "$DOTFILES_URL")"
      ;;

    "Edit dotfiles script")
      DOTFILES_SCRIPT="$(edit_value "Dotfiles script" "$DOTFILES_SCRIPT")"
      ;;

    "Edit IDE")
      IDE="$(gum choose \
        --header "IDE" \
        "" \
        "vscode" \
        "openvscode" \
        "none" \
        "custom")"

      if [[ "$IDE" == "custom" ]]; then
        IDE="$(edit_value "Custom IDE" "")"
      fi
      ;;

    "Edit branch")
      BRANCH="$(edit_value "Branch" "$BRANCH")"
      ;;

    "Toggle debug")
      DEBUG="$(toggle_bool "$DEBUG")"
      ;;

    "Toggle recreate")
      RECREATE="$(toggle_bool "$RECREATE")"
      ;;

    "Show command")
      ensure_required_values
      build_command
      clear

      gum style --bold "Generated command:"
      printf '%q ' "${CMD[@]}"
      echo
      echo

      gum input --placeholder "Press Enter to continue..." >/dev/null
      ;;

    "Quit")
      exit 0
      ;;
  esac
done
