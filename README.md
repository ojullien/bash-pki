# Bash-PKI

ECC Public Key Infrastructure (PKI) management toolkit.

*Note: I use this script for my own projects, it contains only the features I need.*

## Table of Contents

[Installation](#installation) | [Features](#features) | [Documentation](#documentation) | [Test](#test) | [Contributing](#contributing) | [License](#license)

## Installation

Requires: a Debian/Ubuntu version of linux and a Bash version ~4.4. [bash-sys](https://github.com/ojullien/bash-sys) and openssl installed.

1. [Download a release](https://github.com/ojullien/bash-pki/releases) or clone this repository.
2. Use [scripts/install.sh](scripts/install.sh) to automatically install the application in the /opt/oju/bash project folder.
3. If needed, add `PATH="$PATH:/opt/oju/bash/bin"` to the .profile files.
4. Update the [config.sh](src/app/pki/config.sh) configuration file.
5. Create the openssl configuration files you need from the [samples](src/app/pki/cnf).

## Features

This tool is a wrapper to the openssl commands. It allows you to create a self-signed root certificate, a signing ca certificate and user TLS | EMAIL | SOFT certificates. We use the root CA to issue subordinate signing CAs. We use intermediate signing CA to issue TLS, Email or Software certificates. It generate PKCS#8 keypair using elliptic curves algorithm and uses openssl-req and openssl-x509 commands only.

```bash
Usage: pki.sh [options] <command>

Options:
        -h | --help             Show the help.
        -l | --active-log       log mode. Contents are logged.
        -n | --no-display       display mode. Contents are not displayed.
        -v | --version          Show the version.
        -w | --wait             wait user. Wait for user input between actions.

Available Commands:
        root    Root CA level application.
        signing Intermediate Signing CA level application.
        email   User certificate level application.
        soft    User certificate level application.
        tls     User certificate level application.
```

### Create the Root Certificate

1. Create or update the [root ca openssl configuration file](src/app/pki/cnf/root-ca.sample.conf)
2. Update the [main configuration file](src/app/pki/config.sh)
3. Run the command: `pki.sh root install`

```bash
Usage: pki.sh root <command>
        Root CA application. We use the root CA to issue subordinate signing CAs.

Available Commands:
        bundle                          Pack the root CA private key and the root CA certificate into a PKCS#12 bundle.
        bundle-output|output            Print some info about root CA PKCS#12 file.
        certificate-display|display     Display the contents of root CA certificate file in a human-readable output format.
        certificate-purpose|purpose     Check the root CA certificate extensions and determines what the certificate can be used for.
        certificate-verify|verify       Verify root CA certificate.
        initialize|init                 Create the root CA level repository and database files.
        install                         Run all the commands.
        help                            Show this help.
        key-check|check                 Check the consistency of root CA key pair for both public and private components.
        key-generate|key                Generate a root CA private and root CA public key.
        remove|rm                       Remove all PKI level repositories. Root CA, subordinate signing CAs and all issued certificates.
        request-generate|request|req    Generate a new PKCS#10 certificate request from existing root CA key.
        request-verify                  Verifies the signature on the root CA request.
        selfsign                        Create and self-sign the root CA certificate based on the CSR.
```

### Create the Intermediate Signing Certificate

1. Create or update the [intermediate signing ca openssl configuration file](src/app/pki/cnf/signing-ca.sample.conf)
2. Update the [main configuration file](src/app/pki/config.sh)
3. Run the command: `pki.sh signing install`

```bash
Usage: pki.sh signing <command>
        Signing CA application. We use intermediate signing CA to issue TLS, Email or Software certificates.

Available Commands:
        bundle                          Pack the signing CA private key and the signing CA certificate into a PKCS#12 bundle.
        bundle-output|output            Print some info about signing CA PKCS#12 file.
        certificate-display|display     Display the contents of signing CA certificate file in a human-readable output format.
        certificate-purpose|purpose     Check the signing CA certificate extensions and determines what the certificate can be used for.
        certificate-verify|verify       Verify signing CA certificate.
        initialize|init                 Create the signing CA level repository and database files.
        install                         Run all the commands.
        help                            Show this help.
        key-check|check                 Check the consistency of signing CA key pair for both public and private components.
        key-generate|key                Generate a private and signing CA public key.
        remove|rm                       Remove the signing level repositories and issued certificates.
        request-generate|request|req    Generate a new PKCS#10 certificate request from existing signing CA key.
        request-verify                  Verifies the signature on the signing CA request.
        sign                            Create and sign the signing CA certificate based on the CSR.
```

### Create the user Certificate

1. Create the user configuration file using [the sample](src/app/pki/cnf/tls.sample.conf) and name it domain.tld.conf for example.
2. Update the [main configuration file](src/app/pki/config.sh)
3. Run the command: `pki.sh tls domain.tld install`.

```bash
Usage: pki.sh <tls | email | soft> <name> <command>
        User certificate application.

name:
        name of the configuration file located in cnf folder. Without the path.

Available Commands:
        bundle                          Pack the private key and the certificate into a PKCS#12 bundle.
        bundle-output|output            Print some info about the PKCS#12 file.
        certificate-display|display     Display the contents of certificate file in a human-readable output format.
        certificate-purpose|purpose     Check the certificate extensions and determines what the certificate can be used for.
        certificate-verify|verify       Verify the certificate.
        install                         Run all the commands.
        help                            Show this help.
        key-check|check                 Check the consistency of the key pair for both public and private components.
        key-generate|key                Generate a private and public key.
        request-generate|request|req    Generate a new PKCS#10 certificate request from existing key.
        request-verify                  Verifies the signature on the request.
        sign                            Create and sign the certificate based on the CSR.
```

## Documentation

- [OpenSSL PKI Tutorial](https://pki-tutorial.readthedocs.io/en/latest/index.html)
- [Guide for building an ECC pki](https://tools.ietf.org/html/draft-moskowitz-ecdsa-pki-05)
- [Roll Your Own Network](https://roll.urown.net/ca/index.html)

## Test

As this tool is just a wrapper to openssl commands, I didn't write any line of 'unit test' code. Sorry.

## Contributing

Thanks you for taking the time to contribute. Please fork the repository and make changes as you'd like.

As I use these scripts for my own projects, they contain only the features I need. But If you have any ideas, just open an [issue](https://github.com/ojullien/bash-pki/issues/new/choose) and tell me what you think. Pull requests are also warmly welcome.

If you encounter any **bugs**, please open an [issue](https://github.com/ojullien/bash-pki/issues/new/choose).

Be sure to include a title and clear description,as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

## License

This project is open-source and is licensed under the [MIT License](LICENSE).
