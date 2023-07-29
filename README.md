## ![](https://i.imgur.com/SsOU6r8.png) teamblueprint/main
[Discord ➚](https://ptero.shop/community)\
[Documentation ➚](https://ptero.shop/docs)

[Installation](#installation)\
[Development](#development)\
[Extensions](#extensions)\
[Contributions](#contributions)

### Installation
**What you need:**
* The latest release of Blueprint. [Download ➚](https://github.com/teamblueprint/main/releases/latest)
* `unzip` [Download ➚](https://pkgs.org/download/unzip)
* `nodejs` [Download ➚](https://pkgs.org/download/nodejs)
* `yarn` (to build the panel)
* Linux and Pterodactyl knowledge.
* Fingers and a brain.

**Installation:**
1. Navigate to your Pterodactyl folder. (most likely /var/www/pterodactyl)
2. Run the Blueprint installation script. This runs the commands required for Blueprint to function correctly. If your Pterodactyl folder is not `/var/www/pterodactyl`, adjust the `$FOLDER` variable in blueprint.sh before running it.
```sh
chmod +x blueprint.sh
bash blueprint.sh
```
3. After waiting for the installation script to finish, open up your Pterodactyl admin panel and click on the puzzle icon in the top right of the website.

### Development
We've made some guides for extension development over on [GitBook](https://ptero.shop/docs). We are adding more guides over time, don't hesitate to suggest a topic for future guides.

### Extensions
Open an issue on GitHub to get your extension listed here. To install an extension, upload your `something.blueprint` file to your Pterodactyl folder and run `blueprint -install something`.

**Announcements**: [PterodactylMarket](https://pterodactylmarket.com/resource/679), [sourceXchange](https://www.sourcexchange.net/products/announcements)\
**Redirect**: [PterodactylMarket](https://pterodactylmarket.com/resource/664), [GitHub](https://github.com/prplwtf/blueprint-redirect)\
**dbEdit**: [GitHub](https://github.com/prplwtf/blueprint-dbedit)

### Contributions
[prplwtf](https://github.com/prplwtf) - creator and maintainer\
[alipoyrazaydin](https://github.com/alipoyrazaydin) - contributor\
[sp11rum](https://github.com/sp11rum) - contributor