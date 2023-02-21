# Mock server

This is an example mock server for MoodleNet.

This server will build its own SSL Certificate Authority, and create a signed certificate for it.

The default configuration will generate a certificate with the names:
- `moodlenet_mock`
- `localhost`

You can specify additional hostnames for the certificate using the `hostnames` environment variable.

If you need to, you can import the root certificate into your local machine. We recommend sharing the /opt/certs/ca directory with your local machine to do this.

## Running

```
docker run \
    -p 443:80 \
    -v "${HOME}/.config/localca":/opt/certs/ca \
    moodlenet_mock
```

### Adding additional hostnames

You can specify additional hostnames to the certificate using the `hostnames` environment variable:

```
docker run \
    -p 443:80 \
    -e hostnames="some other hostnames here" \
    -v "${HOME}/.config/localca":/opt/certs/ca \
    moodlenet_mock
```

This uses Subject Alternative Names feature of X509 certificates, and supports multiple space-separated hostnames.

## Install the CA Certificate

### MacOS

You can use the following command:

```
sudo security add-trusted-cert -d -r trustRoot -k '/Library/Keychains/System.keychain' ./certs/ca/ca.pem
```

### Linux

sudo cp ./ca/ca.pem /usr/local/share/ca-certificates/moodlenet_mock.crt && sudo update-ca-certificates

## Building

```
docker build --no-cache --tag moodlenet_mock .
```

