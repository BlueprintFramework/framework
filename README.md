<h2><img src="https://i.imgur.com/nBYQ4Bl.png" style="height:30px;padding-right:1px"></img></h2>

[Discord ➚](https://ptero.shop/community)\
[Documentation ➚](https://ptero.shop/docs)

[Installation](#installation)\
[Development](#development)\
[Extensions](#extensions)\
[Contributions](#contributions)

### Installation
**What you need:**
* [The latest release of Blueprint.](https://github.com/teamblueprint/main/releases/latest)
* [`unzip`](https://pkgs.org/download/unzip)
* [`nodejs`](https://nodejs.org) (18.x or later)
* [`yarn`](https://yarnpkg.com/)
* Linux and Pterodactyl knowledge.
* Common sense.

**Installation:**
1. Blueprint doesn't mix well with other modifications, so if you already have any, [perform a panel update](https://pterodactyl.io/panel/1.0/updating.html) before moving on with this guide.
2. Navigate to your Pterodactyl folder. (most likely `/var/www/pterodactyl`)
3. Install NodeJS, NPM and Yarn using the following script. This assumes you are running Pterodactyl on Ubuntu or Debian-based systems.
```sh
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
npm i -g yarn
yarn
```
4. Download [the latest release of Blueprint](https://github.com/teamblueprint/main/releases/latest) and extract it (stable build) or pull the files via git (bleeding-edge build).
5. If you haven't already, place the Blueprint files inside of your Pterodactyl folder. (common location is `/var/www/pterodactyl`)
6. Run the Blueprint installation script. This runs the commands required for Blueprint to function correctly. If your Pterodactyl folder is not `/var/www/pterodactyl` you may need to put `_FOLDER="/path/to/pterodactyl"` in front of `bash blueprint.sh`.
```sh
chmod +x blueprint.sh
bash blueprint.sh
```
7. After waiting for the installation script to finish, open up your Pterodactyl admin panel and click on the puzzle icon in the top right of the website.

**Upgrade:**

To upgrade Blueprint or its extensions, follow these steps:

1. Create a backup of your current panel. In case anything goes wrong, you can use your backup.
2. Run the command `blueprint -upgrade`.

Success! You have successfully upgraded Blueprint. Now you can install your extensions as usual.

### Development
We've made some guides and documentation for extension development over on [GitBook](https://ptero.shop/docs). We are adding more guides over time, don't hesitate to suggest a topic for future guides.

### Extensions
[Open an issue](https://github.com/teamblueprint/main/issues) on GitHub to get your extension listed here. To install an extension, upload your `something.blueprint` file to your Pterodactyl folder and run `blueprint -install something`.

**Announcements**: [PterodactylMarket](https://pterodactylmarket.com/resource/679), [sourceXchange](https://www.sourcexchange.net/products/announcements), [BuiltByBit](https://builtbybit.com/resources/announcements-for-blueprint.32546/)\
**Arc.io Integration**: [BuiltByBit](https://builtbybit.com/resources/pterodactyl-v1-addon-arc-integration.32109/)\
**Cats**: [sourceXchange](https://www.sourcexchange.net/products/cats)\
**Cookies**: [sourceXchange](https://www.sourcexchange.net/products/cookies)\
**dbEdit**: [GitHub](https://github.com/prplwtf/blueprint-dbedit)\
**Loader**: [sourceXchange](https://www.sourcexchange.net/products/loader)\
**Nebula**: [PterodactylMarket](https://pterodactylmarket.com/resource/698), [sourceXchange](https://www.sourcexchange.net/products/nebula), [BuiltByBit](https://builtbybit.com/resources/nebula-for-blueprint.32442/)\
**Recolor**: [GitHub](https://github.com/sp11rum/recolor), [sourceXchange](https://www.sourcexchange.net/products/announcements)\
**Redirect**: [PterodactylMarket](https://pterodactylmarket.com/resource/664), [GitHub](https://github.com/prplwtf/blueprint-redirect)

### Contributions
[prplwtf](https://github.com/prplwtf) - creator and maintainer\
[ahwxorg](https://github.com/ahwxorg) - contributor\
[alipoyrazaydin](https://github.com/alipoyrazaydin) - contributor\
[sp11rum](https://github.com/sp11rum) - contributor\
[phedona](https://github.com/Phedona) - contributor
