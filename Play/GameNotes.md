# Play

[PlayCommand](PlayCommand.swift) `struct` is the unified command line launcher for each game, and is the source for the **play** executable command. A specific game is launched using the `-g` option followed by the *gameName* (`rawValue` from the Game `enum` for the game case). `-t` flag for running unit test is also available, but only implemented in a few select games.

## Game Notes

Each game has undergone limited testing, primarily to demonstrate equal output to the sample runs included in the original sources, when possible.

### [Acey Ducey](AceyDucey.swift)

- No issues.

### [Amazing](Amazing.swift)

- The original program flow is exceedingly convoluted and difficult to unravel. The underlying algorithm is ingenious, and akin to random walk; the algorithm is outlined in the inline program comments.
- The first attempt used recursion to duplicate the original code flow directly and is included for reference but commented out. This contains the exit row bug in the original code, in which an exit from the maze may be missing. The level of recursion exponentially increases with maze size, and results in stack overflow with large mazes. 

### [Animal](Animal.swift)

- No issues.
- Added save feature, as mentioned in the game description, and ability to reset the saved list.

### [Awari](Awari.swift)

- Retained simple array to represent the board.
- Incomplete understanding of computer learning algorithm.
- Lines 900-999 should never be executed.

### [Bagels](Bagels.swift)

- No issues

### [Banner](Banner.swift)

- No issues

### [Basketball](Basketball.swift)

- Extra new line printed after rebound.
- Execution flow incompletely deconstructed; uses recursion to duplicate program flow.

### [Batnum](Batnum.swift)

- No issues

### [Battle](Battle.swift)

- 2D array grid represented by Matrix struct.
- Complex logic to place ships on board in element-wise fashion not duplicated; replaced by Swift array methods.

### [Blackjack](Blackjack.swift)

- Original Basic program design largely followed

### [Bombardment](Bombardment.swift)

- Added check for illegal entry

### [Bombs Away](BombsAway.swift)

- No issues

### [Bounce](Bounce.swift)

- Minor difference in plot along x axis, maybe due to cumulative rounding error 

### [Bowling](Bowling.swift)

- Strike not possible? Additional testing needed
- Scoring issues: scoring of spares and strikes does not appear to follow bowling rules, and potential bugs in scoring, improper indexing of score by player; scoring not shown in sample run

### [Boxing](Boxing.swift)

- No issues

### [Bug](Bug.swift)

- No issues

### [Bullfight](Bullfight.swift)

- Lines 1460-1570 - random number fnc is recomputed for each if statement
- Lines 1800-1820 should never be executed

### [Bullseye](Bullseye.swift)

- No issues

### [Bunny](Bunny.swift)

- No issues

### [Buzzword](Buzzword.swift)

- No issues

### [Calendar](Calendar.swift)

- Modification to allow user input of year
- Incorporates algorithm from weekday to get first day of year, as suggested in program intro

### [Change](Change.swift)

- No issues

### [Checkers](Checkers.swift)

- Bug in computer move, if move to last row (King) via jump user chip not removed
- Modified for Matrix implementation of Board after initial translation 

### [Chemist](Chemist.swift)

- No issues

### [Chief](Chief.swift)

- No issues

### [Chomp](Chomp.swift)

- No issues

### [Civil War](CivilWar.swift)

- Bug fixed - if 2 player mode, north not allowed to surrender; if south surrenders battle continues
- Bug fixed - morale for both sides calculated from F1 computed from south only

### [Combat](Combat.swift)

- No issues

### [Craps](Craps.swift)

- Lines 21-26 do nothing, except maybe random delay?

### [Cube](Cube.swift)

- No issues

### [Depth Charge](Depth Charge.swift)


### [Diamond](Diamond.swift)


### [Dice](Dice.swift)


### [Digits](Digits.swift)


### [Even Wins (v1)](EvenWins1.swift)


### [Even Wins (v2)](EvenWins2.swift)


### [Flip Flop](FlipFlop.swift)


### [Football](Football.swift)


### [Ftball](Ftball.swift)


### [Fur Trader](FurTrader.swift)


### [Golf](Golf.swift)


### [Gomoko](Gomoko.swift)


### [Guess](Guess.swift)


### [Gunner](Gunner.swift)


### [Hamurabi](Hamurabi.swift)


### [Hangman](Hangman.swift)


### [Hello](Hello.swift)


### [Hexapawn](Hexapawn.swift)


### [Hi-Lo](HiLo.swift)


### [High I-Q](HighIQ.swift)


### [Hockey](Hockey.swift)


### [Horserace](Horserace.swift)


### [Hurkle](Hurkle.swift)


### [ICBM](ICBM.swift)


### [Joust](Joust.swift)


### [Kinema](Kinema.swift)


### [King](King.swift)


### [Letter](Letter.swift)


### [Life](Life.swift)


### [Life for Two](Life2.swift)


### [Literature Quiz](LiteratureQuiz.swift)


### [Love](Love.swift)


### [Lunar](Lunar.swift)


### [LEM](LEM.swift)


### [Rocket](Rocket.swift)


### [Master Mind](MasterMind.swift)


### [Math Dice](MathDice.swift)


### [Mugwump](Mugwump.swift)


### [Name](Name.swift)


### [Nicomachus](Nicomachus.swift)


### [Nim](Nim.swift)


### [Number](Number.swift)


### [One Check](OneCheck.swift)


### [Orbit](Orbit.swift)


### [Oregon Trail](OregonTrail.swift)


### [Pizza](Pizza.swift)


### [Poetry](Poetry.swift)


### [Poker](Poker.swift)


### [Queen](Queen.swift)


### [Reverse](Reverse.swift)


### [Rock, Scissors, Paper](RockScissorsPaper.swift)


### [Roulette](Roulette.swift)


### [Russian Roulette](RussianRoulette.swift)


### [Salvo](Salvo.swift)


### [Sine Wave](SineWave.swift)


### [Slalom](Slalom.swift)


### [Slots](Slots.swift)


### [Splat](Splat.swift)


### [Star Trek](StarTrek.swift)


### [Stars](Stars.swift)


### [Stock Market](StockMarket.swift)


### [Synonym](Synonym.swift)


### [Target](Target.swift)


### [3-D Plot](3DPlot.swift)


### [3-D Tic-Tac-Toe](3DTicTacToe.swift)


### [Tic Tac Toe (v1)](TicTacToe1.swift)


### [Tic Tac Toe (v2)](TicTacToe2.swift)


### [Tower](Tower.swift)


### [Train](Train.swift)


### [Trap](Trap.swift)


### [23 Matches](23Matches.swift)


### [War](War.swift)


### [Weekday](Weekday.swift)


### [Word](Word.swift)

