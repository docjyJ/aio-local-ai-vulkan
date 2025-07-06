> [!WARNING]
> ARM devices are not supported by this container. It is only for x86_64 devices.
> See: https://github.com/mudler/LocalAI/issues/5778

# Local AI with Vulkan support Community Container for Nextcloud All-In-One

This container is used in the [Nextcloud All-In-One](https://github.com/nextcloud/all-in-one/tree/main/community-containers/local-ai-vulkan) AI backend for Nextcloud Assistant. It works with the [Caddy community container](https://github.com/nextcloud/all-in-one/tree/main/community-containers/caddy) as a reverse proxy.

## Features

Compared to the default LocalAI container, this container provides:

- Automatic configuration of Nextcloud Assistant.
- Hardware acceleration support with Vulkan.
- *(Planned)* Easy access to the local AI web interface.

## Getting Started

### Prerequisites

You need:

- A Nextcloud instance running on a server with x86_64 architecture.
- At least 7GB of available storage space.
- Ensure that port `10078` is not used by another program (use `sudo netstat -tulpn` to list all used ports).
- Deploy the [Caddy community container](https://github.com/nextcloud/all-in-one/tree/main/community-containers/caddy) as a reverse proxy. (Other solutions are possible, see: [Use Your Own Reverse Proxy](#use-your-own-reverse-proxy)).

For hardware acceleration:

- A GPU compatible with Vulkan. Run `vulkaninfo` in the terminal to check if it is enabled.
- Enable [DRI device](https://github.com/nextcloud/all-in-one/tree/main#with-open-source-drivers-mesa-for-amd-intel-and-new-drivers-nouveau-for-nvidia) in AIO. Add `--env NEXTCLOUD_ENABLE_DRI_DEVICE=true` to the container.

### Installation

See [how to use community containers](https://github.com/nextcloud/all-in-one/tree/main/community-containers#how-to-use-this).

After installation on Nextcloud, go to `https://ai.$NC_DOMAIN` and log in with:

- **Username**: `aio`
- **Password**: Retrieve the password from the AIO interface

From the Local AI web interface, you can download and manage models. By default, no models are installed, so you need to download them manually. See [Recommended Models](#recommended-models) below.

After downloading the models, configure the Local AI server in Nextcloud:
1. Go to `https://$NC_DOMAIN/settings/admin/ai`
2. Set the Local AI server URL to `http://nextcloud-aio-local-ai-vulkan:8080`
3. Configure the models you want to use in the Nextcloud Assistant settings.

#### Recommended Models

| Usage               | Model            |
|---------------------|------------------|
| Text generation     | Llama 3          |
| Image generation    | Stable Diffusion |
| Audio transcription | Whisper          |

Feedback and suggestions are welcome!

## Use Your Own Reverse Proxy

Redirect HTTPS (or HTTP) traffic from `ai.$NC_DOMAIN` (or another subdomain) to port `10078` of the `nextcloud-aio-local-ai-vulkan` container over HTTP.

Example with `Caddyfile` syntax:

```caddyfile
https://ai.{$NC_DOMAIN}:443 {
    reverse_proxy http://{$LOCAL_AI_HOSTNAME}:10078
}
```

If you don't want to use the authentication provided you can redirect the traffic to the port `8080` but the proxy must
link in the `nextcloud-aio` container network.