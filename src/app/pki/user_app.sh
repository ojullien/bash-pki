## -----------------------------------------------------------------------------
## Linux Scripts.
## Public Key Infrastructure (PKI) management toolkit.
## Certification level application.
## Issue TLS, email and soft certificates.
##
## @package ojullien\bash\app\pki
## @license MIT <https://github.com/ojullien/bash-pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

PKI::User::showHelp() {
    String::notice "Usage: $(basename "$0") <tls | email | soft> <name> <command>"
    String::notice "\tUser certificate application."
    String::notice "Available Commands:"
    String::notice "\tbundle\t\t\t\tPack the private key and the certificate into a PKCS#12 bundle."
    String::notice "\tbundle-output|output\t\tPrint some info about the PKCS#12 file."
    String::notice "\tcertificate-display|display\tDisplay the contents of certificate file in a human-readable output format."
    String::notice "\tcertificate-purpose|purpose\tCheck the certificate extensions and determines what the certificate can be used for."
    String::notice "\tcertificate-verify|verify\tVerify the certificate."
    String::notice "\tinstall\t\t\t\tRun all the commands."
    String::notice "\thelp\t\t\t\tShow this help."
    String::notice "\tkey-check|check\t\t\tCheck the consistency of the key pair for both public and private components."
    String::notice "\tkey-generate|key\t\tGenerate a private and public key."
    String::notice "\trequest-generate|request|req\tGenerate a new PKCS#10 certificate request from existing key."
    String::notice "\trequest-verify\t\t\tVerifies the signature on the request."
    String::notice "\tsign\t\t\t\tCreate and sign the certificate based on the CSR."
    return 0
}

## -----------------------------------------------------------------------------
## Main CA commands
## -----------------------------------------------------------------------------

