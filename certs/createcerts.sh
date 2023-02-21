#!/bin/bash

CERTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


CACONF="${CERTDIR}/openssl.cnf"
CAKEY="${CERTDIR}/ca/ca.key"
CACERT="${CERTDIR}/ca/ca.pem"

mkdir -p "${CERTDIR}/ca"
mkdir -p "${CERTDIR}/certs"

if [ -f "$CAKEY" ] && [ -f "${CACERT}" ]; then
    echo "Using existing CA private key"
else
    # Generate the private key for the CA:
    echo "Generating the key and certificate for the CA server"

    # Generate the key and certificate for the CA.
    cat <<EOF | openssl req -config ${CACONF} -nodes -new -x509  -keyout "${CAKEY}" -out "${CACERT}"
AU
Western Australia
Perth
Moodle Pty Ltd
Moodle LMS


EOF

    echo "Generated an OpenSSL Certificate Authority"
    touch "${CERTDIR}/ca/index.txt"
    echo '01' > "${CERTDIR}/ca/serial.txt"
    echo
    echo "============================================================================"
    echo "====            You **MUST NOT** share your Certificate keys            ===="
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
fi

if [ "$#" -lt 1 ]
then
  echo "Usage: Must supply at least one hostname."
  exit 1
fi

# The first hostname is canonical.
DOMAIN=$1

HOSTKEY="${CERTDIR}/certs/${DOMAIN}.key"
HOSTCSR="${CERTDIR}/certs/${DOMAIN}.csr"
HOSTCRT="${CERTDIR}/certs/${DOMAIN}.crt"
HOSTEXT="${CERTDIR}/certs/${DOMAIN}.ext"
HOSTP12="${CERTDIR}/certs/${DOMAIN}.p12"

# Create a private key for the dev site:
echo "Generating a private key for the $DOMAIN dev site"
echo
openssl genrsa -out "${HOSTKEY}" 2048

echo "Generating a CSR for $DOMAIN"
cat <<EOF | openssl req -nodes -new -key "${HOSTKEY}" -out "${HOSTCSR}"
AU
Western Australia
Perth
Moodle Pty Ltd
Moodle LMS


EOF
echo

DNSCOUNT=1
for var in "$@"
do
    DNS=$(cat <<-EOF
${DNS}
DNS.${DNSCOUNT} = ${var}
EOF
)
    DNSCOUNT=$((DNSCOUNT + 1))
done

cat > "${HOSTEXT}" << EOF
[ req ]
default_bits       = 2048
default_keyfile    = ${HOSTKEY}
distinguished_name = server_distinguished_name
req_extensions     = server_req_extensions
string_mask        = utf8only

[ server_distinguished_name ]

countryName         = Country Name (2 letter code)
countryName_default = AU

stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = Western Australia

localityName                = Locality Name (eg, city)
localityName_default        = Perth

organizationName            = Organization Name (eg, company)
organizationName_default    = Moodle Pty Ltd

organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = Moodle LMS

commonName         = Common Name (e.g. server FQDN or YOUR name)
commonName_default = ${DOMAIN}

emailAddress         = Email Address
emailAddress_default = moodle@example.com

[ server_req_extensions ]
subjectKeyIdentifier    = hash
basicConstraints        = CA:FALSE
keyUsage                = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName          = @alternate_names
[ alternate_names ]
$DNS
EOF

#Next run the command to create the certificate: using our CSR, the CA private key, the CA certificate, and the config file:
echo "Generating a certificate for $DOMAIN"
cat <<EOF | openssl req -config "${HOSTEXT}" -newkey rsa:2048 -sha256 -nodes -out "${HOSTCSR}" -outform PEM
AU
Western Australia
Perth
Moodle Pty Ltd
Moodle LMS


EOF
echo

echo "Signing the request"
echo openssl ca -batch -config "${CACONF}" -policy signing_policy -extensions signing_req -out "${HOSTCRT}" -infiles "${HOSTCSR}"
openssl ca -batch -config "${CACONF}" -policy signing_policy -extensions signing_req -out "${HOSTCRT}" -infiles "${HOSTCSR}"

echo "Generating pkcs12 Keystore"
openssl pkcs12 \
  -export \
  -inkey "${HOSTKEY}" \
  -in "${HOSTCRT}" \
  -name "${DOMAIN}" \
  -out "${HOSTP12}" \
  -passout pass:
