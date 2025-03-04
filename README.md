#  Basic Computer Games

Swift translation of classic computer games written in Basic from the book [Basic Computer Games (Microcomputer Edition)](https://www.atariarchives.org/basicgames/), published by [David H. Ahl](https://www.swapmeetdave.com/Ahl/DHAbio.htm) in 1978, and other select Basic games from the follow-up book [More Basic Computer Games](https://archive.org/details/More_BASIC_Computer_Games), published by Ahl in 1980, and from [Creative Computing](https://archive.org/details/creativecomputing) magazine from the same era.

## Background

I was first exposed to computers and programming in the early 1970's, when a teletype connected via phone modem to a mainframe computer operated by the [Minnesota Educational Computing Consortium](https://en.wikipedia.org/wiki/MECC) was brought to my grade school. As I recall, 3 games were available on the mainframe: Amazing, a word finder puzzle generator, and probably Lunar. I was captivated and soon after learned to program in Basic, and later in Fortran. I purchased a TRS-80 Model 1 (originally with 4K RAM, later expanded to 16K). I subscribed to Creative Computing magazine and later purchased the compilation of games [Basic Computer Games (Microcomputer Edition)](https://www.atariarchives.org/basicgames/), and spent many hours entering programs into the TRS-80, as well as tinkering with my own programs. Later in college and graduate school, I learned to program in C. After a long hiatus from programming, I decided to revive my computer hobby, and learned Apple's Swift language shortly after it was released in 2014.

## Motivation

As a fun exercise, I decided to translate my favorite classic Basic games to Swift, starting first with Oregon Trail, and then Amazing. Inevitably the goal of translating all the games from [Basic Computer Games (Microcomputer Edition)](https://www.atariarchives.org/basicgames/) emerged. I have worked sporadically toward this goal over the past several years.

## Project Evolution

Originally each program was created as a CLI program. As more games were completed, a stand alone game launcher app was constructed to access all the games. Each game was launched in a separate Terminal window, tweaked to mimic a 1970's era computer. I subsequently discovered and added the [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git) terminal emulator, which allowed for more customization and a self-contained game launcher app. 

To simplify the design further, the individual game CLI products were consolidated into a single **play** CLI program. Individual games are run using the play command with the name of the game in the command line.

The project is written completely in Swift; the Basic Games launcher app utilizes SwiftUI wherever possible.

## Basic to Swift Translation

The primary focus is to duplicate as closely as possible the original game play, logic and I/O. In a few instances, minor output errors are corrected and enhancements are added. Many of the programs contain convoluted logic and confusing execution flow; all attempts are made to understand the underlying logic and to deconstruct the flow of execution in a more coherent, clear, and modern design. Custom Swift data structures are used to modularize code and encapsulate data and methods.

The Swift source code for each game is contained in a Swift class conforming to the BasicGame protocol.

In many cases, inline comments in the Swift source code provide a reference to lines in the original Basic code. Remarks (REM statements) are preserved in most cases, as a tribute to the original code.
 
### ConsoleIO

[ConsoleIO](ConsoleIO.swift) provides terminal I/O and other utility methods to bridge between the Swift code and terminal emulator. In most cases, output is throttled to create a vintage computer feel. It also provides simple communication between the terminal emulator and macOS app and system.

### BasicGame

[BasicGame](BasicGame.swift) is a Swift `protocol` adopted by all the games. It implements Swift methods duplicating many Basic functions, including `input`, `print`, `rnd`, `chr$`, among others, and provides a more explicit connection between the original Basic and Swift code.

## Project Structure

### Root folder

- [Extensions](Extensions.swift) and [Game](Game.swift) - shared by all targets.
- [Matrix](Matrix.swift) and [Tensor](Tensor.swift) - custom Swift 2D and 3D data structures, utilized in some of the game programs.
- [ConsoleIO](ConsoleIO.swift) - terminal I/O and utility methods
- [BasicGame](BasicGame.swift) - BasicGame protocol

### BasicGames folder 

UI code for the BasicGames game launcher app and SwiftTerm wrapper.

### Play folder

Code for the executable **play** CLI, which contains all the individual games, and for each game. Each game is contained in its own file, and is structured as a Swift class conforming to the BasicGame protocol.

See [GameNotes](Play/GameNotes.md) in **Play** folder for individual game notes.

### Package dependencies

[SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git) is currently embedded as a local package dependency in the BasicGames target, allowing for additional customizations. Alternatively it can be added remote package.

The **play** target depends on the [swift-argument-parser](https://github.com/apple/swift-argument-parser) package, for command line argument parsing and enhancements.

## Products

### BasicGames target

The GUI launcher macOS app, which launches each game in separate window in SwiftTerm. Contains additional goodies, including ability to view the original Basic code for each game (which is unlocked as an Easter Egg after successful game play).

### play target

Executable CLI program, which is embedded withi the BasicGames launcher app, but which can also be run as a standalone CLI in any terminal shell. If run in the macOS Terminal app, some customizations of Terminal can be added by un-commenting terminal setup commands in the ConsoleIO.swift file.

## Contribution

To add a new game:

1. Add *GameName*.swift file to [Play](Play) folder, with target membership **play**.
2. In that file create Swift `class` with *GameName* with conformance to BasicGame protocol, and add `func run() {}` for conformance.
2. Add case *gameName* to [Game](Game.swift) `enum`, and associated computed properties.
3. Add image for game as an Image set in [Assets](BasicGames/Assets), or use a selected system image; add image name to [Game](Game.swift) `enum`.
4. In [Play](Play/PlayCommand.swift) `struct`, add enum case for game and instantiate.
5. Write game code in *GameName*.swift file.
6. Optionally add pdf file with Basic source code, and matching pdf filename to the [Game](Game.swift) `enum`.

## Future

- Review completed programs for refinements, in some cases more complete understanding of underlying logic.
- Implement additional games from [More Basic Computer Games](https://archive.org/details/More_BASIC_Computer_Games) and [Creative Computing](https://archive.org/details/creativecomputing)

## Credits

Much thanks to [David H. Ahl](https://www.swapmeetdave.com/Ahl/DHAbio.htm) for his seminal involvement in early personal computing and computer games, and for inspiring a whole generation of programmers. In an incredibly generous move, David released all his works into the public domain in 2022.

Thanks to [Miguel de Icaza](https://github.com/migueldeicaza) and the other contributors of [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm.git).
