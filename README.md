# Nubby's Forgery
W.I.P Modloader for Nubby's Number Factory

## Why
Every GameMaker has a data.win file which holds most of not all of its assets and code.

Since it is a single binary file, it is rather simple to create mods for GameMaker games by editing it and distributing a differential patch (an .xdelta)
However, since mods target this single binary file, you can't very easily apply two mods together; additionally, when the game updates, that file changes,
so mods have to update with the game.

The goal of this project is to solve both of these problems. You can think of the modloader as a regular mod that can load additional sub-mods, that are in a different format.
Since everything is done at runtime, there's no issue running several mods together. And if the game updates, depending on the nature of the update, the modloader could make sure old mods still work.

## How it works
This repository contains a GameMaker project. This project is built, and then merged into Nubby's Number Factory, using an UndertaleModTool script, 
with some patches applied from `/patches`.
This structure is what allows the project to be open-sourced (and also makes it resilient to game updates!)

Mods are written using [Catspeak](https://github.com/katsaii/catspeak-lang).

To make a mod, clone the example project from [here](https://github.com/Skirlez/nubbys-forgery-example-mod), and read the comments

## Status
Below is a list of what I want the modloader to have with a tick with what's implemented.
- [x] Items
- [ ] Perks
- [ ] Supervisors
- [ ] Challenges
- [ ] Special/Boss Rounds
- [x] Sprite loading
- [ ] Audio loading
- [x] Translations

## Building
See the wiki: [Windows](https://github.com/Skirlez/nubbys-forgery/wiki/Building-Nubby's-Forgery-(Windows)), [Linux](https://github.com/Skirlez/nubbys-forgery/wiki/Building-Nubby's-Forgery-(Linux))
## License
Catspeak is licensed under MIT license. Therefore, all of its code files are licensed under the MIT license.
The rest of the code is licensed under the AGPLv3 license.

## Contributing
Please contribute