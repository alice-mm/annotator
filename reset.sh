#! /usr/bin/env bash

set -e

readonly BASEDIR=$(cd "$(dirname "$0")" && pwd -P)

. "${BASEDIR:?}"/lib/constants.sh
. "${BASEDIR:?}"/lib/logs.sh
. "${BASEDIR:?}"/lib/config.sh

read_config "${BASEDIR:?}/${CONFIG_FILE:?}" _config

. "${BASEDIR:?}"/lib/lang/"${_config['language']:?}".sh

log "$T_CONFIG_END"

log "$T_START"

log "$T_RESET_WHAT"

select target in 'Output' 'Input & output'
do
    if [ "$target" ]
    then
        break
    fi
done

printf -- '--> %s\n' "$target"

unset -v dirs
if [ "$target" = Output ]
then
    dirs=(
        output
    )
else
    dirs=(
        input/{{north,south}{west,,east},east,west,center}
        output
    )
fi

mkdir -pv -- "${dirs[@]}"
find "${dirs[@]}" -type f -printf "${T_RESET_DELETE__P}\n" -delete

log "$T_END"
