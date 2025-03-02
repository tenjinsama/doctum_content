#!/bin/bash

# ------------------------------------------------------------------
# - Filename: gitkeep_all_folder.sh
# - Author : draed
# - Dependency : none
# - Description : script that automatically add or remove .gitkeep
# - Creation date : 2025-02-20
# - Bash version : 5.2.15(1)-release
# ------------------------------------------------------------------

set -uo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

add_gitkeep() {
  for dir in "$1"/*; do
    if [ -d "$dir" ]; then
      ## Check if the directory is empty
      if [ -z "$(ls -A "$dir")" ]; then
        touch "$dir/.gitkeep"
        echo "Added .gitkeep to empty directory: $dir"
      else
        ## Recursively call the function for non-empty directories
        add_gitkeep "$dir"
      fi
    fi
  done
}

manage_gitkeep() {
###  add or remove .gitkeep in empty directories ###
  for dir in "$1"/*; do
    if [ -d "$dir" ]; then
      ## Check if the directory is empty
      if [ -z "$(ls -A "$dir")" ]; then
        ## If empty, add .gitkeep
        if [ ! -f "$dir/.gitkeep" ]; then
          touch "$dir/.gitkeep"
          echo "Added .gitkeep to empty directory: $dir"
        fi
      else
        ## If not empty, remove .gitkeep if it exists
        if [ -f "$dir/.gitkeep" ]; then
          rm "$dir/.gitkeep"
          echo "Removed .gitkeep from non-empty directory: $dir"
        fi
        ## Recursively call the function for non-empty directories
        manage_gitkeep "$dir"
      fi
    fi
  done
}

# Start the process
manage_gitkeep "$1"