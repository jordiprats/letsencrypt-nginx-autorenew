# letsencrypt-nginx-autorenew

certificate autorenew for nginx

## configuration

/etc/ejemplo.conf

* **rsa-key-size**
* **email**
* **domains**
* **webroot-path**

for example:

```
rsa-key-size = 4096
email = ejemplo@systemadmin.es
domains = ejemplo.systemadmin.es
webroot-path = /usr/share/nginx/html
```

script execution example:

```
# /usr/local/bin/renew.cert.sh /etc/ejemplo.conf
certificate up to date, remainig days: 89
```
