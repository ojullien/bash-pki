## -----------------------------------------------------------------------------
## Linux Scripts.
## Public Key Infrastructure (PKI) management toolkit.
## Root CA level application. We use the root CA to issue subordinate signing CAs.
##
## @package ojullien\bash\app\pki
## @license MIT <https://github.com/ojullien/bash-pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

PKI::Root::showHelp() {
    String::notice "Usage: $(basename "$0") root <command>"
    String::notice "\tRoot CA application. We use the root CA to issue subordinate signing CAs."
    String::notice "Available Commands:"
    String::notice "\tbundle\t\t\t\tPack the root CA private key and the root CA certificate into a PKCS#12 bundle."
    String::notice "\tbundle-output|output\t\tPrint some info about root CA PKCS#12 file."
    String::notice "\tcertificate-display|display\tDisplay the contents of root CA certificate file in a human-readable output format."
    String::notice "\tcertificate-purpose|purpose\tCheck the root CA certificate extensions and determines what the certificate can be used for."
    String::notice "\tcertificate-verify|verify\tVerify root CA certificate."
    String::notice "\tinitialize|init\t\t\tCreate the root CA level repository and database files."
    String::notice "\tinstall\t\t\t\tRun all the commands."
    String::notice "\thelp\t\t\t\tShow this help."
    String::notice "\tkey-check|check\t\t\tCheck the consistency of root CA key pair for both public and private components."
    String::notice "\tkey-generate|key\t\tGenerate a root CA private and root CA public key."
    String::notice "\tremove|rm\t\t\tRemove all PKI level repositories. Root CA, subordinate signing CAs and all issued certificates."
    String::notice "\trequest-generate|request|req\tGenerate a new PKCS#10 certificate request from existing root CA key."
    String::notice "\trequest-verify\t\t\tVerifies the signature on the root CA request."
    String::notice "\tselfsign\t\t\tCreate and self-sign the root CA certificate based on the CSR."
    return 0
}

## -----------------------------------------------------------------------------
## Main CA commands
## -----------------------------------------------------------------------------

