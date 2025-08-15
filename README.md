# Nubby's Forgery
W.I.P Modloader for Nubby's Number Factory

## Why
Every GameMaker game has a data.win file, which holds most if not all of its assets and code.

Since it is a single binary file, it is rather simple to create mods for GameMaker games by modifying it and distributing a differential patch (an .xdelta).
However, since mods target this single binary file, you can't very easily apply two mods together; additionally, when the game updates, that file changes,
so mods have to update with the game.

The goal of this project is to solve both of these problems. You can think of the modloader as a regular mod that can load additional sub-mods, that are in a different format.
Since this format doesn't target a single binary file, there's no issue having multiple mods running together. And when the game updates (depending on the nature of the update), the modloader could make sure old mods still work.

There's two other goals:

- Making modding slightly more accessible by writing an API to help you extend base game systems (e.g. making it easier to add new items, perks, and whatnot)

- Making sure the modloader doesn't limit what you can do. And in the end, the goal is that you'll be able to do any modification to the game you could do normally
by modifying the data.win directly.

## How it works
This repository contains a GameMaker project. This project is built, and then merged into Nubby's Number Factory, using an UndertaleModTool script, 
with some patches applied from `/patches`.
This structure is what allows the project to be open-sourced (and also makes it resilient to game updates!)

Mods are written using [Catspeak](https://www.katsaii.com/catspeak-lang/), or GML with [GMLspeak](https://docs.tabularelf.com/GMLspeak/).

# Installing
Pick the version you want in https://github.com/Skirlez/nubbys-forgery/releases, and follow the instructions written with it.

## Making your own mod
I would advise against it as of now, as the API is still changing. Nevertheless, an up-to-date example mod, with various trinkets I have implemented, is
available at https://github.com/Skirlez/nubbys-forgery-example-mod. It has plenty of comments to help you.

The example mod is released under a public domain license, so you can copy or fork it and make whatever changes you want, without attribution.

Additionally: See the [wiki](https://github.com/Skirlez/nubbys-forgery/wiki)! 

## Status
Below is a list of what I want the modloader to have with a tick with what's implemented.
- [x] Items
- [x] Perks
- [x] Supervisors
- [ ] Challenges
- [ ] Special/Boss Rounds
- [x] Sprite management
- [x] Audio management
- [x] Translations
- [ ] Code patching/modification using launcher

## Building
See the wiki: [Windows](https://github.com/Skirlez/nubbys-forgery/wiki/Building-Nubby's-Forgery-(Windows)), [Linux](https://github.com/Skirlez/nubbys-forgery/wiki/Building-Nubby's-Forgery-(Linux))

## License
The project is licensed under the LGPLv3 license (LICENSE.md). GPLv3 license text available in (COPY-OF-GPL-3.0.md)
Catspeak, GMLspeak are originally licensed under the MIT license (see GMLspeak_LICENSE and catspeak_LICENSE)


## Contributing
Please contribute