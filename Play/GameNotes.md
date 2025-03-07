## Play

[PlayCommand](PlayCommand.swift) `struct` is the unified command line launcher for each game, and is the source for the **play** executable command. A specific game is launched using the `-g` option followed by the *gameName* (`rawValue` from the Game `enum` for the game case). `-t` flag for running unit test is also available, but only implemented in a few select games.

## Game Notes

Each game has undergone limited testing, primarily to demonstrate equivalent output to the sample runs included in the original sources, when possible.

##### [Acey Ducey](AceyDucey.swift)

- No issues

##### [Amazing](Amazing.swift)

- Original program flow is exceedingly convoluted and difficult to unravel. The underlying algorithm is ingenious and reproduced in the translation.
- First attempt at translation used recursion to duplicate the original code flow directly and is included for reference but commented out. This contains the exit row bug in the original code, in which an exit from the maze may be missing. The level of recursion exponentially increases with maze size, and results in stack overflow with large mazes. 

#### [Animal](Animal.swift)

- No issues
- Added save feature, as mentioned in the game description

#### [Awari](Awari.swift)

- Retained simple array to represent the board
- Incomplete understanding of computer learning algorithm
- Lines 900-999 should never be executed

#### [Bagels](Bagels.swift)

- No issues

#### [Banner](Banner.swift)

- No issues

#### [Basketball](Basketball.swift)

- Extra new line printed after rebound.
- Execution flow incompletely deconstructed; uses recursion to duplicate program flow

#### [Batnum](Batnum.swift)

- No issues

#### [Battle](Battle.swift)

- 2D array grid represented by Matrix struct.
- Complex logic to place ships on board in element-wise fashion not duplicated; replaced by Swift array methods

#### [Blackjack](Blackjack.swift)

- Original Basic program design largely followed

#### [Bombardment](Bombardment.swift)

- Added check for illegal entry

#### [Bombs Away](BombsAway.swift)

- No issues

#### [Bounce](Bounce.swift)

- Minor difference in plot along x axis, maybe due to cumulative rounding error 

#### [Bowling](Bowling.swift)

- Strike not possible? Additional testing needed
- Scoring issues: scoring of spares and strikes does not appear to follow bowling rules, and potential bugs in scoring, improper indexing of score by player; scoring not shown in sample run

#### [Boxing](Boxing.swift)

- No issues

#### [Bug](Bug.swift)

- No issues

#### [Bullfight](Bullfight.swift)

- Lines 1460-1570 - random number fnc is recomputed for each if statement
- Lines 1800-1820 should never be executed

#### [Bullseye](Bullseye.swift)

- No issues

#### [Bunny](Bunny.swift)

- No issues

#### [Buzzword](Buzzword.swift)

- No issues

#### [Calendar](Calendar.swift)

- Modification to allow user input of year
- Incorporates algorithm from weekday to get first day of year, as suggested in program intro

#### [Change](Change.swift)

- No issues

#### [Checkers](Checkers.swift)

- Bug in computer move, if move to last row (crowning - King) via jump user chip not removed
- Modified for Matrix implementation of Board after initial translation 

#### [Chemist](Chemist.swift)

- No issues

#### [Chief](Chief.swift)

- No issues

#### [Chomp](Chomp.swift)

- No issues

#### [Civil War](CivilWar.swift)

- Bug fixed - if 2 player mode, north not allowed to surrender; if south surrenders battle continues
- Bug fixed - morale for both sides calculated from F1 computed from south only

#### [Combat](Combat.swift)

- No issues

#### [Craps](Craps.swift)

- Lines 21-26 do nothing, except maybe random delay?

#### [Cube](Cube.swift)

- No issues

#### [Depth Charge](DepthCharge.swift)

- Added error check on dimension input

#### [Diamond](Diamond.swift)

- No issues

#### [Dice](Dice.swift)

- No issues

#### [Digits](Digits.swift)

- Line 700 - A=0, so K[] should not be used in calculation of S

#### [Even Wins (v1)](EvenWins1.swift)

- No issues

#### [Even Wins (v2)](EvenWins2.swift)

- No issues

#### [Flip Flop](FlipFlop.swift)

- Need to understand algorithm for flipping additional elements, r function 

#### [Football](Football.swift)

- Largely duplicates original code flow

#### [Ftball](Ftball.swift)

- Largely duplicates original code flow

#### [Fur Trader](FurTrader.swift)

- No issues

#### [Golf](Golf.swift)

- Original code execution flow is convoluted and probably not completely deconstructed
- Lines 650-665 C conditions don't makes ense, some may alway evaluate to true

#### [Gomoko](Gomoko.swift)

- Lines 610-650 original code bug fix - infinite loop when board is full

#### [Guess](Guess.swift)

- No issues

#### [Gunner](Gunner.swift)

- No issues

#### [Hamurabi](Hamurabi.swift)

