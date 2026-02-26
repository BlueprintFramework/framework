[![](https://github.com/user-attachments/assets/a1a6df48-7925-43c9-81d6-e2351e6c6bb8)](https://blueprint.zip/guides/admin/install)

## Introduction
**Blueprint** is an open-source extension framework/manager for Pterodactyl. Developers can create versatile, easy-to-install extensions that system administrators can install within minutes *(usually even seconds!)* without having to custom-code compatibility across multiple panel modifications.

We aim to introduce new developers to Blueprint with easy to understand guides, documentation, developer commands, community support and more.

[Learn more about **Blueprint**](https://blueprint.zip) or [find your **next extension**](https://blueprint.zip/browse).

### Install Blueprint
Refer to the [installation guide](https://blueprint.zip/guides/admin/install).

<br>

## Donate and contribute
Blueprint is free and open-source software. We play a vital role in the Pterodactyl modding community and empower developers with tools to bring their ideas to life. To keep everything up and running, we rely heavily on [donations](https://hcb.hackclub.com/blueprint/donations). We're also nonprofit!

If you are an organization, [consider becoming a corporate sponsor](https://hcb.hackclub.com/donations/start/blueprint/tiers/392). Blueprint hosts guides and documentation that bring new developers to the hosting industry, giving a new chance for companies to aquire new talent and bring their operations further.

[**Donate to our nonprofit organization**](https://hcb.hackclub.com/donations/start/blueprint) or [view our open finances](https://hcb.hackclub.com/blueprint).

### Contributors
Contributors help shape the future of the Blueprint modding framework. To start contributing you have to [fork this repository](https://github.com/BlueprintFramework/framework/fork) and [open a pull request](https://github.com/BlueprintFramework/framework/compare).

<a href="https://github.com/BlueprintFramework/framework/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=BlueprintFramework/framework" />
</a>

### Related repositories
The Blueprint modding platform is spread over multiple repositories, each with it's own purpose. If you'd like to contribute, check out the following repositories:

- [**BlueprintFramework/docker**](https://github.com/BlueprintFramework/docker) is the image for running Blueprint and Pterodactyl with Docker.
- [**BlueprintFramework/templates**](https://github.com/BlueprintFramework/templates) is a repository with initialization templates for extension development.
- [**BlueprintFramework/web**](https://github.com/BlueprintFramework/web) is our open-source source of documentation, landing website, and API.

<br>

## What's in here?
The framework repository hosts the "Blueprint patch" that you apply onto your Pterodactyl panel. This overwrites files like installing a "standalone addon" would, but instead of being just that, Blueprint allows your panel to be extended through "extensions".

- Blueprint's CLI is written in Bash.
- The backend adds onto Pterodactyl's, and is written in PHP/Laravel.
- The user-side frontend adds onto Pterodactyl's, and is written in React/TypeScript.
- The admin-side frontend adds onto Pterodactyl's, and is written in PHP/Laravel/Blade.

### CLI
Our main CLI script is [`blueprint.sh`](./blueprint.sh). This script gets called by `/usr/local/bin/blueprint` whenever a user runs the `blueprint` command, or queries bash autocomplete.

[`blueprint.sh`](./blueprint.sh) is in charge of the following duties;
- Finishing initial installation steps and updates (flushing cache, artisan commands, etc)
- Sourcing CLI dependencies ([`scripts/libraries`](./scripts/libraries))
- Running the right sub-scripts for each command ([`scripts/commands`](./scripts/commands))
- Placing the Blueprint command shortcut to `/usr/local/bin/blueprint`

We used to do *everything* in the main CLI script, which overcomplicated everything *a lot*. Everything is now (mostly) designated to it's own area.

<br>

## Showcase
We've got a growing ecosystem of extensions, from ones cover game features such as Minecraft and Hytale, to useful quality-of-life admin tools.

![](https://github.com/user-attachments/assets/1cea099b-9af8-4ccc-ac1a-0a896a30f817)

<br/><br/>
<p align="center">
  © 2023-2026 Emma (prpl.wtf)
  <br/><br/><img src="https://github.com/user-attachments/assets/e6ff62c3-6d99-4e43-850d-62150706e5dd"/>
</p>
