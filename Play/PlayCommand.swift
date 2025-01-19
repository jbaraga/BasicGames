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
        if test {
            try self.test(game)
            return
        }
        
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
            throw RuntimeError("'\(game)' not implemented.")
        case .batnum:
            Batnum().run()
        case .battle:
            throw RuntimeError("'\(game)' not implemented.")
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
            throw RuntimeError("'\(game)' not implemented.")
        case .bug:
            Bug().run()
        case .bullfight:
            throw RuntimeError("'\(game)' not implemented.")
        case .bullseye:
            Bullseye().run()
        case .bunny:
            Bunny().run()
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
            Chief().run()
        case .chomp:
            Chomp().run()
        case .civilWar:
            CivilWar().run()
        case .combat:
            throw RuntimeError("'\(game)' not implemented.")
        case .craps:
            Craps().run()
        case .cube:
            Cube().run()
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
            throw RuntimeError("'\(game)' not implemented.")
        case .football:
            Football().run()
        case .ftball:
            Ftball().run()
        case .furTrader:
            throw RuntimeError("'\(game)' not implemented.")
        case .golf:
            Golf().run()
        case .gomoko:
            Gomoko().run()
        case .guess:
            Guess().run()
        case .gunner:
            throw RuntimeError("'\(game)' not implemented.")
        case .hamurabi:
            Hamurabi().run()
        case .hangman:
            Hangman().run()
        case .hello:
            Hello().run()
        case .hexapawn:
            throw RuntimeError("'\(game)' not implemented.")
        case .hiLo:
            HiLo().run()
        case .highIQ:
            throw RuntimeError("'\(game)' not implemented.")
        case .hockey:
            Hockey().run()
        case .horserace:
            throw RuntimeError("'\(game)' not implemented.")
        case .hurkle:
            Hurkle().run()
        case .icbm:
            ICBM().run()
        case .joust:
            Joust().run()
        case .kinema:
            throw RuntimeError("'\(game)' not implemented.")
        case .king:
            King().run()
        case .letter:
            throw RuntimeError("'\(game)' not implemented.")
        case .life:
            Life().run()
        case .lifeForTwo:
            Life2().run()
        case .literatureQuiz:
            throw RuntimeError("'\(game)' not implemented.")
        case .love:
            Love().run()
        case .lunar:
            Lunar().run()
        case .lem:
            LEM().run()
        case .rocket:
            Rocket().run()
        case .masterMind:
            throw RuntimeError("'\(game)' not implemented.")
        case .mathDice:
            MathDice().run()
        case .mugwump:
            Mugwump().run()
        case .name:
            Name().run()
        case .nicomachus:
            Nicomachus().run()
        case .nim:
            throw RuntimeError("'\(game)' not implemented.")
        case .number:
            Number().run()
        case .oneCheck:
            throw RuntimeError("'\(game)' not implemented.")
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
            throw RuntimeError("'\(game)' not implemented.")
        case .reverse:
            Reverse().run()
        case .rockScissorsPaper:
            RockScissorsPaper().run()
        case .roulette:
            throw RuntimeError("'\(game)' not implemented.")
        case .russianRoulette:
            //TODO: throw error or hide game before release
            RussianRoulette().run()
        case .salvo:
            throw RuntimeError("'\(game)' not implemented.")
        case .sineWave:
            SineWave().run()
        case .slalom:
            throw RuntimeError("'\(game)' not implemented.")
        case .slots:
            Slots().run()
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
            throw RuntimeError("'\(game)' not implemented.")
        case .ticTacToe1:
            TicTacToe1().run()
        case .ticTacToe2:
            TicTacToe2().run()
        case .tower:
            throw RuntimeError("'\(game)' not implemented.")
        case .train:
            Train().run()
        case .trap:
            Trap().run()
        case .twentyThreeMatches:
            TwentyThreeMatches().run()
        case .war:
            War().run()
        case .weekday:
            Weekday().run()
        case .word:
            Word().run()
        }
    }
    
    func test(_ game: Game) throws {
        switch game {
        case .aceyDucey:
            AceyDucey().test()
        case .amazing:
            Amazing().test()
        case .animal:
            Animal().test()
        case .awari:
            Awari().test()
        case .bagels:
            Bagels().test()
        case .banner:
            Banner().test()
        case .basketball:
            throw RuntimeError("'\(game)' not implemented.")
        case .batnum:
            Batnum().test()
        case .battle:
            throw RuntimeError("'\(game)' not implemented.")
        case .blackjack:
            Blackjack().test()
        case .bombardment:
            Bombardment().test()
        case .bombsAway:
            BombsAway().test()
        case .bounce:
            Bounce().test()
        case .bowling:
            Bowling().test()
        case .boxing:
            throw RuntimeError("'\(game)' not implemented.")
        case .bug:
            Bug().test()
        case .bullfight:
            throw RuntimeError("'\(game)' not implemented.")
        case .bullseye:
            Bullseye().test()
        case .bunny:
            Bunny().test()
        case .buzzword:
            Buzzword().test()
        case .calendar:
            Calendar().test()
        case .change:
            Change().test()
        case .checkers:
            Checkers().test()
        case .chemist:
            Chemist().test()
        case .chief:
            Chief().test()
        case .chomp:
            throw RuntimeError("'\(game)' not implemented.")
        case .civilWar:
            CivilWar().test()
        case .combat:
            throw RuntimeError("'\(game)' not implemented.")
        case .craps:
            Craps().test()
        case .cube:
            Cube().test()
        case .depthCharge:
            DepthCharge().test()
        case .diamond:
            Diamond().test()
        case .dice:
            Dice().test()
        case .digits:
            Digits().test()
        case .evenWins1:
            EvenWins1().test()
        case .evenWins2:
            EvenWins2().test()
        case .flipFlop:
            throw RuntimeError("'\(game)' not implemented.")
        case .football:
            Football().test()
        case .ftball:
            Ftball().test()
        case .furTrader:
            throw RuntimeError("'\(game)' not implemented.")
        case .golf:
            Golf().test()
        case .gomoko:
            Gomoko().test()
        case .guess:
            Guess().test()
        case .gunner:
            throw RuntimeError("'\(game)' not implemented.")
        case .hamurabi:
            Hamurabi().test()
        case .hangman:
            Hangman().test()
        case .hello:
            Hello().test()
        case .hexapawn:
            throw RuntimeError("'\(game)' not implemented.")
        case .hiLo:
            HiLo().test()
        case .highIQ:
            throw RuntimeError("'\(game)' not implemented.")
        case .hockey:
            Hockey().test()
        case .horserace:
            throw RuntimeError("'\(game)' not implemented.")
        case .hurkle:
            Hurkle().test()
        case .icbm:
            ICBM().test()
        case .joust:
            Joust().test()
        case .kinema:
            throw RuntimeError("'\(game)' not implemented.")
        case .king:
            King().test()
        case .letter:
            throw RuntimeError("'\(game)' not implemented.")
        case .life:
            Life().test()
        case .lifeForTwo:
            Life2().test()
        case .literatureQuiz:
            throw RuntimeError("'\(game)' not implemented.")
        case .love:
            Love().test()
        case .lunar:
            Lunar().test()
        case .lem:
            LEM().test()
        case .rocket:
            Rocket().test()
        case .masterMind:
            throw RuntimeError("'\(game)' not implemented.")
        case .mathDice:
            MathDice().test()
        case .mugwump:
            Mugwump().test()
        case .name:
            Name().test()
        case .nicomachus:
            Nicomachus().test()
        case .nim:
            throw RuntimeError("'\(game)' not implemented.")
        case .number:
            Number().test()
        case .oneCheck:
            throw RuntimeError("'\(game)' not implemented.")
        case .orbit:
            Orbit().test()
        case .oregonTrail:
            OregonTrail().test()
        case .pizza:
            Pizza().test()
        case .poetry:
            Poetry().test()
        case .poker:
            Poker().test()
        case .queen:
            throw RuntimeError("'\(game)' not implemented.")
        case .reverse:
            Reverse().test()
        case .rockScissorsPaper:
            RockScissorsPaper().test()
        case .roulette:
            throw RuntimeError("'\(game)' not implemented.")
        case .russianRoulette:
            //TODO: throw error or hide game before release
            RussianRoulette().test()
        case .salvo:
            throw RuntimeError("'\(game)' not implemented.")
        case .sineWave:
            SineWave().test()
        case .slalom:
            throw RuntimeError("'\(game)' not implemented.")
        case .slots:
            Slots().test()
        case .splat:
            Splat().test()
        case .starTrek:
            StarTrek().test()
        case .stars:
            Stars().test()
        case .stockMarket:
            StockMarket().test()
        case .synonym:
            Synonym().test()
        case .target:
            Target().test()
        case .threeDPlot:
            TDPlot().test()
        case .threeDTicTacToe:
            throw RuntimeError("'\(game)' not implemented.")
        case .ticTacToe1:
            TicTacToe1().test()
        case .ticTacToe2:
            TicTacToe2().test()
        case .tower:
            throw RuntimeError("'\(game)' not implemented.")
        case .train:
            Train().test()
        case .trap:
            Trap().test()
        case .twentyThreeMatches:
            TwentyThreeMatches().test()
        case .war:
            War().test()
        case .weekday:
            Weekday().test()
        case .word:
            Word().test()
        }
    }
}


struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
