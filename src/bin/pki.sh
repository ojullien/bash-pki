#!/bin/bash

## -----------------------------------------------------------------------------
## Linux Scripts.
## Public Key Infrastructure (PKI) management toolkit.
##
## @package ojullien\bash\bin
## @license MIT <https://github.com/ojullien/bash-pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------
#set -o errexit
set -o nounset
set -o pipefail

## -----------------------------------------------------------------------------
## Shell scripts directory, eg: /root/work/Shell/src/bin
## -----------------------------------------------------------------------------
readonly m_DIR_REALPATH="$(realpath "$(dirname "$0")")"

## -----------------------------------------------------------------------------
## Load constants
## -----------------------------------------------------------------------------
# shellcheck source=/dev/null
. "${m_DIR_REALPATH}/../sys/constant.sh"

## -----------------------------------------------------------------------------
## Includes sources & configuration
## -----------------------------------------------------------------------------
# shellcheck source=/dev/null
. "${m_DIR_SYS}/runasroot.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/string.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/filesystem.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/openssl.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/option.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/config.sh"
# Load PKI configuration
Config::load "pki"

# shellcheck source=/dev/null
. "${m_DIR_APP}/pki/app.sh"

## -----------------------------------------------------------------------------
## Help
## -----------------------------------------------------------------------------
((m_OPTION_SHOWHELP)) && PKI::showHelp && exit 0
(( 0==$# )) && PKI::showHelp && exit 1

## -----------------------------------------------------------------------------
## Trace
## -----------------------------------------------------------------------------
Constant::trace

## -----------------------------------------------------------------------------
## Start
## -----------------------------------------------------------------------------
String::separateLine
String::notice "Today is: $(date -R)"
String::notice "The PID for $(basename "$0") process is: $$"
Console::waitUser

## -----------------------------------------------------------------------------
## Main PKI commands
## -----------------------------------------------------------------------------

# Parameters
if (($# < 1)); then
    PKI::showHelp
    return 1
fi

# Do the job
case "$1" in

    rootca|root|rca|r) # Simple PKI root CA level
        shift
        # shellcheck source=/dev/null
        . "${m_DIR_APP}/pki/root_app.sh"
        PKI::Root::main "$@"
        ;;

    signingca|signing|sca|s) # Simple PKI intermediate signing CA level
        shift
        # shellcheck source=/dev/null
        . "${m_DIR_APP}/pki/signing_app.sh"
        PKI::Signing::main "$@"
        ;;

    tls) # User level, TLS certificate
        shift
        # shellcheck source=/dev/null
        . "${m_DIR_APP}/pki/user_app.sh"
        PKI::User::main "tls" "$@"
        ;;

    email) # User level, Email certificate
        shift
        # shellcheck source=/dev/null
        . "${m_DIR_APP}/pki/user_app.sh"
        PKI::User::main "email" "$@"
        ;;

    soft) # User level, Software certificate
        shift
        # shellcheck source=/dev/null
        . "${m_DIR_APP}/pki/user_app.sh"
        PKI::User::main "soft" "$@"
        ;;

    *)
        String::error "argument error: missing or incorrect command."
        PKI::showHelp
        ;;
esac

## -----------------------------------------------------------------------------
## END
## -----------------------------------------------------------------------------
String::notice "Now is: $(date -R)"
exit 0
