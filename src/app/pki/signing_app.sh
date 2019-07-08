## -----------------------------------------------------------------------------
## Linux Scripts.
## Public Key Infrastructure (PKI) management toolkit.
## Intermediate signing level application. We use intermediate signing CA to issue
## TLS certificates.
##
## @package ojullien\bash\app\pki
## @license MIT <https://github.com/ojullien/bash-pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

PKI::Signing::showHelp() {
    String::notice "Usage: $(basename "$0") signing <command>"
    String::notice "\tSigning CA application. We use intermediate signing CA to issue TLS, Email or Software certificates."
    String::notice "Available Commands:"
    String::notice "\tbundle\t\t\t\tPack the signing CA private key and the signing CA certificate into a PKCS#12 bundle."
    String::notice "\tbundle-output|output\t\tPrint some info about signing CA PKCS#12 file."
    String::notice "\tcertificate-display|display\tDisplay the contents of signing CA certificate file in a human-readable output format."
    String::notice "\tcertificate-purpose|purpose\tCheck the signing CA certificate extensions and determines what the certificate can be used for."
    String::notice "\tcertificate-verify|verify\tVerify signing CA certificate."
    String::notice "\tinitialize|init\t\t\tCreate the signing CA level repository and database files."
    String::notice "\tinstall\t\t\t\tRun all the commands."
    String::notice "\thelp\t\t\t\tShow this help."
    String::notice "\tkey-check|check\t\t\tCheck the consistency of signing CA key pair for both public and private components."
    String::notice "\tkey-generate|key\t\tGenerate a private and signing CA public key."
    String::notice "\tremove|rm\t\t\tRemove the signing level repositories and issued certificates."
    String::notice "\trequest-generate|request|req\tGenerate a new PKCS#10 certificate request from existing signing CA key."
    String::notice "\trequest-verify\t\t\tVerifies the signature on the signing CA request."
    String::notice "\tsign\t\t\t\tCreate and sign the signing CA certificate based on the CSR."
    return 0
}

## -----------------------------------------------------------------------------
## Main CA commands
## -----------------------------------------------------------------------------

