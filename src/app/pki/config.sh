## -----------------------------------------------------------------------------
## Linux Scripts.
## Public Key Infrastructure (PKI) management toolkit.
## Configuration file.
##
## @package ojullien\bash\app\pki
## @license MIT <https://github.com/ojullien/bash-pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

# Remove these 3 lines once you have configured this file
echo "The 'app/pki/config.sh' file is not configured !!!"
String::error "The 'app/pki/config.sh' file is not configured !!!"
exit 3

## -----------------------------------------------------------------------------
## Main folders and files
## -----------------------------------------------------------------------------
readonly m_SSL_DIR="/etc/ssl" # you may change this!
readonly m_PKI_CNF_DIR="${m_DIR_APP}/pki/cnf" # you may change this!

readonly m_PKI_CA_DIR="${m_SSL_DIR}/pki20190701"
readonly -A m_PKI_CA_DIRNAMES=( [privatekeys]="private" [databases]="db" [signedcertificates]="newcerts" [certificatesigningrequests]="csr");

readonly -A m_SSL_FILE_EXTENTIONS=( [passwd]=".pass" [key]="key.pem" [certificate]="crt.pem" [certificatesigningrequest]="csr.pem" [serial]=".srl" [p12]=".p12");

## -----------------------------------------------------------------------------
## Main names
## -----------------------------------------------------------------------------

readonly -A m_PKI_CA_NAMES=( [root]="root-ca" [signing]="signing-ca" ); # you may change this
readonly -A m_PKI_CA_CONF_FILENAMES=( [root]="root-ca.sample.conf" [signing]="signing-ca.sample.conf" ); # you may change this
readonly -A m_PKI_CA_FRIENDLYNAMES=( [root]="Buster Root Certification Authority" [signing]="Buster Intermediate Signing Certification Authority" ); # you may change this
readonly -A m_PKI_CA_CONF_V3EXTENTIONS=( [root]="root_ca_ext" [signing]="signing_ca_ext" [tls]="server_ext" [email]="email_ext" [soft]="codesign_ext" );
