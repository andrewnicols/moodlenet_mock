#!/usr/bin/env bash

# Install the certificate authority.
cp \
  /opt/certs/ca/ca.pem \
  /usr/local/share/ca-certificates/moodle-docker-ca.crt
update-ca-certificates

# Certificate requested.
# Regenerate the standard certificate.

bin/console doctrine:schema:create --no-interaction

exec "$@"