PKI::User::main() {

    # Parameters
    if (($# != 3)); then
        PKI::User::showHelp
        return 1
    fi

    # Init
    local sUserType="${1:-""}" sCommand="${3:-""}" sUserName="${2:-""}"
    if [[ -z "${sCommand}" ]] || [[ -z "${sUserName}" ]] || [[ -z "${sUserType}" ]] || [[ ! -v "m_PKI_CA_CONF_V3EXTENTIONS[${sUserType}]" ]]; then
        PKI::User::showHelp
        return 1
    fi

    local sSigningCAName="${m_PKI_CA_NAMES[signing]}"
    local sSigningCAPath="${m_PKI_CA_DIR}/${sSigningCAName}"
    local sSigningCAKeyFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[privatekeys]}/${sSigningCAName}.${m_SSL_FILE_EXTENTIONS[key]}"
    local sSigningCACRTFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sSigningCAName}.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sSigningCASRLFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[databases]}/${sSigningCAName}${m_SSL_FILE_EXTENTIONS[serial]}"
    local sSigningCAChainFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sSigningCAName}-chain.${m_SSL_FILE_EXTENTIONS[certificate]}"

    local sUserConf="${m_PKI_CNF_DIR}/${sUserName}.conf"
    local sUserKeyFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[privatekeys]}/${sUserName}.${m_SSL_FILE_EXTENTIONS[key]}"
    local sUserCSRFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[certificatesigningrequests]}/${sUserName}.${m_SSL_FILE_EXTENTIONS[certificatesigningrequest]}"
    local sUserCRTFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sUserName}.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sUserChainFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sUserName}-chain.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sUserCAP12File="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sUserName}${m_SSL_FILE_EXTENTIONS[p12]}"
    local sUserCAExtention="${m_PKI_CA_CONF_V3EXTENTIONS[${sUserType}]}"
    local sUserCAFriendlyName="${sUserName}"
    local -i iReturn=1

    # Do the job
    case "${sCommand}" in

        bundle)
            # Pack the into a new PKCS#12 bundle.
            MyOpenSSL::createPKCS12bundle "${sUserCAFriendlyName}" "${sUserCRTFile}" "${sUserKeyFile}" "${sUserCAP12File}"
            iReturn=$?
            # Print some info about a PKCS#12 file
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::outputPKCS12Bundle "${sUserCAP12File}"
                iReturn=$?
            fi
            ;;

        bundle-output|output)
            # Print some info about a PKCS#12 file.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::outputPKCS12Bundle "${sUserCAP12File}"
                iReturn=$?
            fi
            ;;

        certificate-display|display)
            # Display the contents of a certificate file in a human-readable output format
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::displayCertificate "${sUserCRTFile}"
                iReturn=$?
            fi
            ;;

        certificate-purpose|purpose)
            # Check the certificate extensions and determines what the certificate can be used for.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::purposeCertificate "${sUserCRTFile}"
                iReturn=$?
            fi
            ;;

        certificate-verify|verify)
            # Verifies certificate chains.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::verifyCertificate "${sSigningCAChainFile}" "${sUserCRTFile}"
                iReturn=$?
            fi
            ;;

        install)
            # Run all
            MyOpenSSL::generateKeypair "${sUserName}" "${sUserKeyFile}"\
                && MyOpenSSL::createRequest "${sUserName}" "${sUserKeyFile}" "${sUserConf}" "${sUserCSRFile}"\
                && MyOpenSSL::signCertificate "${sSigningCACRTFile}" "${sSigningCAKeyFile}" "${sSigningCASRLFile}" "${sUserConf}" "${sUserCAExtention}" "${sUserCSRFile}" "${sUserName}" "${sUserCRTFile}"\
                && MyOpenSSL::createPEMBundle "cert chain" "${sUserCRTFile}" "${sSigningCAChainFile}" "${sUserChainFile}"\
                && MyOpenSSL::createPKCS12bundle "${sUserCAFriendlyName}" "${sUserCRTFile}" "${sUserKeyFile}" "${sUserCAP12File}"
            iReturn=$?
            ;;

        key-check|check)
            # Inspecting the key's metadata
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::checkKey "${sUserKeyFile}"
                iReturn=$?
            fi
            ;;

        key-generate|key)
            # Generate a private and public key.
            MyOpenSSL::generateKeypair "${sUserName}" "${sUserKeyFile}"
            iReturn=$?
            # Inspecting the key's metadata.
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::checkKey "${sUserKeyFile}"
                iReturn=$?
            fi
            ;;

        request-generate|request|req)
            # Generate a new PKCS#10 certificate request from existing key.
            MyOpenSSL::createRequest "${sUserName}" "${sUserKeyFile}" "${sUserConf}" "${sUserCSRFile}"
            iReturn=$?
            # Verifies the signature on the request.
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::verifyRequest "${sUserCSRFile}"
                iReturn=$?
            fi
            ;;

        request-verify)
            # Verifies the signature on the request.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::verifyRequest "${sUserCSRFile}"
                iReturn=$?
            fi
            ;;

        sign)
            # Create the User certificate based on the CSR.
            MyOpenSSL::signCertificate "${sSigningCACRTFile}" "${sSigningCAKeyFile}" "${sSigningCASRLFile}" "${sUserConf}" "${sUserCAExtention}" "${sUserCSRFile}" "${sUserName}" "${sUserCRTFile}"
           iReturn=$?
            # Create the cert chain PEM bundle
            if ((0==iReturn)); then
                MyOpenSSL::createPEMBundle "cert chain" "${sUserCRTFile}" "${sSigningCAChainFile}" "${sUserChainFile}"
                iReturn=$?
            fi
            # Inspecting the certificate's metadata
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::displayCertificate "${sUserCRTFile}"
                MyOpenSSL::purposeCertificate "${sUserCRTFile}"
                MyOpenSSL::verifyCertificate "${sSigningCAChainFile}" "${sUserCRTFile}"
            fi
            ;;

        trace)
            FileSystem::checkFile "\tConf file is:\t\t${sUserConf}" "${sUserConf}"
            FileSystem::checkDir "\tDirectory:\t\t${sSigningCAPath}" "${sSigningCAPath}"
            FileSystem::checkFile "\tKey is:\t\t\t${sUserKeyFile}" "${sUserKeyFile}"
            FileSystem::checkFile "\tCSR is:\t\t\t${sUserCSRFile}" "${sUserCSRFile}"
            FileSystem::checkFile "\tCertificate is:\t\t${sUserCRTFile}" "${sUserCRTFile}"
            FileSystem::checkFile "\tSerial file is:\t\t${sSigningCASRLFile}" "${sSigningCASRLFile}"
            FileSystem::checkFile "\tCombined is:\t\t${sUserChainFile}" "${sUserChainFile}"
            FileSystem::checkFile "\tP12 file is:\t\t${sUserCAP12File}" "${sUserCAP12File}"
            String::notice "\tExtention is:\t\t${sUserCAExtention}"
            String::notice "\tFriendly Name is:\t${sUserCAFriendlyName}"
            iReturn=0
            ;;

        *)
            PKI::User::showHelp
            iReturn=$?
            ;;

    esac

    return ${iReturn}
}
