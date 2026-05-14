# Local AI with Vulkan support Community Container for Nextcloud All-In-One

This container is used in the [Nextcloud All-In-One](https://github.com/nextcloud/all-in-one/tree/main/community-containers/local-ai) AI backend for Nextcloud Assistant. It works with the [Caddy community container](https://github.com/nextcloud/all-in-one/tree/main/community-containers/caddy) as a reverse proxy.

## Features

Compared to the default LocalAI container, this container provides:

- Automatic configuration of Nextcloud Assistant.
- Hardware acceleration support with Vulkan.
- Easy access to the local AI web interface.

## Getting Started

### Prerequisites

You need:

- A Nextcloud instance running on a server with x86_64 architecture.
- At least 7GB of available storage space.
- Ensure that port `10078` is not used by another program (use `sudo netstat -tulpn` to list all used ports).
- Deploy the [Caddy community container](https://github.com/nextcloud/all-in-one/tree/main/community-containers/caddy) as a reverse proxy. (Other solutions are possible, see: [Use Your Own Reverse Proxy](#use-your-own-reverse-proxy)).

For hardware acceleration (optional but recommended), you need:

- A GPU compatible with Vulkan. Run `vulkaninfo` in the terminal to check if it is enabled.
- Enable [DRI device](https://github.com/nextcloud/all-in-one/tree/main#with-open-source-drivers-mesa-for-amd-intel-and-new-drivers-nouveau-for-nvidia) in AIO. Add `--env NEXTCLOUD_ENABLE_DRI_DEVICE=true` to the container.

### Installation

See [how to use community containers](https://github.com/nextcloud/all-in-one/tree/main/community-containers#how-to-use-this).

After installation on Nextcloud, go to `https://ai.$NC_DOMAIN` and log in with:

- **API key**: Retrieve the password from the AIO interface

From the Local AI web interface, you can download and manage models. By default, no models are installed, so you need to download them manually. See [Recommended Models](#recommended-models) below.

After downloading the models, configure the Local AI server in Nextcloud:
1. Go to `https://$NC_DOMAIN/settings/admin/ai`
2. Set the Local AI server URL to `http://nextcloud-aio-local-ai:10078`
3. Setup API key authentication with the API key from above.
4. Configure the models you want to use in the Nextcloud Assistant settings.

#### Recommended Models

| Usage               | Model            |
|---------------------|------------------|
| Text generation     | Llama 3          |
| Image generation    | Stable Diffusion |
| Audio transcription | Whisper          |

Feedback and suggestions are welcome!

## Use Your Own Reverse Proxy

Redirect HTTPS (or HTTP) traffic from `ai.$NC_DOMAIN` (or another subdomain) to port `10078` of the `nextcloud-aio-local-ai` container over HTTP.

Example with `Caddyfile` syntax:

```caddyfile
https://ai.{$NC_DOMAIN}:443 {
    reverse_proxy http://{$LOCAL_AI_HOSTNAME}:10078
}
```

Example with `Apache` syntax:

```
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        # Enable h2, h2c and http1.1
        Protocols h2 h2c http/1.1
        ServerName ai.$NC_DOMAIN

        # Apache (.htaccess)
        Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains" env=HTTPS

        # Ensure you set the needed mods to fix the redirection to using HTTPS instead of the out of the box HTTP
        # sudo a2enmod substitute proxy_html
        ProxyHTMLEnable On
        ProxyHTMLExtended On
        # replace "http://" to "https://"
        AddOutputFilterByType SUBSTITUTE text/xml text/html text/plain
        Substitute "s|http://|https://|i"
        ProxyHTMLURLMap ^http:\/\/(.*) https://$1 R

        # Optional lock down to local network users
        # IF the remote address is NOT 192.168.1.X (a specific IP)
        RewriteCond %{REMOTE_ADDR} !^192\.168\.1\.[0-9]+$
        # THEN apply the following RewriteRule:
        # If the request is for the / area, block it (Forbidden)
        RewriteRule ^/ - [F,L]

        LogLevel alert
        # Optional higher level of alerts
        #LogLevel alert ssl:alert http2:alert proxy_html:trace8 substitute:trace8 xml2enc:trace2

        DocumentRoot "/var/www/ai.$NC_DOMAIN"
        <Directory "/var/www/ai.$NC_DOMAIN">
            Options None
            Allow from All
            Require all granted
        </Directory>

        RewriteEngine on
        RewriteCond %{HTTP:Upgrade} =websocket [NC]
        RewriteRule /(.*)           ws://$LOCAL_AI_HOSTNAME:10078/$1 [P,L]
        RewriteCond %{HTTP:Upgrade} !=websocket [NC]
        RewriteRule /(.*)           http://$LOCAL_AI_HOSTNAME:10078/$1 [P,L]

        # Reverse proxy based on https://httpd.apache.org/docs/current/mod/mod_proxy_wstunnel.html
        RewriteEngine On
        ProxyPreserveHost On
        RequestHeader set X-Real-IP %{REMOTE_ADDR}s
        AllowEncodedSlashes NoDecode

        ProxyPass /  http://$LOCAL_AI_HOSTNAME:10078/ nocanon
        ProxyPassReverse / http://$LOCAL_AI_HOSTNAME:10078/

        RewriteCond %{HTTP:Upgrade} websocket [NC]
        RewriteCond %{HTTP:Connection} upgrade [NC]
        RewriteCond %{THE_REQUEST} "^[a-zA-Z]+ /(.*) HTTP/\d+(\.\d+)?$"
        # Adjust to match APACHE_PORT and APACHE_IP_BINDING. 
        # See https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md#adapting-the-sample-web-server-configurations-below
        RewriteRule .? "ws://localhost:10078/%1" [P,L,UnsafeAllow3F]

        ErrorLog logs/ai.$NC_DOMAIN-error_log
        CustomLog logs/ai.$NC_DOMAIN-access_log combined

        SSLCertificateFile /etc/letsencrypt/live/ai.$NC_DOMAIN/cert.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/ai.$NC_DOMAIN/privkey.pem
        SSLCertificateChainFile /etc/letsencrypt/live/ai.$NC_DOMAIN/chain.pem

        # Solves slow upload speeds caused by http2
        H2WindowSize 5242880

        # TLS
        SSLEngine               on
        SSLProtocol             -all +TLSv1.2 +TLSv1.3
        SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDH>
        SSLHonorCipherOrder     off
        SSLSessionTickets       off

        # Disable HTTP TRACE method.
        TraceEnable off
        <Files ".ht*">
            Require all denied
        </Files>

        # Support big file uploads
        LimitRequestBody 0
        Timeout 86400
        ProxyTimeout 86400
    </VirtualHost>

</IfModule>
```

