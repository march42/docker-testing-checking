## Running Docker container with hosts TLS certificates

The specifics are for [Ubuntu 22.04 LTS](https://packages.ubuntu.com/jammy/)
and apply not always exactly.

Consider the host has TLS certificates and trusted CA certificates.
See [TLS how-to](https://ubuntu.com/server/docs/how-to/security/obtain-tls-certificates/)
on how to obtain TLS certificates with [let's Encrypt](https://letsencrypt.org/).

Running `certbot renew` will renew certificates, if their about to expire.
Using a hook script we handle updating out container.
`--deploy-hook `

### configuration and scripts

Please asume following

- docker compose project in `/srv/docker-compose`
- private files holding secrets, keys, certificates in `private` subdirectory
- CA certificate in `private/ca.crt`
- TLS certificate in `private/arachne.crt` and key in `private/arachne.key`
- TLS certificate in `private/bia.crt` and key in `private/bia.key`
- services `arachne` and `bia` in `docker-compose.yaml`

I preferably install configuration and scripts in the project directory.
and symlink the hook scripts into the needed directories.

```bash
ln -s /srv/docker-compose/ca-crt-updated-hook.sh /etc/ca-certificates/update.d/docker-compose-ca-crt-update-hook.sh
ln -s /srv/docker-compose/certbot-deploy-hook.sh /etc/letsencrypt/renewal-hooks/deploy/docker-compose-tls-update-hook.sh
```

For certbot, Instead of using the hook script directory
you can explicitly name the script when renewing the certificates.
With `certbot renew --deploy-hook /srv/docker-compose/certbot-deploy-hook.sh`

### renewing certificates

- Running `update-ca-certificates`
- Running `certbot renew`
