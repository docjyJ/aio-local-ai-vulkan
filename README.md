> [!WARNING]
> ARM devices are not supported by this container. It is only for x86_64 devices. (See: https://github.com/mudler/LocalAI/issues/5778)


# Local AI with Vulkan support Community Container for Nextcloud All-In-One

This container is used in [Nextcloud All-In-One](https://github.com/nextcloud/all-in-one/tree/main/community-containers/local-ai-vulkan) AI backend for Nextcloud Assistant.

## Features

Compared to a default LocalAI container, this container allows:
- Automatic configuration of Nextcloud Assistant.
- Support Hardware acceleration with Vulkan.
- *(Planned)* Esseay access to local AI web interface.

## Getting Started

### Prerequisites

In general, you need:
- A Nextcloud instance running on a server with x86_64 architecture.
- Have enough storage space available (at least 7GB).

For hardware acceleration, you need:
- A GPU that supports Vulkan. Run `vulkaninfo` in the terminal to check if it is enabled.
- The [DRI device enabled](https://github.com/nextcloud/all-in-one/tree/main#with-open-source-drivers-mesa-for-amd-intel-and-new-drivers-nouveau-for-nvidia) in the AIO. You can do this by adding `--env NEXTCLOUD_ENABLE_DRI_DEVICE=true` to the container.

### Installation

See [how to use community containers](https://github.com/nextcloud/all-in-one/tree/main/community-containers#how-to-use-this).

After installation on Nextcloud, go to `https://TODO.$NC_DOMAIN/login` and log in with the following credentials:
- **Username**: `aio`
- **Password**: Get password inside the AIO interface

From the web interface of Local AI, you can download and manage models. By default, no models are installed, so you need to download them manually. See [Recommended models](#recommended-models) below.

After downloading the models, you neet to configure the Local AI server in Nextcloud. Go to `https://$NC_DOMAIN/settings/admin/ai` and set the Local AI server URL to `http://localhost:8080`. This is the default URL for the Local AI server in this container.

#### Recommended models

| Usage               | Model            |
|---------------------|------------------|
| Text generation     | llama 3          |
| Image generation    | Stable Diffusion |
| Audio transcription | Whisper          |

feedback and suggestions are welcome!
