<h2><img src="https://i.imgur.com/nBYQ4Bl.png" style="height:30px;padding-right:1px"></img></h2>

[Discord ➚](https://ptero.shop/community)\
[Documentation ➚](https://blueprint.zip/docs)

[Introduction](#introduction)\
[Installation](#installation)\
[Development](#development)\
[Extensions](#extensions)\
[Contributors](#contributors)\
[Related Links](#related-links)

<br/>

## Introduction
**Blueprint** is an open-source extension framework/manager for Pterodactyl. Developers can create versatile, easy-to-install extensions that system administrators can install within minutes *(and sometimes even seconds!)*.

We aim to introduce new developers to Blueprint with easy to understand guides, documentation, developer commands, community support and more.

<br/>

## Installation
**What you need:**
* [The latest release of Blueprint.](https://github.com/teamblueprint/main/releases/latest)
* [`unzip`](https://pkgs.org/download/unzip)
* [`zip`](https://pkgs.org/download/zip)
* [`curl`](https://github.com/curl/curl)
* [`git`](https://github.com/git/git)
* [`nodejs`](https://nodejs.org) (20.x or later)
* [`yarn`](https://yarnpkg.com/)
* Linux and Pterodactyl knowledge.
* Common sense.

**Installation:**
> [!IMPORTANT]
> Blueprint doesn't mix well with other modifications, so if you already have any, [perform a panel update](https://pterodactyl.io/panel/1.0/updating.html) before moving on with this guide.

<br/>

1. Navigate to your Pterodactyl folder. (most likely `/var/www/pterodactyl`)
2. Install NodeJS, NPM and Yarn using the following commands. This assumes you are running Pterodactyl on Ubuntu or Debian-based systems.
```sh
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs
npm i -g yarn
yarn
```
3. Download [the latest release of Blueprint](https://github.com/teamblueprint/main/releases/latest) and extract it (stable build) or pull the files via git (bleeding-edge build).
4. If you haven't already, place the Blueprint files inside of your Pterodactyl folder. (common location is `/var/www/pterodactyl`)
5. Run the Blueprint installation script. This runs the commands required for Blueprint to function correctly. If your Pterodactyl folder is not `/var/www/pterodactyl` you may need to put `_FOLDER="/path/to/pterodactyl"` in front of `bash blueprint.sh`.
```sh
chmod +x blueprint.sh
bash blueprint.sh
```
6. After waiting for the installation script to finish, open up your Pterodactyl admin panel and click on the puzzle icon in the top right of the website.

<br/>

## Development
We've made some guides and documentation for extension development over on [blueprint.zip](https://blueprint.zip/docs). We are adding more guides over time, don't hesitate to suggest a topic for future guides.

<br/>

## Extensions
> [!NOTE]
> [Open a pull request](https://github.com/teamblueprint/web/pulls) on our website repository and add your extension to [`browse/:repository/repository.yml`](https://github.com/teamblueprint/web/blob/main/browse/%3Arepository/repository.yml) (in alphabetic order). To install an extension, upload your `something.blueprint` file to your Pterodactyl folder and run `blueprint -install something`.

<br/>

**Browse** free and paid themes and extensions on our website. [Find your next extension here.](https://blueprint.zip/browse)

<br/>

## Contributors
[prplwtf](https://github.com/prplwtf) - creator and maintainer\
[ahwxorg](https://github.com/ahwxorg) - contributor\
[alipoyrazaydin](https://github.com/alipoyrazaydin) - contributor\
[sp11rum](https://github.com/sp11rum) - contributor\
[phedona](https://github.com/Phedona) - contributor\
[codixer](https://github.com/Codixer) - contributor

<br/>

## Related Links
[**Pterodactyl**](https://pterodactyl.io/) is a free, open-source game server management panel built with PHP, React, and Go.\
[**teamblueprint/templates**](https://github.com/teamblueprint/templates) is a repository with initialization templates for extension development.\
[**teamblueprint/web**](https://github.com/teamblueprint/web) is our website and documentation revision.