- No issues

#### [Hangman](Hangman.swift)

- 300-320 minor variation to print word if all letters guessed

#### [Hello](Hello.swift)

- No issues

#### [Hexapawn](Hexapawn.swift)

- No issues

#### [Hi-Lo](HiLo.swift)

- No issues

#### [High I-Q](HighIQ.swift)

- No issues

#### [Hockey](Hockey.swift)

- 290-305 fixed bug in original code where pass could occur between same player
- Line 430 missing in original code; Z assumed to equal 17 for choice S=2

#### [Horserace](Horserace.swift)

- No issues

#### [Hurkle](Hurkle.swift)

- No issues

#### [ICBM](ICBM.swift)

- CLS statements not implemented

#### [Joust](Joust.swift)

- CLS statements not implemented

#### [Kinema](Kinema.swift)

- No issues

#### [King](King.swift)

- No issues

#### [Letter](Letter.swift)

- No issues

#### [Life](Life.swift)

- Added CRT mode

#### [Life for Two](Life2.swift)

- ?bug in original code - too many cells survive from round 1 to round 2
- Could improve coordinate input masking with raw mode in terminal

#### [Literature Quiz](LiteratureQuiz.swift)

- No issues

#### [Love](Love.swift)

- No issues

#### [Lunar](Lunar.swift)

- Total capsule weight M is 500 lbs larger than reported in description
- N is capsule weight, not including fuel
- 420-430 - replaced Taylor's expansion for log(1 - q) in original code 

#### [LEM](LEM.swift)

- No issues

#### [Rocket](Rocket.swift)

- Contact condition H > 0.05, to avoid showing height 0.0 before surface contact

#### [Master Mind](MasterMind.swift)

- Fixed bug in original code lines 620-630, actual combo not printed after out of guesses 

#### [Math Dice](MathDice.swift)

- No issues

#### [Mugwump](Mugwump.swift)

- No issues

#### [Name](Name.swift)

- No issues

#### [Nicomachus](Nicomachus.swift)

- No issues

#### [Nim](Nim.swift)

- Need to more completely understand computer move logic, binary arithmetic

#### [Number](Number.swift)

- No issues

#### [One Check](OneCheck.swift)

- No issues

#### [Orbit](Orbit.swift)

- Line 280 ship altitude D random calculation bug? fix - distance range should be 10000-30000

#### [Oregon Trail](OregonTrail.swift)

- First game translated, construction and code flow could be improved
- Uses nested functions to access state data in play func; could transition state data to a struct

#### [Pizza](Pizza.swift)

- Added error check for invalid address entry

#### [Poetry](Poetry.swift)

- No issues

#### [Poker](Poker.swift)

- Hand evaluation, computer betting logic confusing with inconsistencies, could be simplified and improved

#### [Queen](Queen.swift)

- Direct translation of original code (commented out) is substantially simplified

#### [Reverse](Reverse.swift)

- No issues

#### [Rock, Scissors, Paper](RockScissorsPaper.swift)

- No issues

#### [Roulette](Roulette.swift)

- Minor modification to date handling, added current date retrieval as mentioned in remarks

#### [Russian Roulette](RussianRoulette.swift)

- Not available for play 

#### [Salvo](Salvo.swift)

- Added error checking for coordinate entry
- Data structures and methods largely copied from similar game Battle

#### [Sine Wave](SineWave.swift)

- No issues

#### [Slalom](Slalom.swift)

- No issues

#### [Slots](Slots.swift)

- No issues

#### [Splat](Splat.swift)

- Added save feature, as suggested in game description

#### [Star Trek](StarTrek.swift)

- Retained much of the original design and variables
- Simplified algorithm for library computer calculation of direction and distance

#### [Stars](Stars.swift)

- No issues

#### [Stock Market](StockMarket.swift)

- No issues

#### [Synonym](Synonym.swift)

- No issues

#### [Target](Target.swift)

- Added report of approx degrees from x axis and z axis, from original 1975 source code

#### [3-D Plot](3DPlot.swift)

- Added function selection from options given in description

#### [3-D Tic-Tac-Toe](3DTicTacToe.swift)

- Tensor `struct` for 3D representation of board
- Convoluted computer move logic in original source code incompletely implemented

#### [Tic Tac Toe (v1)](TicTacToe1.swift)

- No issues

#### [Tic Tac Toe (v2)](TicTacToe2.swift)

- No issues

#### [Tower](Tower.swift)

- No issues

#### [Train](Train.swift)

- No issues

#### [Trap](Trap.swift)

- No issues

#### [23 Matches](23Matches.swift)

- No issues

#### [War](War.swift)

- No issues

#### [Weekday](Weekday.swift)

- Added date entry error catch
- Used Doomsday algorithm to compute weekday; A2 calculation not understood
- Alternate compact method to compute weekday included, but not used

#### [Word](Word.swift)

- No issues
