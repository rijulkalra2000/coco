#!/usr/bin/env bash
# Claude Code adapter — wires Coco artifacts into ~/.claude/
#
# Usage:
#   bash adapters/claude-code/install.sh                    # install everything
#   bash adapters/claude-code/install.sh --systems gsd      # add GSD bundle
#   bash adapters/claude-code/install.sh --dry-run          # preview only

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TARGET_HOME="${CLAUDE_HOME:-$HOME/.claude}"
DRY_RUN=0
SYSTEMS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --systems) shift; IFS=',' read -ra SYSTEMS <<< "$1" ;;
    --help|-h)
      grep '^#' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then echo "DRY: $*"; else "$@"; fi
}

link_dir() {
  local src=$1 dst=$2
  [[ -e "$dst" && ! -L "$dst" ]] && { echo "Skip (exists, not symlink): $dst"; return; }
  [[ -L "$dst" ]] && run rm "$dst"
  run mkdir -p "$(dirname "$dst")"
  run ln -sf "$src" "$dst"
  echo "Linked: $dst -> $src"
}

link_skills() {
  for skill in "$REPO_ROOT/skills"/*/; do
    name=$(basename "$skill")
    link_dir "$skill" "$TARGET_HOME/skills/$name"
  done
}

link_commands() {
  # Map commands/<namespace>/<name>.md → ~/.claude/commands/<namespace>:<name>.md
  for ns in "$REPO_ROOT/commands"/*/; do
    nsname=$(basename "$ns")
    for cmd in "$ns"*.md; do
      [[ -f "$cmd" ]] || continue
      cname=$(basename "$cmd" .md)
      if [[ "$cname" == "_index" ]]; then
        link_dir "$cmd" "$TARGET_HOME/commands/$nsname.md"
      else
        link_dir "$cmd" "$TARGET_HOME/commands/$nsname:$cname.md"
      fi
    done
  done
}

link_agents() {
  for agent in "$REPO_ROOT/agents"/*.md; do
    name=$(basename "$agent")
    link_dir "$agent" "$TARGET_HOME/agents/$name"
  done
}

link_system() {
  local sys=$1
  local sys_dir="$REPO_ROOT/systems/$sys"
  [[ -d "$sys_dir" ]] || { echo "Unknown system: $sys" >&2; exit 1; }
  if [[ -d "$sys_dir/skills" ]]; then
    for s in "$sys_dir/skills"/*/; do
      name=$(basename "$s")
      link_dir "$s" "$TARGET_HOME/skills/$name"
    done
  fi
  if [[ -d "$sys_dir/agents" ]]; then
    for a in "$sys_dir/agents"/*.md; do
      [[ -f "$a" ]] || continue
      name=$(basename "$a")
      link_dir "$a" "$TARGET_HOME/agents/$name"
    done
  fi
  if [[ -d "$sys_dir/commands" ]]; then
    for c in "$sys_dir/commands"/*.md; do
      [[ -f "$c" ]] || continue
      name=$(basename "$c")
      link_dir "$c" "$TARGET_HOME/commands/$name"
    done
  fi
}

echo "Coco · Claude Code adapter"
echo "Source: $REPO_ROOT"
echo "Target: $TARGET_HOME"
[[ $DRY_RUN -eq 1 ]] && echo "(dry-run mode)"

link_skills
link_commands
link_agents

for sys in "${SYSTEMS[@]:-}"; do
  [[ -n "$sys" ]] && link_system "$sys"
done

echo "Done."
