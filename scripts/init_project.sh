#!/usr/bin/env bash
# scripts/init_project.sh — Rebrands the template for a new project
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <NewProjectName>"
    exit 1
fi

NEW_NAME="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ">>> Initializing new project: $NEW_NAME"

# 1. Replace "MyProject" with New Name in CMake and Source
echo "    Updating strings..."
grep -rli "MyProject" "$ROOT" --exclude-dir=".git" --exclude="init_project.sh" | xargs sed -i '' "s/MyProject/$NEW_NAME/g"

# 2. Reset Git History (Optional but recommended for templates)
# read -p "    Reset git history? (y/n) " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     echo "    Resetting git history..."
#     rm -rf "$ROOT/.git"
#     git init "$ROOT"
#     git add -A
#     git commit -m "Initial commit from template ($NEW_NAME)"
# fi

echo ">>> Done. Your project is now branded as $NEW_NAME."
echo "    Run 'cmake --preset dev' to verify."
