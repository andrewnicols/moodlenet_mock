## Building

```
docker build --no-cache --tag moodlenet_mock .
```

## Running

```
docker run -p 80:443 moodlenet_mock
```

## Install the CA Certificate

### MacOS

You can use the following command:

```
sudo security add-trusted-cert -d -r trustRoot -k '/Library/Keychains/System.keychain' ./certs/ca/ca.pem
```

### Linux

sudo cp ./ca/ca.pem /usr/local/share/ca-certificates/moodlenet_mock.crt && sudo update-ca-certificates
