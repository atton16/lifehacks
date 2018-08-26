# letsencrypt-scripts
The Collection of Let's Encrypt Scripts

#### Obtaining SSL Certification

1. DNS Challenge w/ Cloudflare
   
   See `dns-cloudflare` folder.
   
   Please note that `dns-cloudflare/cloudflare.ini` is best stored with permission `600` or `u+rw,u-x,go-rwx`.

   To do so, simply execute the command `chmod 600 dns-cloudflare/cloudflare.ini`.

#### Renew SSL Certification

1. Execute (with root access)

   ```
   # crontab -e
   ```

   or
   
   ```
   $ sudo crontab -e
   ```

2. Then place this line in the file (CentOS)

   ```
   15 3 * * * certbot renew --quiet --deploy-hook "<your_server_restart_script>"
   ```

   Example for <your_server_restart_script>

   1. NGINX (Debian/CentOS) `systemctl reload nginx`

   2. NGINX (Docker) `docker exec -it nginx-container nginx -s reload`

   3. Apache (Bitnami, Ubuntu) `/opt/bitnami/ctlscript.sh restart apache`

   Full example

   ```
   15 3 * * * certbot renew --quiet --deploy-hook "docker exec -it nginx-container nginx -s reload"
   ```

#### Appendix A: Generating Diffie Hellman Parameters

Simply execute the following command

```
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