PKI::Root::main() {

    # Parameters
    if (($# != 1)); then
        PKI::Root::showHelp
        return 1
    fi

    # Init
    local sRootCAName="${m_PKI_CA_NAMES[root]}"
    local sRootCAConf="${m_PKI_CNF_DIR}/${m_PKI_CA_CONF_FILENAMES[root]}"
    local sRootCAPath="${m_PKI_CA_DIR}/${sRootCAName}"
    local sRootCAKeyFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[privatekeys]}/${sRootCAName}.${m_SSL_FILE_EXTENTIONS[key]}"
    local sRootCACSRFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[certificatesigningrequests]}/${sRootCAName}.${m_SSL_FILE_EXTENTIONS[certificatesigningrequest]}"
    local sRootCACRTFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sRootCAName}.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sRootCASRLFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[databases]}/${sRootCAName}${m_SSL_FILE_EXTENTIONS[serial]}"
    local sRootCAKeyCRTCombinedFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[privatekeys]}/${sRootCAName}.key${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sRootCAP12File="${sRootCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sRootCAName}${m_SSL_FILE_EXTENTIONS[p12]}"
    local sRootCAExtention="${m_PKI_CA_CONF_V3EXTENTIONS[root]}"
    local sRootCAFriendlyName="${m_PKI_CA_FRIENDLYNAMES[root]}"
    local -i iReturn=1

    # Do the job
    case "$1" in

        bundle)
            # Pack the private key and the certificate into a PKCS#12 bundle
            MyOpenSSL::createPKCS12bundle "${sRootCAFriendlyName}" "${sRootCACRTFile}" "${sRootCAKeyFile}" "${sRootCAP12File}"
            iReturn=$?
            # Print some info about a PKCS#12 file
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::outputPKCS12Bundle "${sRootCAP12File}"
                iReturn=$?
            fi
            ;;

        bundle-output|output)
            # Print some info about a PKCS#12 file.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::outputPKCS12Bundle "${sRootCAP12File}"
                iReturn=$?
            fi
            ;;

        certificate-display|display)
            # Display the contents of a certificate file in a human-readable output format
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::displayCertificate "${sRootCACRTFile}"
                iReturn=$?
            fi
            ;;

        certificate-purpose|purpose)
            # Check the certificate extensions and determines what the certificate can be used for.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::purposeCertificate "${sRootCACRTFile}"
                iReturn=$?
            fi
            ;;

        certificate-verify|verify)
            # Verifies certificate chains.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::verifyCertificate "${sRootCACRTFile}" "${sRootCACRTFile}"
                iReturn=$?
            fi
            ;;

        initialize|init)
            # Create the root CA repository
            PKI::createRepository "${sRootCAPath}" "${sRootCAName}"
            iReturn=$?
            ;;

        install)
            # Run all
            PKI::remove "${m_PKI_CA_DIR}"\
                && PKI::createRepository "${sRootCAPath}" "${sRootCAName}"\
                && MyOpenSSL::generateKeypair "${sRootCAName}" "${sRootCAKeyFile}"\
                && MyOpenSSL::createRequest "${sRootCAName}" "${sRootCAKeyFile}" "${sRootCAConf}" "${sRootCACSRFile}"\
                && MyOpenSSL::createSelfSignedCertificate "${sRootCACSRFile}" "${sRootCAKeyFile}" "${sRootCACRTFile}" "${sRootCAConf}" "${sRootCAExtention}" "${sRootCAName}"\
                && MyOpenSSL::createPEMBundle "key + cert" "${sRootCAKeyFile}" "${sRootCACRTFile}" "${sRootCAKeyCRTCombinedFile}"\
                && MyOpenSSL::createPKCS12bundle "${sRootCAFriendlyName}" "${sRootCACRTFile}" "${sRootCAKeyFile}" "${sRootCAP12File}"
            iReturn=$?
            ;;

        key-check|check)
            # Inspecting the key's metadata
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::checkKey "${sRootCAKeyFile}"
                iReturn=$?
            fi
            ;;

        key-generate|key)
            # Generate a private and public key.
            MyOpenSSL::generateKeypair "${sRootCAName}" "${sRootCAKeyFile}"
            iReturn=$?
            # Inspecting the key's metadata.
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::checkKey "${sRootCAKeyFile}"
                iReturn=$?
            fi
            ;;

        remove|rm)
            # Remove all PKI level repositories. Root CA, subordinate signing CAs and all issued certificates.
            PKI::remove "${m_PKI_CA_DIR}"
            iReturn=$?
            ;;

        request-generate|request|req)
            # Generate a new PKCS#10 certificate request from existing key.
            MyOpenSSL::createRequest "${sRootCAName}" "${sRootCAKeyFile}" "${sRootCAConf}" "${sRootCACSRFile}"
            iReturn=$?
            # Verifies the signature on the request.
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::verifyRequest "${sRootCACSRFile}"
                iReturn=$?
            fi
            ;;

        request-verify)
            # Verifies the signature on the request.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::verifyRequest "${sRootCACSRFile}"
                iReturn=$?
            fi
            ;;

        selfsign|sign)
            # Create and self-sign the root CA certificate root based on the CSR.
            MyOpenSSL::createSelfSignedCertificate "${sRootCACSRFile}" "${sRootCAKeyFile}" "${sRootCACRTFile}" "${sRootCAConf}" "${sRootCAExtention}" "${sRootCAName}"
            iReturn=$?
            # Create the key + cert PEM bundle
            if ((0==iReturn)); then
                MyOpenSSL::createPEMBundle "key + cert" "${sRootCAKeyFile}" "${sRootCACRTFile}" "${sRootCAKeyCRTCombinedFile}"
                iReturn=$?
            fi
            # Inspecting the certificate's metadata
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::displayCertificate "${sRootCACRTFile}"
                MyOpenSSL::purposeCertificate "${sRootCACRTFile}"
                MyOpenSSL::verifyCertificate "${sRootCACRTFile}" "${sRootCACRTFile}"
            fi
            ;;

        trace)
            FileSystem::checkFile "\tConf file is:\t\t${sRootCAConf}" "${sRootCAConf}"
            FileSystem::checkDir "\tDirectory:\t\t${sRootCAPath}" "${sRootCAPath}"
            FileSystem::checkFile "\tKey is:\t\t\t${sRootCAKeyFile}" "${sRootCAKeyFile}"
            FileSystem::checkFile "\tCSR is:\t\t\t${sRootCACSRFile}" "${sRootCACSRFile}"
            FileSystem::checkFile "\tCertificate is:\t\t${sRootCACRTFile}" "${sRootCACRTFile}"
            FileSystem::checkFile "\tSerial file is:\t\t${sRootCASRLFile}" "${sRootCASRLFile}"
            FileSystem::checkFile "\tCombined is:\t\t${sRootCAKeyCRTCombinedFile}" "${sRootCAKeyCRTCombinedFile}"
            FileSystem::checkFile "\tP12 file is:\t\t${sRootCAP12File}" "${sRootCAP12File}"
            String::notice "\tExtention is:\t\t${sRootCAExtention}"
            String::notice "\tFriendly Name is:\t${sRootCAFriendlyName}"
            iReturn=0
            ;;

        *)
            PKI::Root::showHelp
            iReturn=$?
            ;;
    esac

    return ${iReturn}
}
