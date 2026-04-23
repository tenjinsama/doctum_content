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

manage_gitkeep() {
    ### add or remove .gitkeep in empty directories ###
    for dir in "$1"/*; do
        if [ -d "$dir" ]; then
            ## Check if the directory is empty or contains only .gitkeep
            non_gitkeep_files=$(find "$dir" -maxdepth 1 -mindepth 1 ! -name ".gitkeep")

            if [ -z "$non_gitkeep_files" ]; then
                ## If empty or only .gitkeep, ensure .gitkeep exists
                if [ ! -f "$dir/.gitkeep" ]; then
                    touch "$dir/.gitkeep"
                    echo "Added .gitkeep to empty directory: $dir"
                fi
            else
                ## If it contains other files, remove .gitkeep if it exists
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

## Start the process
manage_gitkeep "$1"