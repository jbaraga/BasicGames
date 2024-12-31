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
    
    @Option(name: [.short, .customLong("game")], help: "Game to play. Available games: \n\((Game.allCases.map { $0.rawValue }).joined(separator: ", "))")
    var gameName: String

    func run() throws {
        guard let game = Game(rawValue: gameName) else { throw RuntimeError("Invalid game name.") }
        switch game {
        case .aceyDucey:
            AceyDucey().run()
        case .amazing:
            Amazing().run()
        case .animal:
            Animal().run()
        case .awari:
            Awari().run()
        case .bagels:
            Bagels().run()
        case .banner:
            Banner().run()
        case .basketball:
            throw RuntimeError("\(game) not implemented.")
        case .batnum:
            Batnum().run()
        case .battle:
            throw RuntimeError("\(game) not implemented.")
        case .blackjack:
            Blackjack().run()
        case .bombardment:
            Bombardment().run()
        case .bombsAway:
            BombsAway().run()
        case .bounce:
            Bounce().run()
        case .bowling:
            Bowling().run()
        case .boxing:
            throw RuntimeError("\(game) not implemented.")
        case .bug:
            Bug().run()
        case .bullfight:
            throw RuntimeError("\(game) not implemented.")
        case .bullseye:
            Bullseye().run()
        case .bunny:
            throw RuntimeError("\(game) not implemented.")
        case .buzzword:
            Buzzword().run()
        case .calendar:
            Calendar().run()
        case .change:
            Change().run()
        case .checkers:
            Checkers().run()
        case .chemist:
            Chemist().run()
        case .chief:
            throw RuntimeError("\(game) not implemented.")
        case .chomp:
            throw RuntimeError("\(game) not implemented.")
        case .civilWar:
            CivilWar().run()
        case .combat:
            throw RuntimeError("\(game) not implemented.")
        case .craps:
            throw RuntimeError("\(game) not implemented.")
        case .cube:
            throw RuntimeError("\(game) not implemented.")
        case .depthCharge:
            DepthCharge().run()
        case .diamond:
            Diamond().run()
        case .dice:
            Dice().run()
        case .digits:
            Digits().run()
        case .evenWins1:
            EvenWins1().run()
        case .evenWins2:
            EvenWins2().run()
        case .flipFlop:
            throw RuntimeError("\(game) not implemented.")
        case .football:
            Football().run()
        case .ftball:
            Ftball().run()
        case .furTrader:
            throw RuntimeError("\(game) not implemented.")
        case .golf:
            throw RuntimeError("\(game) not implemented.")
        case .gomoko:
            throw RuntimeError("\(game) not implemented.")
        case .guess:
            Guess().run()
        case .gunner:
            throw RuntimeError("\(game) not implemented.")
        case .hamurabi:
            Hamurabi().run()
        case .hangman:
            Hangman().run()
        case .hello:
            throw RuntimeError("\(game) not implemented.")
        case .hexapawn:
            throw RuntimeError("\(game) not implemented.")
        case .hiLo:
            throw RuntimeError("\(game) not implemented.")
        case .highIQ:
            throw RuntimeError("\(game) not implemented.")
        case .hockey:
            Hockey().run()
        case .horserace:
            throw RuntimeError("\(game) not implemented.")
        case .hurkle:
            throw RuntimeError("\(game) not implemented.")
        case .icbm:
            ICBM().run()
        case .joust:
            Joust().run()
        case .kinema:
            throw RuntimeError("\(game) not implemented.")
        case .king:
            King().run()
        case .letter:
            throw RuntimeError("\(game) not implemented.")
        case .life:
            throw RuntimeError("\(game) not implemented.")
        case .lifeForTwo:
            throw RuntimeError("\(game) not implemented.")
        case .literatureQuiz:
            throw RuntimeError("\(game) not implemented.")
        case .love:
            Love().run()
        case .lunar:
            Lunar().run()
        case .lem:
            LEM().run()
        case .rocket:
            Rocket().run()
        case .masterMind:
            throw RuntimeError("\(game) not implemented.")
        case .mathDice:
            MathDice().run()
        case .mugwump:
            Mugwump().run()
        case .name:
            Name().run()
        case .nicomachus:
            Nicomachus().run()
        case .nim:
            throw RuntimeError("\(game) not implemented.")
        case .number:
            Number().run()
        case .oneCheck:
            throw RuntimeError("\(game) not implemented.")
        case .orbit:
            Orbit().run()
        case .oregonTrail:
            OregonTrail().run()
        case .pizza:
            Pizza().run()
        case .poetry:
            Poetry().run()
        case .poker:
            Poker().run()
        case .queen:
            throw RuntimeError("\(game) not implemented.")
        case .reverse:
            throw RuntimeError("\(game) not implemented.")
        case .rockScissorsPaper:
            RockScissorsPaper().run()
        case .roulette:
            throw RuntimeError("\(game) not implemented.")
        case .russianRoulette:
            throw RuntimeError("\(game) not implemented.")
        case .salvo:
            throw RuntimeError("\(game) not implemented.")
        case .sineWave:
            SineWave().run()
        case .slalom:
            throw RuntimeError("\(game) not implemented.")
        case .slots:
            throw RuntimeError("\(game) not implemented.")
        case .splat:
            Splat().run()
        case .starTrek:
            StarTrek().run()
        case .stars:
            Stars().run()
        case .stockMarket:
            StockMarket().run()
        case .synonym:
            Synonym().run()
        case .target:
            Target().run()
        case .threeDPlot:
            TDPlot().run()
        case .threeDTicTacToe:
            throw RuntimeError("\(game) not implemented.")
        case .ticTacToe1:
            throw RuntimeError("\(game) not implemented.")
        case .ticTacToe2:
            throw RuntimeError("\(game) not implemented.")
        case .tower:
            throw RuntimeError("\(game) not implemented.")
        case .train:
            Train().run()
        case .trap:
            Trap().run()
        case .twentyThreeMatches:
            TwentyThreeMatches().run()
        case .war:
            throw RuntimeError("\(game) not implemented.")
        case .weekday:
            Weekday().run()
        case .word:
            throw RuntimeError("\(game) not implemented.")
        }
    }
}


struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