PKI::Signing::main() {

    # Parameters
    if (($# != 1)); then
        PKI::Signing::showHelp
        return 1
    fi

    # Init
    local sRootCAName="${m_PKI_CA_NAMES[root]}"
    local sRootCAPath="${m_PKI_CA_DIR}/${sRootCAName}"
    local sRootCAKeyFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[privatekeys]}/${sRootCAName}.${m_SSL_FILE_EXTENTIONS[key]}"
    local sRootCACRTFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sRootCAName}.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sRootCASRLFile="${sRootCAPath}/${m_PKI_CA_DIRNAMES[databases]}/${sRootCAName}${m_SSL_FILE_EXTENTIONS[serial]}"
    local sRootCAFriendlyName="${m_PKI_CA_FRIENDLYNAMES[root]}"

    local sSigningCAName="${m_PKI_CA_NAMES[signing]}"
    local sSigningCAConf="${m_PKI_CNF_DIR}/${m_PKI_CA_CONF_FILENAMES[signing]}"
    local sSigningCAPath="${m_PKI_CA_DIR}/${sSigningCAName}"
    local sSigningCAKeyFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[privatekeys]}/${sSigningCAName}.${m_SSL_FILE_EXTENTIONS[key]}"
    local sSigningCACSRFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[certificatesigningrequests]}/${sSigningCAName}.${m_SSL_FILE_EXTENTIONS[certificatesigningrequest]}"
    local sSigningCACRTFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sSigningCAName}.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sSigningCASRLFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[databases]}/${sSigningCAName}${m_SSL_FILE_EXTENTIONS[serial]}"
    local sSigningCAChainFile="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sSigningCAName}-chain.${m_SSL_FILE_EXTENTIONS[certificate]}"
    local sSigningCAP12File="${sSigningCAPath}/${m_PKI_CA_DIRNAMES[signedcertificates]}/${sSigningCAName}${m_SSL_FILE_EXTENTIONS[p12]}"
    local sSigningCAExtention="${m_PKI_CA_CONF_V3EXTENTIONS[signing]}"
    local sSigningCAFriendlyName="${m_PKI_CA_FRIENDLYNAMES[signing]}"
    local -i iReturn=1

    # Do the job
    case "$1" in

        bundle)
            # Pack the Signing CA private key, the Signing CA certificate and the Root CA PKCS#12 bundle into a new PKCS#12 bundle.
            MyOpenSSL::createPKCS12Chainbundle "${sSigningCAFriendlyName}" "${sSigningCACRTFile}" "${sSigningCAKeyFile}" "${sRootCAFriendlyName}" "${sRootCACRTFile}" "${sSigningCAP12File}"
            iReturn=$?
            # Print some info about a PKCS#12 file
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::outputPKCS12Bundle "${sSigningCAP12File}"
                iReturn=$?
            fi
            ;;

        bundle-output|output)
            # Print some info about a PKCS#12 file.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::outputPKCS12Bundle "${sSigningCAP12File}"
                iReturn=$?
            fi
            ;;

        certificate-display|display)
            # Display the contents of a certificate file in a human-readable output format
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::displayCertificate "${sSigningCACRTFile}"
                iReturn=$?
            fi
            ;;

        certificate-purpose|purpose)
            # Check the certificate extensions and determines what the certificate can be used for.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::purposeCertificate "${sSigningCACRTFile}"
                iReturn=$?
            fi
            ;;

        certificate-verify|verify)
            # Verifies certificate chains.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::verifyCertificate "${sRootCACRTFile}" "${sSigningCACRTFile}"
                iReturn=$?
            fi
            ;;

        initialize|init)
            # Create the CA repository for the given CA (see app/pki/config.sh !!!m_PKI_CA_SIGNING!!! constant )
            PKI::createRepository "${sSigningCAPath}" "${sSigningCAName}"
            iReturn=$?
            ;;

        install)
            # Run all
            PKI::remove "${sSigningCAPath}"
            PKI::createRepository "${sSigningCAPath}" "${sSigningCAName}"\
                && MyOpenSSL::generateKeypair "${sSigningCAName}" "${sSigningCAKeyFile}"\
                && MyOpenSSL::createRequest "${sSigningCAName}" "${sSigningCAKeyFile}" "${sSigningCAConf}" "${sSigningCACSRFile}"\
                && MyOpenSSL::signCertificate "${sRootCACRTFile}" "${sRootCAKeyFile}" "${sRootCASRLFile}" "${sSigningCAConf}" "${sSigningCAExtention}" "${sSigningCACSRFile}" "${sSigningCAName}" "${sSigningCACRTFile}"\
                && MyOpenSSL::createPEMBundle "cert chain" "${sSigningCACRTFile}" "${sRootCACRTFile}" "${sSigningCAChainFile}"\
                && MyOpenSSL::createPKCS12Chainbundle "${sSigningCAFriendlyName}" "${sSigningCACRTFile}" "${sSigningCAKeyFile}" "${sRootCAFriendlyName}" "${sRootCACRTFile}" "${sSigningCAP12File}"
            iReturn=$?
            ;;

        key-check|check)
            # Inspecting the key's metadata
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::checkKey "${sSigningCAKeyFile}"
                iReturn=$?
            fi
            ;;

        key-generate|key)
            # Generate a private and public key.
            MyOpenSSL::generateKeypair "${sSigningCAName}" "${sSigningCAKeyFile}"
            iReturn=$?
            # Inspecting the key's metadata.
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::checkKey "${sSigningCAKeyFile}"
                iReturn=$?
            fi
            ;;

        remove|rm) # Remove the PKI signing CA level repository.
            PKI::remove "${sSigningCAPath}"
            iReturn=$?
            ;;

        request-generate|request|req)
            # Generate a new PKCS#10 certificate request from existing key.
            MyOpenSSL::createRequest "${sSigningCAName}" "${sSigningCAKeyFile}" "${sSigningCAConf}" "${sSigningCACSRFile}"
            iReturn=$?
            # Verifies the signature on the request.
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::verifyRequest "${sSigningCACSRFile}"
                iReturn=$?
            fi
            ;;

        request-verify)
            # Verifies the signature on the request.
            if ((m_OPTION_DISPLAY)); then
                MyOpenSSL::verifyRequest "${sSigningCACSRFile}"
                iReturn=$?
            fi
            ;;

        sign)
            # Create the Signing CA certificate based on the CSR.
            MyOpenSSL::signCertificate "${sRootCACRTFile}" "${sRootCAKeyFile}" "${sRootCASRLFile}" "${sSigningCAConf}" "${sSigningCAExtention}" "${sSigningCACSRFile}" "${sSigningCAName}" "${sSigningCACRTFile}"
            iReturn=$?
            # Create the cert chain PEM bundle
            if ((0==iReturn)); then
                MyOpenSSL::createPEMBundle "cert chain" "${sSigningCACRTFile}" "${sRootCACRTFile}" "${sSigningCAChainFile}"
                iReturn=$?
            fi
            # Inspecting the certificate's metadata
            if ((m_OPTION_DISPLAY)) && ((0==iReturn)); then
                MyOpenSSL::displayCertificate "${sSigningCACRTFile}"
                MyOpenSSL::purposeCertificate "${sSigningCACRTFile}"
                MyOpenSSL::verifyCertificate "${sRootCACRTFile}" "${sSigningCACRTFile}"
            fi
            ;;

        trace)
            FileSystem::checkFile "\tConf file is:\t\t${sSigningCAConf}" "${sSigningCAConf}"
            FileSystem::checkDir "\tDirectory:\t\t${sSigningCAPath}" "${sSigningCAPath}"
            FileSystem::checkFile "\tKey is:\t\t\t${sSigningCAKeyFile}" "${sSigningCAKeyFile}"
            FileSystem::checkFile "\tCSR is:\t\t\t${sSigningCACSRFile}" "${sSigningCACSRFile}"
            FileSystem::checkFile "\tCertificate is:\t\t${sSigningCACRTFile}" "${sSigningCACRTFile}"
            FileSystem::checkFile "\tSerial file is:\t\t${sSigningCASRLFile}" "${sSigningCASRLFile}"
            FileSystem::checkFile "\tCombined is:\t\t${sSigningCAChainFile}" "${sSigningCAChainFile}"
            FileSystem::checkFile "\tP12 file is:\t\t${sSigningCAP12File}" "${sSigningCAP12File}"
            String::notice "\tExtention is:\t\t${sSigningCAExtention}"
            String::notice "\tFriendly Name is:\t${sSigningCAFriendlyName}"
            iReturn=0
            ;;

        *)
            PKI::Signing::showHelp
            iReturn=$?
            ;;
    esac

    return ${iReturn}
}
