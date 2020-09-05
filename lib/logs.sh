#! /usr/bin/env bash


# For internal use via the logging functions below.
#
# $1    String added between the program name and the message,
#       typically to specify the log level.
# $2    Printf-style format string.
# $3…n  Arguments for printf.
function _f_log {
    local prog
    
    prog=$(basename "$0"):
    
    printf "%s %s${2}\n" "$prog" "$1" "${@:3}"
}

# $1    Printf-style format string.
# $2…n  Arguments for printf.
function log {
    _f_log '   INFO  ' "$@"
}

# $1    Printf-style format string.
# $2…n  Arguments for printf.
function warn {
    _f_log 'WARNING  ' "$@" >&2
}

# $1    Printf-style format string.
# $2…n  Arguments for printf.
function err {
    _f_log '  ERROR  ' "$@" >&2
}

# $@    A command, meant to be run with “set -x” activated.
#
# Note that the command is run in a subshell.
# Won’t work well with “cd” and stuff.
function setx {
    (
        set -x
        "$@"
    )
}
