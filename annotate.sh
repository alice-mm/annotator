#! /usr/bin/env bash

set -e

# ————

# $1    Path, assumed to have an extension.
#
# stdout → Path,
#           • unchanged if the file does not exist;
#           • with an added number otherwise.
function alter_name_if_needed {
    local p=${1:?No path given.}
    local original_p=$p
    local -i n=1
    
    while [ -e "$p" ]
    do
        ((n++)) || true
        p=${original_p%.*}_${n}.${original_p##*.}
    done
    
    printf '%s\n' "$p"
}

function gravity_to_distance {
    local gravity=${1:?No gravity.}
    
    local distance
    
    case "$gravity" in
        north|south)
            distance="+0+${_config['distance']:?}"
            ;;
        
        east|west)
            distance="+${_config['distance']:?}+0"
            ;;
        
        center)
            distance=0
            ;;
        
        *)
            distance="+${_config['distance']:?}+${_config['distance']:?}"
            ;;
    esac
    
    printf '%s\n' "$distance"
}

# $1    Path to picture.
# $2    Gravity.
# $3    Output directory.
function process_one {
    local photo=${1:?No picture.}
    local gravity=${2:?No gravity.}
    local output_dir=${3:?No output directory.}
    
    local output
    output=${output_dir}/$(
        basename "${photo%.*}.${_config['output format']:?}"
    )
    output=$(alter_name_if_needed "$output")
    
    local distance
    distance=$(gravity_to_distance "$gravity")
    
    local text
    # Not mandatory.
    text=${_config['text']}
    
    log "$T_INPUT__Q" "$photo"
    log "$T_OUTPUT__Q" "$output"
    
    local -a opts
    
    if [ "${_config['resize']}" ]
    then
        opts+=(
            -resize "${_config['resize']}"
        )
    fi
    
    if [ "${_config['quality']}" ]
    then
        opts+=(
            -quality "${_config['quality']}"
        )
    fi
    
    opts+=(
        -pointsize "${_config['text size']:?}"
        -gravity "$gravity"

        -stroke "${_config['border color']:?}"
        -strokewidth "${_config['border size']:?}"
        -annotate "$distance" "$text"

        -stroke none
        -fill "${_config['text color']:?}"
        -annotate "$distance" "$text"
    )
    
    convert "$photo" "${opts[@]}" "$output"
    du -bh "$output"
}

# ————

readonly BASEDIR=$(cd "$(dirname "$0")" && pwd -P)

. "${BASEDIR:?}"/lib/constants.sh
. "${BASEDIR:?}"/lib/logs.sh
. "${BASEDIR:?}"/lib/config.sh

read_config "${BASEDIR:?}/${CONFIG_FILE:?}" _config

. "${BASEDIR:?}"/lib/lang/"${_config['language']:?}".sh

log "$T_CONFIG_END"

log "$T_START"


# Prepare the output directory.
output_dir=${BASEDIR:?}/output
mkdir -pv "$output_dir"


# Process the input files.
input_dir=${BASEDIR:?}/input

for gravity_dir in "${input_dir}"/*/
do
    if [ ! -d "$gravity_dir" ]
    then
        continue
    fi
    
    gravity=$(basename "$gravity_dir")
    # Clean up the path (trailing slash, etc.).
    gravity_dir=$(dirname "$gravity_dir")/"${gravity}"
    
    while read -rd '' photo
    do
        process_one "${photo:?}" "${gravity:?}" "${output_dir:?}"
    done < <(
        find "$gravity_dir"/ -type f -print0
    )
done

log "$T_END"
