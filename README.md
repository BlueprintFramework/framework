## ![](https://i.imgur.com/SsOU6r8.png) teamblueprint/main
[Discord ➚](https://ptero.shop/community)\
[Documentation ➚](https://ptero.shop/docs)

[Installation](#installation)\
[Development](#development)\
[Extensions](#extensions)

### Installation
**What you need:**
* The latest release of Blueprint. [Download ➚](https://github.com/teamblueprint/main/releases/latest)
* `unzip` [Download ➚](https://pkgs.org/download/unzip)
* Linux and Pterodactyl knowledge.
* Fingers and a brain.

**Installation:**
1. Navigate to `/var/www/pterodactyl`. (your Pterodactyl installation should be installed there or in `/var/www/html`, else it might not be compatible with Blueprint)
```sh
cd /var/www/pterodactyl
```
2. Run the Blueprint installation script. This runs the commands required for Blueprint to function correctly.
```sh
chmod +x blueprint.sh
bash blueprint.sh
```
3. After waiting for the installation script to finish, open up your Pterodactyl admin panel and click on the puzzle icon in the top right of the website.

### Development
We've made some guides for extension development over on [GitBook](https://ptero.shop/docs). We are adding more guides over time, don't hesitate to suggest a topic for future guides.

### Extensions
Open an issue on GitHub to get your extension listed here. To install an extension, upload your `something.blueprint` file to your Pterodactyl folder and run `blueprint -install something`.

**Redirect**: [PterodactylMarket](https://pterodactylmarket.com/resource/664), [GitHub](https://github.com/prplwtf/blueprint-redirect)\
**dbEdit**: [GitHub](https://github.com/prplwtf/blueprint-dbedit)
