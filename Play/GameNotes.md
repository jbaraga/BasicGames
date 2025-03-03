# Play

[PlayCommand](PlayCommand.swift) is the unified launcher for each game, and is the source for the **play** executable command. A specific game is launched using the `-g` option followed by the *gameName* (`rawValue` from the Game `enum` for the game case). `-t` flag for running unit test is also available, but only implemented in a few select games.

## Game Notes

Each game has undergone limited testing, primarily to demonstrate equal output to the sample runs included in the original sources, when possible.

### [Acey Ducey](AceyDucey.swift)

- No issues.

### [Amazing](Amazing.swift)

- The original program flow is exceedingly convoluted and difficult to unravel. The underlying algorithm is ingenious, and akin to random walk; the algorithm is outlined in the inline program comments.
- The first attempt used recursion to duplicate the original code flow directly and is included for reference but commented out. This contains the exit row bug in the original code, in which an exit is not created occasionally. The level of recursion exponentially increases with maze size, and results in stack overflow with large mazes. 

### [Animal](Animal.swift)

- No issues.
- Added save feature, as mentioned in the game description, and ability to reset the saved list.

### [Awari](Awari.swift)

- Retained simple array to represent the board.
- Incomplete understanding of computer learning algorithm.
- Lines 900-999 should never be executed.

### Bagels


### Banner


### Basketball


### Batnum


### Battle


### Blackjack


### Bombardment


### Bombs Away


### Bounce


### Bowling


### Boxing


### Bug


### Bullfight


### Bullseye


### Bunny


### Buzzword


### Calendar


### Change


### Checkers


### Chemist


### Chief


### Chomp


### Civil War


### Combat


### Craps


### Cube


### Depth Charge


### Diamond


### Dice


### Digits


### Even Wins (v1)


### Even Wins (v2)


### Flip Flop


### Football


### Ftball


### Fur Trader


### Golf


### Gomoko


### Guess


### Gunner


### Hamurabi


### Hangman


### Hello


### Hexapawn


### Hi-Lo


### High I-Q


### Hockey


### Horserace


### Hurkle


### ICBM


### Joust


### Kinema


### King


### Letter


### Life


### Life for Two


### Literature Quiz


### Love


### Lunar


### LEM


### Rocket


### Master Mind


### Math Dice


### Mugwump


### Name


### Nicomachus


### Nim


### Number


### One Check


### Orbit


### Oregon Trail


### Pizza


### Poetry


### Poker


### Queen


### Reverse


### Rock, Scissors, Paper


### Roulette


### Russian Roulette


### Salvo


### Sine Wave


### Slalom


### Slots


### Splat


### Star Trek


### Stars


### Stock Market


### Synonym


### Target


### 3-D Plot


### 3-D Tic-Tac-Toe


### Tic Tac Toe (v1)


### Tic Tac Toe (v2)


### Tower


### Train


### Trap


### 23 Matches


### War


### Weekday


### Word

