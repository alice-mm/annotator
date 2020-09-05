#! /usr/bin/env bash


# Filter to trim.
function _trim {
    sed '
        # Space, nbsp, nnbsp.
        s/^[   \t]*//
        s/[   \t]*$//
    '
}

# $1    Path to config file.
# $2    Name of associative array to be created with the config in it.
function read_config {
    local key
    local val
    
    unset -v "$2"
    declare -gA "$2"
    
    if [ "$2" != t ]
    then
        local -n t=$2
    fi
    
    while IFS=':' read -r key val
    do
        key=$(_trim <<< "$key")
        val=$(_trim <<< "$val")

        if [ "$key" ]
        then
            # Store config in array, using lowercase key as array key.
            t[${key,,}]=$val
        fi
    done <<< "$(
        # Force final newline via “<<<”.
        grep -v -- '^[ \t]*#' "$1"
    )"
}
