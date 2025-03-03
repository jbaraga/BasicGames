#  Basic Computer Games

Swift translation of classic computer games written in Basic from the book [Basic Computer Games (Microcomputer Edition)](https://www.atariarchives.org/basicgames/), published by [David H. Ahl](https://www.swapmeetdave.com/Ahl/DHAbio.htm) in 1978, and other select Basic games from the follow-up book [More Basic Computer Games](https://archive.org/details/More_BASIC_Computer_Games), published by Ahl in 1980, and from [Creative Computing](https://archive.org/details/creativecomputing) magazine from the same era.

## Background

I was first exposed to computers and programming in the early 1970's, when a teletype connected via phone modem to a mainframe computer operated by the [Minnesota Educational Computing Consortium](https://en.wikipedia.org/wiki/MECC) was brought to my grade school. As I recall, 3 games were available on the mainframe: Amazing, a word finder puzzle generator, and a third game which I do not specifically remember. I was captivated and soon after learned to program in Basic, and later in Fortran. I purchased a TRS-80 Model 1 (originally with 4K RAM, later expanded to 16K). I subscribed to Creative Computing magazine and later purchased the compilation of games [Basic Computer Games (Microcomputer Edition)](https://www.atariarchives.org/basicgames/), and spent many hours entering programs into the TRS-80, as well as tinkering with my own programs. Later in college and graduate school, I learned to program in C. After a long hiatus from programming, I decided to revive my computer hobby, and learned Apple's Swift language shortly after it was released in 2014.

## Motivation

As a fun exercise, I decided to translate my favorite classic Basic games to Swift, starting first with Oregon Trail, and then Amazing. Inevitably the goal of translating all the games from [Basic Computer Games (Microcomputer Edition)](https://www.atariarchives.org/basicgames/) emerged, and I have worked on this sporadically over that past several years.

## Project Evolution

Originally each program was created as a CLI program, running them in Terminal. As more games were completed, I decided to create a stand alone game launcher app to access all the games. Each game was launched in a separate Terminal window, which I tweaked to mimic a 1970's era computer. I subsequently discovered and added the [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git) terminal emulator, which allowed for more customization and a self-contained game launcher app. 

As a further simplification, the individual game CLI products were replaced by the single **play** CLI programs, which encapsulates all of the games in a single combined CLI. Individual games are launched from the command line.

The project is written completely in Swift; the Basic Games launcher app utilizes SwiftUI wherever possible.

## Basic to Swift Translation

The primary focus is to duplicate as closely as possible the original game play, logic and I/O. In a few instances, minor output errors are corrected. Many of the programs contain convoluted logic and confusing execution flow; all attempts are made to understand the underlying logic and to duplicate the logic in a more coherent, clear, and modern design. Custom Swift data structures are used to modularize code and encapsulate data and methods.

The Swift source code for each game is contained in a Swift class conforming to the BasicGame protocol.

In many cases, inline comments in the Swift source code provide a reference to lines in the original Basic code. Remarks (REM statements) are preserved in most cases, as a tribute to the original code.
 
### ConsoleIO

[ConsoleIO](BasicGames/ConsoleIO) provides I/O and other utility methods to bridge between the Swift code and terminal emulator. In most cases, output is throttled to create a vintage computer feel. It also provides simple communication between the terminal emulator and macOS app and system.

### BasicGame

[BasicGame](BasicGames/BasicGame) is a Swift protocol adopted by all the games. It implements Swift methods duplicating many Basic functions, including input, print, rnd, chr$, among others, and provides a more explicit connection between the original Basic and Swift code.

## Project Structure

### BasicGames folder 

Code shared among all the games, and the source code and UI code for the BasicGames game launcher app and SwiftTerm wrapper.

### Play folder

Code for the executable **play** CLI, which contains all the individual games, and for each game. Each game is contained in its own file, and is structured as a Swift class conforming to the BasicGame protocol.

See [Readme](Play/README.md) file in Play folder for individual game notes.

### Package dependencies

[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git) is currently embedded as a local package dependency in the BasicGames target, allowing for additional customizations. Alternatively it can be added remote package.

The **play** target depends on the [swift-argument-parser](https://github.com/apple/swift-argument-parser) package, for command line argument parsing and enhancements.

## Products

### BasicGames target

The complete launcher app, which launches each game in separate window in SwiftTerm. Contains additional goodies, including ability to view the original Basic code for each game (which is unlocked as an Easter Egg after successful game play).

### play target

Executable CLI program, which is embedded withi the BasicGames launcher app, but which can also be run as a standalone CLI in any terminal shell. If run in the macOS Terminal app, some customizations of Terminal can be added by un-commenting terminal setup commands in the ConsoleIO.swift file.

## Contribution

To add a new game:

1. Add <GameName>.swift file to [Play](BasicGames/Play) folder, with target membership **play**.
2. In that file create Swift class with GameName with conformance to BasicGame protocol, and add `func run() {}` for conformance.
2. Add case gameName to [Game](BasicGames/Game) `enum`, and associated computed properties.
3. Add image for game as anImage set in Assets, or use a selected system image; add image name to [Game](BasicGames\Game) `enum`.
4. In [`Play`](BasicGames/Play/PlayCommand) struct, add enum case for game and instantiate.
5. Write game code in GameName.swift file.
6. Optionally add pdf file with Basic source code, and matching pdf filename to the [Game](BasicGames/Game) `enum`.

## Credits

Much thanks to [David H. Ahl](https://www.swapmeetdave.com/Ahl/DHAbio.htm) for his seminal involvement in early personal computing and computer games, and for inspiring a whole generation of programmers. In an incredibly generous move, David released all his works into the public domain in 2022.

Thanks to [Miguel de Icaza](https://github.com/migueldeicaza) and the other contributors of [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git).
