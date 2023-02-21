#!/usr/bin/env bash

# Certificate requested.
hostnames="${hostnames:-}"

cd /opt/certs
/opt/certs/createcerts.sh moodlenet_mock localhost ${hostnames}
cd -

# Install the certificate authority.
cp \
  /opt/certs/ca/ca.pem \
  /usr/local/share/ca-certificates/moodle-docker-ca.crt
update-ca-certificates

# TODO Uncomment when we have a schema to build.
# bin/console doctrine:schema:create --no-interaction

CERTDIR="/opt/certs"
CACERT="${CERTDIR}/ca/ca.pem"
echo "============================================================================"
echo "=== Configuring Certificates"
echo "============================================================================"
echo
echo "If you wish to install the root certificate used to generate for this"
echo "container, then you can should ensure that you have mapped the following"
echo "directory to your local machine:"
echo
echo "    ${CERTDIR}/ca"
echo
echo "============================================================================"
echo "====           You **MUST NOT** the keys to this Certificate            ===="
echo "============================================================================"
echo
echo "You can add this certificate to your root certificate store."
echo
echo "MacOS:"
echo "======"
echo "sudo security add-trusted-cert -d -r trustRoot -k '/Library/Keychains/System.keychain' ${CACERT}"
echo
echo "Linux"
echo "====="
echo "sudo cp ${CERTDIR}/ca/ca.pem /usr/local/share/ca-certificates/moodlenet_mock-ca.crt && sudo update-ca-certificates"
echo "============================================================================"

exec "$@"
