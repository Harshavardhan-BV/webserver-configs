#!/bin/bash

srcdir=./compose-files
dstdir=$HOME/docker

mkhardlink() {
    mkdir -p "$2/$dock"
    rm "$2/$dock/docker-compose.yml"
    ln "$1/$dock/docker-compose.yml" "$2/$dock/docker-compose.yml"
}

# Function to see if there is any entries in srcdocks that are not in destdocks
missing_docks() {
    # List subdirectories in srcdir with docker-compose.yml files
    srcdocks=$(find "$1" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/docker-compose.yml' ';' -print | xargs -n 1 basename)
    destdocks=$(find "$2" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/docker-compose.yml' ';' -print | xargs -n 1 basename)
    # Missing docks in destdocks
    notpresent=$(comm -23 <(echo "$srcdocks" | sort) <(echo "$destdocks" | sort))
    for dock in $notpresent; do
        echo "Compose-file for $dock is not present in $2, Copy a hard-link? (y/N)"
        read -r answer
        if [[ "$answer" = "y" ]] || [[ "$answer" = "Y" ]]; then
            mkhardlink "$1" "$2"
        fi
    done
}

# Check if the compose-files in srcdir are in sync with dstdir
modified_docks(){
    # List subdirectories in srcdir with docker-compose.yml files
    srcdocks=$(find "$1" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/docker-compose.yml' ';' -print | xargs -n 1 basename)
    destdocks=$(find "$2" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/docker-compose.yml' ';' -print | xargs -n 1 basename)
    # Common docks in srcdocks and destdocks
    common=$(comm -12 <(echo "$srcdocks" | sort) <(echo "$destdocks" | sort))
    for dock in $common; do
        # Check if the diff -q returns anything
        if [[ $(diff -q "$1/$dock/docker-compose.yml" "$2/$dock/docker-compose.yml") ]]; then
            echo "Compose-file for $dock is not synced"
            echo "Changes in $1/$dock/docker-compose.yml:"
            diff -u "$1/$dock/docker-compose.yml" "$2/$dock/docker-compose.yml"
            echo "Choose an action: (1) Copy a hard-link from $1 to $2, (2) Copy a hard-link from $2 to $1. Note that the existing file will be removed. (1/2)"
            read -r answer
            if [[ "$answer" = "1" ]]; then
                echo "Copying hard-link from $1 to $2. Continue? (y/N)"
                read -r answer
                if [[ "$answer" = "y" ]] || [[ "$answer" = "Y" ]]; then
                    mkhardlink "$1" "$2"
                fi
            elif [[ "$answer" = "2" ]]; then
                echo "Copying hard-link from $2 to $1. Continue? (y/N)"
                read -r answer
                if [[ "$answer" = "y" ]] || [[ "$answer" = "Y" ]]; then
                    mkhardlink "$2" "$1"
                fi
            fi
        fi
    done
}

missing_docks "$srcdir" "$dstdir"
missing_docks "$dstdir" "$srcdir"
modified_docks "$srcdir" "$dstdir"