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
* `yarn`
* Linux and Pterodactyl knowledge.
* Common sense.

**Installation:**
1. Navigate to your Pterodactyl folder. (most likely `/var/www/pterodactyl`)
2. Install NodeJS, NPM and Yarn using the following script. This assumes you are running Pterodactyl on Ubuntu or Debian-based systems.
```sh
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
npm i -g yarn
yarn
```
3. Run the Blueprint installation script. This runs the commands required for Blueprint to function correctly. If your Pterodactyl folder is not `/var/www/pterodactyl`, adjust the `$FOLDER` variable in blueprint.sh before running it.
```sh
chmod +x blueprint.sh
bash blueprint.sh
```
4. After waiting for the installation script to finish, open up your Pterodactyl admin panel and click on the puzzle icon in the top right of the website.

### Development
We've made some guides and documentation for extension development over on [GitBook](https://ptero.shop/docs). We are adding more guides over time, don't hesitate to suggest a topic for future guides.

### Extensions
[Open an issue](https://github.com/teamblueprint/main/issues) on GitHub to get your extension listed here. To install an extension, upload your `something.blueprint` file to your Pterodactyl folder and run `blueprint -install something`.

**Announcements**: [PterodactylMarket](https://pterodactylmarket.com/resource/679), [sourceXchange](https://www.sourcexchange.net/products/announcements)\
**Cats**: [sourceXchange](https://www.sourcexchange.net/products/cats)\
**dbEdit**: [GitHub](https://github.com/prplwtf/blueprint-dbedit)\
**Loader**: [sourceXchange](https://www.sourcexchange.net/products/loader)\
**Recolor**: [GitHub](https://github.com/sp11rum/recolor), [sourceXchange](https://www.sourcexchange.net/products/announcements)\
**Redirect**: [PterodactylMarket](https://pterodactylmarket.com/resource/664), [GitHub](https://github.com/prplwtf/blueprint-redirect)

### Contributions
[prplwtf](https://github.com/prplwtf) - creator and maintainer\
[ahwxorg](https://github.com/ahwxorg) - contributor\
[alipoyrazaydin](https://github.com/alipoyrazaydin) - contributor\
[sp11rum](https://github.com/sp11rum) - contributor
