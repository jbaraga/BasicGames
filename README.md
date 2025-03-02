#  Basic Computer Games
Swift translation of classic computer games written in Basic from the book "Basic Computer Games (Microcomputer Edition)", published by David H. Ahl in 1978, and other select Basic games from the follow-up book "More Basic Computer Games", published by David H. Ahl in 1980, and from Creative Computing magazine from the same era.

## Background
I was first exposed to computers and computer games in the early 1970's, when a teletype connected via phone modem to a mainframe computer operated by the Minnesota Educational Computing Consortium was brought to my grade school. As I recall, 3 games were available on the mainframe: Amazing, a word finder puzzle generator, and a third game which I do not specifically remember. I was mesmerized, and soon after began to learn how to program in Basic, and later in Fortran. As an early teen, I purchased a TRS-80 Model 1 (originally with 4K RAM, later expanded to 16K). I subscribed to Creative Computing magazine, and spent many hours entering programs published in each issue into the TRS-80, as well as tinkering with my own programs. I later purchased the compilation "Basic Computer Games", by David Ahl (alas, my TRS-80 and associated materials have been long lost). Later in college and graduate school, I learned and programmed in C. After a long hiatus, I decided to revive my computer hobby, and I learned to program in Swift shortly after it was released in 2014.

## Motivation
As a fun exercise, I decided to translate my favorite classic Basic games to Swift, starting first with Oregon Trail, and then Amazing. I then decided to translate more Basic games from "Basic Computer Games", and inevitably the goal of translating all the games emerged. 

## Project Evolution
Originally each program was created as a CLI program, running them in Terminal. As more games were completed, I decided to create a stand alone game launcher app to access all the games. Originally the app launched each game in a separate Terminal window, which I tweaked to mimic a 1970's era computer. I subsequently discovered and added the [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git) terminal emulator, which allowed for more customization and a self-contained game launcher app. 

As a further simplification, the individual game CLI products were replaced by the Play CLI, which contains all of the games in a single combined CLI. Individual games are launched from the command line.

The project is written completely in Swift, and uses SwiftUI wherever possible.

## Project Structure


## Usage
Currently SwiftTerm is embedded as a local package dependency in the BasicGames target, allowing for additional customizations, but this is not mandatory and it can be added remote package.

The BasicGames target produces the complete launcher app, which launches each game in separate window in SwiftTerm.

The play target produces a standalone CLI program, which can be run in any terminal app. If run in the Terminal app, some customizations of Terminal can be added by un-commenting terminal setup commands in the ConsoleIO.swift file.

## Credits
Much thanks to [David H. Ahl](https://www.swapmeetdave.com/Ahl/DHAbio.htm) for his seminal involvement in early personal computing and computer games, and for inspiring a whole generation of programmers.

Thanks to Miguel de Icaza and the other contributers of [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git).
