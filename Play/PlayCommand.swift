//
//  PlayCommand.swift
//  play
//
//  Created by Joseph Baraga on 12/31/24.
//

import Foundation
import ArgumentParser


@main
struct Play: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(abstract: "Basic Computer Games.")
    
    @Option(
        name: [.short, .customLong("game")],
        help: "Game to play. Available games: \n\((Game.allCases.map { $0.rawValue }).joined(separator: ", "))")
    var gameName: String
    
    @Flag(name: [.short, .long], help: "Run unit test, if implemented.")
    var test = false

    func run() throws {
        guard let game = Game(rawValue: gameName) else { throw RuntimeError("Invalid game name.") }
        
        let basicGame: BasicGame
        switch game {
        case .aceyDucey:
            basicGame = AceyDucey()
        case .amazing:
            basicGame = Amazing()
        case .animal:
            basicGame = Animal()
        case .awari:
            basicGame = Awari()
        case .bagels:
            basicGame = Bagels()
        case .banner:
            basicGame = Banner()
        case .basketball:
            basicGame = Basketball()
        case .batnum:
            basicGame = Batnum()
        case .battle:
            basicGame = Battle()
        case .blackjack:
            basicGame = Blackjack()
        case .bombardment:
            basicGame = Bombardment()
        case .bombsAway:
            basicGame = BombsAway()
        case .bounce:
            basicGame = Bounce()
        case .bowling:
            basicGame = Bowling()
        case .boxing:
            basicGame = Boxing()
        case .bug:
            basicGame = Bug()
        case .bullfight:
            basicGame = BullFight()
        case .bullseye:
            basicGame = Bullseye()
        case .bunny:
            basicGame = Bunny()
        case .buzzword:
            basicGame = Buzzword()
        case .calendar:
            basicGame = Calendar()
        case .change:
            basicGame = Change()
        case .checkers:
            basicGame = Checkers()
        case .chemist:
            basicGame = Chemist()
        case .chief:
            basicGame = Chief()
        case .chomp:
            basicGame = Chomp()
        case .civilWar:
            basicGame = CivilWar()
        case .combat:
            basicGame = Combat()
        case .craps:
            basicGame = Craps()
        case .cube:
            basicGame = Cube()
        case .depthCharge:
            basicGame = DepthCharge()
        case .diamond:
            basicGame = Diamond()
        case .dice:
            basicGame = Dice()
        case .digits:
            basicGame = Digits()
        case .evenWins1:
            basicGame = EvenWins1()
        case .evenWins2:
            basicGame = EvenWins2()
        case .flipFlop:
            basicGame = FlipFlop()
        case .football:
            basicGame = Football()
        case .ftball:
            basicGame = Ftball()
        case .furTrader:
            basicGame = FurTrader()
        case .golf:
            basicGame = Golf()
        case .gomoko:
            basicGame = Gomoko()
        case .guess:
            basicGame = Guess()
        case .gunner:
            basicGame = Gunner()
        case .hamurabi:
            basicGame = Hamurabi()
        case .hangman:
            basicGame = Hangman()
        case .hello:
            basicGame = Hello()
        case .hexapawn:
            basicGame = Hexapawn()
        case .hiLo:
            basicGame = HiLo()
        case .highIQ:
            basicGame = HighIQ()
        case .hockey:
            basicGame = Hockey()
        case .horserace:
            basicGame = Horserace()
        case .hurkle:
            basicGame = Hurkle()
        case .icbm:
            basicGame = ICBM()
        case .joust:
            basicGame = Joust()
        case .kinema:
            basicGame = Kinema()
        case .king:
            basicGame = King()
        case .letter:
            basicGame = Letter()
        case .life:
            basicGame = Life()
        case .lifeForTwo:
            basicGame = Life2()
        case .literatureQuiz:
            basicGame = LiteratureQuiz()
        case .love:
            basicGame = Love()
        case .lunar:
            basicGame = Lunar()
        case .lem:
            basicGame = LEM()
        case .rocket:
            basicGame = Rocket()
        case .masterMind:
            basicGame = MasterMind()
        case .mathDice:
            basicGame = MathDice()
        case .mugwump:
            basicGame = Mugwump()
        case .name:
            basicGame = Name()
        case .nicomachus:
            basicGame = Nicomachus()
        case .nim:
            basicGame = Nim()
        case .number:
            basicGame = Number()
        case .oneCheck:
            basicGame = OneCheck()
        case .orbit:
            basicGame = Orbit()
        case .oregonTrail:
            basicGame = OregonTrail()
        case .pizza:
            basicGame = Pizza()
        case .poetry:
            basicGame = Poetry()
        case .poker:
            basicGame = Poker()
        case .queen:
            basicGame = Queen()
        case .reverse:
            basicGame = Reverse()
        case .rockScissorsPaper:
            basicGame = RockScissorsPaper()
        case .roulette:
            basicGame = Roulette()
        case .russianRoulette:
            //TODO: throw error or hide game before release
//            throw RuntimeError("'\(game)' not available.")
            basicGame = RussianRoulette()
        case .salvo:
            basicGame = Salvo()
        case .sineWave:
            basicGame = SineWave()
        case .slalom:
            basicGame = Slalom()
        case .slots:
            basicGame = Slots()
        case .splat:
            basicGame = Splat()
        case .starTrek:
            basicGame = StarTrek()
        case .stars:
            basicGame = Stars()
        case .stockMarket:
            basicGame = StockMarket()
        case .synonym:
            basicGame = Synonym()
        case .target:
            basicGame = Target()
        case .threeDPlot:
            basicGame = TDPlot()
        case .threeDTicTacToe:
            throw RuntimeError("'\(game)' not implemented.")
        case .ticTacToe1:
            basicGame = TicTacToe1()
        case .ticTacToe2:
            basicGame = TicTacToe2()
        case .tower:
            basicGame = Tower()
        case .train:
            basicGame = Train()
        case .trap:
            basicGame = Trap()
        case .twentyThreeMatches:
            basicGame = TwentyThreeMatches()
        case .war:
            basicGame = War()
        case .weekday:
            basicGame = Weekday()
        case .word:
            basicGame = Word()
        }

        if test {
            basicGame.test()
        } else {
            basicGame.run()
        }
    }
}


struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
