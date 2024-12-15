//
//  Game.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import Foundation
import SwiftUI
import PDFKit

enum Game: String, CaseIterable, Codable {
    case aceyDucey
    case amazing
    case animal
    case awari
    case bagels
    case banner
    case basketball
    case batnum
    case battle
    case blackjack
    case bombardment
    case bombsAway
    case bounce
    case bowling
    case boxing
    case bug
    case bullfight
    case bullseye
    case bunny
    case buzzword
    case calendar
    case change
    case checkers
    case chemist
    case chief
    case chomp
    case civilWar
    case combat
    case craps
    case cube
    case depthCharge
    case diamond
    case dice
    case digits
    case evenWins1
    case evenWins2
    case flipFlop
    case football
    case ftball
    case furTrader
    case golf
    case gomoko
    case guess
    case gunner
    case hamurabi
    case hangman
    case hello
    case hexapawn
    case hiLo
    case highIQ
    case hockey
    case horserace
    case hurkle
    case icbm
    case joust
    case kinema
    case king
    case letter
    case life
    case lifeForTwo
    case literatureQuiz
    case love
    case lunar
    case lem
    case rocket
    case masterMind
    case mathDice
    case mugwump
    case name
    case nicomachus
    case nim
    case number
    case oneCheck
    case orbit
    case oregonTrail
    case pizza
    case poetry
    case poker
    case queen
    case reverse
    case rockScissorsPaper
    case roulette
    case russianRoulette
    case salvo
    case sineWave
    case slalom
    case slots
    case splat
    case stars
    case starTrek
    case stockMarket
    case synonym
    case target
    case threeDPlot
    case threeDTicTacToe
    case ticTacToe1
    case ticTacToe2
    case tower
    case train
    case trap
    case twentyThreeMatches
    case war
    case weekday
    case word
    
    var stringValue: String {
        switch self {
        case .aceyDucey: return "Acey Ducey"
        case .amazing: return "Amazing"
        case .animal: return "Animal"
        case .awari: return "Awari"
        case .bagels: return "Bagels"
        case .banner: return "Banner"
        case .basketball: return "Basketball"
        case .blackjack: return "Blackjack"
        case .batnum: return "Batnum"
        case .battle: return "Battle"
        case .bombardment: return "Bombardment"
        case .bombsAway: return "Bombs Away"
        case .bounce: return "Bounce"
        case .bowling: return "Bowling"
        case .boxing: return "Boxing"
        case .bug: return "Bug"
        case .bullfight: return "Bullfight"
        case .bullseye: return "Bullseye"
        case .bunny: return "Bunny"
        case .buzzword: return "Buzzword"
        case .calendar: return "Calendar"
        case .change: return "Change"
        case .checkers: return "Checkers"
        case .chemist: return "Chemist"
        case .chief: return "Chief"
        case .chomp: return "Chomp"
        case .civilWar: return "Civil War"
        case .combat: return "Combat"
        case .craps: return "Craps"
        case .cube: return "Cube"
        case .depthCharge: return "Depth Charge"
        case .diamond: return "Diamond"
        case .dice: return "Dice"
        case .digits: return "Digits"
        case .evenWins1: return "Even Wins (v1)"
        case .evenWins2: return "Even Wins (v2)"
        case .flipFlop: return "Flip Flop"
        case .football: return "Football"
        case .ftball: return "Ftball"
        case .furTrader: return "Fur Trader"
        case .golf: return "Golf"
        case .gomoko: return "Gomoko"
        case .guess: return "Guess"
        case .gunner: return "Gunner"
        case .hamurabi: return "Hamurabi"
        case .hangman: return "Hangman"
        case .hello: return "Hello"
        case .hexapawn: return "Hexapawn"
        case .hiLo: return "Hi-Lo"
        case .highIQ: return "High I-Q"
        case .hockey: return "Hockey"
        case .horserace: return "Horserace"
        case .hurkle: return "Hurkle"
        case .icbm: return "ICBM"
        case .joust: return "Joust"
        case .kinema: return "Kinema"
        case .king: return "King"
        case .letter: return "Letter"
        case .life: return "Life"
        case .lifeForTwo: return "Life for Two"
        case .literatureQuiz: return "Literature Quiz"
        case .love: return "Love"
        case .lunar: return "Lunar"
        case .lem: return "LEM"
        case .rocket: return "Rocket"
        case .masterMind: return "Master Mind"
        case .mathDice: return "Math Dice"
        case .mugwump: return "Mugwump"
        case .name: return "Name"
        case .nicomachus: return "Nicomachus"
        case .nim: return "Nim"
        case .number: return "Number"
        case .oneCheck: return "One Check"
        case .orbit: return "Orbit"
        case .oregonTrail: return "Oregon Trail"
        case .pizza: return "Pizza"
        case .poetry: return "Poetry"
        case .poker: return "Poker"
        case .queen: return "Queen"
        case .reverse: return "Reverse"
        case .rockScissorsPaper: return "Rock, Scissors, Paper"
        case .roulette: return "Roulette"
        case .russianRoulette: return "Russian Roulette"
        case .salvo: return "Salvo"
        case .sineWave: return "Sine Wave"
        case .slalom: return "Slalom"
        case .slots: return "Slots"
        case .splat: return "Splat"
        case .stars: return "Stars"
        case .starTrek: return "Star Trek"
        case .stockMarket: return "Stock Market"
        case .synonym: return "Synonym"
        case .target: return "Target"
        case .threeDPlot: return "3-D Plot"
        case .threeDTicTacToe: return "3-D Tic-Tac-Toe"
        case .ticTacToe1: return "Tic Tac Toe (v1)"
        case .ticTacToe2: return "Tic Tac Toe (v2)"
        case .tower: return "Tower"
        case .train: return "Train"
        case .trap: return "Trap"
        case .twentyThreeMatches: return "23 Matches"
        case .war: return "War"
        case .weekday: return "Weekday"
        case .word: return "Word"
        }
    }
    
    var title: String {
        return stringValue
    }
    
    var category: Category {
        switch self {
        case .aceyDucey: return .cardAndBoard
        case .amazing: return .plot
        case .animal: return .characterGuessing
        case .awari: return .logic
        case .bagels: return .logic
        case .banner: return .plot
        case .basketball: return .sports
        case .batnum: return .removeObject
        case .battle: return .matrixManipulation
        case .blackjack: return .gambling
        case .bombardment: return .matrixManipulation
        case .bombsAway: return .combat
        case .bounce: return .plot
        case .bowling: return .sports
        case .boxing: return .sports
        case .bug: return .plot
        case .bullfight: return .sports
        case .bullseye: return .sports
        case .bunny: return .plot
        case .buzzword: return .introductoryFun
        case .calendar: return .plot
        case .change: return .educational
        case .checkers: return .cardAndBoard
        case .chemist: return .educational
        case .chief: return .educational
        case .chomp: return .logic
        case .civilWar: return .educational
        case .combat: return .combat
        case .craps: return .gambling
        case .cube: return .logic
        case .depthCharge: return .matrixManipulation
        case .diamond: return .plot
        case .dice: return .gambling
        case .digits: return .logic
        case .evenWins1: return .removeObject
        case .evenWins2: return .removeObject
        case .flipFlop: return .logic
        case .football: return .sports
        case .ftball: return .sports
        case .furTrader: return .educational
        case .golf: return .sports
        case .gomoko: return .cardAndBoard
        case .guess: return .characterGuessing
        case .gunner: return .combat
        case .hamurabi: return .educational
        case .hangman: return .educational
        case .hello: return .introductoryFun
        case .hexapawn: return .logic
        case .hiLo: return .characterGuessing
        case .highIQ: return .logic
        case .hockey: return .sports
        case .horserace: return .gambling
        case .hurkle: return .matrixManipulation
        case .icbm: return .combat
        case .joust: return .combat
        case .kinema: return .educational
        case .king: return .educational
        case .letter: return .characterGuessing
        case .life: return .plot
        case .lifeForTwo: return .plot
        case .literatureQuiz: return .educational
        case .love: return .plot
        case .lunar: return .space
        case .lem: return .space
        case .rocket: return .space
        case .masterMind: return .logic
        case .mathDice: return .educational
        case .mugwump: return .matrixManipulation
        case .name: return .introductoryFun
        case .nicomachus: return .logic
        case .nim: return .removeObject
        case .number: return .characterGuessing
        case .oneCheck: return .logic
        case .orbit: return .space
        case .oregonTrail: return .educational
        case .pizza: return .matrixManipulation
        case .poetry: return .introductoryFun
        case .poker: return .gambling
        case .queen: return .logic
        case .reverse: return .logic
        case .rockScissorsPaper: return .introductoryFun
        case .roulette: return .gambling
        case .russianRoulette: return .introductoryFun
        case .salvo: return .matrixManipulation
        case .sineWave: return .plot
        case .slalom: return .sports
        case .slots: return .gambling
        case .splat: return .space
        case .stars: return .characterGuessing
        case .starTrek: return .space
        case .stockMarket: return .educational
        case .synonym: return .educational
        case .target: return .space
        case .threeDPlot: return .plot
        case .threeDTicTacToe: return .logic
        case .ticTacToe1, .ticTacToe2: return .logic
        case .tower: return .logic
        case .train: return .educational
        case .trap: return .characterGuessing
        case .twentyThreeMatches: return .removeObject
        case .war: return .cardAndBoard
        case .weekday: return .introductoryFun
        case .word: return .logic
        }
    }
    
    var executableName: String {
        switch self {
        case .evenWins1: return "EvenWins1"
        case .evenWins2: return "EvenWins2"
        default:
            return stringValue.replacingOccurrences(of: " ", with: "")
        }
    }
    
    //If separate pdf, not from BasicGames.pdf
    var pdfFilename: String {
        switch self {
        case .icbm, .joust: return "BasicGames2"
        case .oregonTrail: return executableName
        default:
            return "BasicGames"
        }
    }
    
    //Page numbers in BasicGames.pdf, zero indexed
    var pdfPageNumbers: ClosedRange<Int>? {
        switch self {
        case .aceyDucey: return 16...16
        case .amazing: return 17...17
        case .animal: return 18...19
        case .awari: return 20...22
        case .bagels: return 23...23
        case .banner: return 24...25
        case .basketball: return 26...27
        case .batnum: return 28...28
        case .blackjack: return 32...35
        case .bombardment: return 36...37
        case .bombsAway: return 38...38
        case .bounce: return 39...39
        case .bowling: return 40...41
        case .boxing: return 42...43
        case .bug: return 44...45
        case .bullfight: return 46...47
        case .bullseye: return 48...48
        case .bunny: return 49...49
        case .buzzword: return 50...50
        case .calendar: return 51...52
        case .change: return 53...53
        case .checkers: return 54...55
        case .chemist: return 56...56
        case .chief: return 57...57
        case .chomp: return 58...59
        case .civilWar: return 60...63
        case .combat: return 64...65
        case .craps: return 66...66
        case .cube: return 67...68
        case .depthCharge: return 69...69
        case .diamond: return 70...70
        case .dice: return 71...71
        case .digits: return 72...73
        case .evenWins1, .evenWins2: return 74...76
        case .flipFlop: return 77...77
        case .football, .ftball: return 78...82
        case .furTrader: return 83...84
        case .golf: return 85...87
        case .gomoko: return 88...88
        case .guess: return 89...90
        case .gunner: return 91...91
        case .hamurabi: return 92...93
        case .hangman: return 94...95
        case .hello: return 96...96
        case .hexapawn: return 97...98
        case .hiLo: return 99...99
        case .highIQ: return 100...101
        case .hockey: return 102...105
        case .icbm: return 88...89
        case .joust: return 92...93
        case .kinema: return 109...109
        case .king: return 110...112
        case .letter: return 113...113
        case .life: return 114...115
        case .lifeForTwo: return 116...117
        case .literatureQuiz: return 118...118
        case .love: return 119...119
        case .lunar, .lem, .rocket: return 120...123
        case .masterMind: return 124...126
        case .mathDice: return 127...127
        case .mugwump: return 128...129
        case .name: return 130...130
        case .nicomachus: return 131...131
        case .nim: return 132...134
        case .number: return 135...135
        case .oneCheck: return 136...137
        case .orbit: return 138...139
        case .pizza: return 140...141
        case .poetry: return 142...142
        case .poker: return 143...146
        case .queen: return 147...148
        case .reverse: return 149...150
        case .rockScissorsPaper: return 151...151
        case .roulette: return 152...154
        case .russianRoulette: return 155...155
        case .salvo: return 156...159
        case .sineWave: return 160...160
        case .slalom: return 161...162
        case .slots: return 163...164
        case .splat: return 165...166
        case .stars: return 167...167
        case .starTrek: return 171...177
        case .stockMarket: return 168...170
        case .synonym: return 178...178
        case .target: return 179...180
        case .threeDPlot: return 181...181
        case .threeDTicTacToe: return 182...184
        case .ticTacToe1, .ticTacToe2: return 185...186
        case .tower: return 187...188
        case .train: return 189...189
        case .trap: return 190...190
        case .twentyThreeMatches: return 191...191
        case .war: return 192...192
        case .weekday: return 193...194
        case .word: return 195...196
        default: return nil
        }
    }
    
    //Encoded string for DistributedNotificationCenter notification
    var pdfString: String {
        if let pdfPageNumbers { return pdfFilename + "-" + pdfPageNumbers.description}
        return pdfFilename
    }
    
    var imageName: String { stringValue }
    
    var imageSystemName: String? {
        switch self {
        case .aceyDucey: return "suit.heart.fill"
        case .animal: return "pawprint.fill"
        case .awari: return "globe.europe.africa"
        case .blackjack: return "suit.club.fill"
        case .bowling: return "figure.bowling"
        case .bug: return "ladybug"
        case .calendar: return "calendar"
        case .checkers: return "rectangle.checkered"
        case .digits: return "hand.raised.fingers.spread.fill"
        case .evenWins1, .evenWins2: return "circle.hexagongrid.circle"
        case .guess: return "questionmark.app"
        case .hamurabi: return "crown.fill"
        case .hockey: return "figure.hockey"
        case .king: return "crown"
        case .orbit: return "atom"
        case .poetry: return "text.alignright"
        case .poker: return "suit.spade.fill"
        case .stockMarket: return "chart.line.uptrend.xyaxis.circle.fill"
        case .target: return "target"
        case .threeDPlot: return "view.3d"
        default:
            return nil
        }
    }
    
    var imageTint: Color? {
        switch self {
        case .aceyDucey: return .red
        case .animal: return .brown
        case .awari: return .orange
        case .batnum: return .orange
        case .blackjack: return .black
        case .bowling: return .brown
        case .bug: return .red
        case .calendar: return .green
        case .checkers: return .red
        case .digits: return .teal
        case .evenWins1: return .indigo
        case .evenWins2: return .blue
        case .guess: return .mint
        case .hamurabi: return .purple
        case .hockey: return .green
        case .king: return .indigo
        case .orbit: return .blue
        case .poetry: return .teal
        case .poker: return .black
        case .starTrek: return .blue
        case .stockMarket: return .purple
        case .target: return .red
        case .threeDPlot: return .indigo
        default:
            return nil
        }
    }
}


enum Category: String, CaseIterable, Identifiable, Codable {
    case all
    case introductoryFun
    case educational
    case plot
    case characterGuessing
    case removeObject
    case matrixManipulation
    case logic
    case space
    case sports
    case gambling
    case cardAndBoard
    case combat
    
    var stringValue: String {
        switch self {
        case .all: return "All Games"
        case .introductoryFun: return "Introductory Fun"
        case .educational: return "Educational"
        case .plot: return "Plotting and Pictures"
        case .characterGuessing: return "Number or Letter Guessing"
        case .removeObject: return "Remove an Object"
        case .matrixManipulation: return "Matrix Manipulation"
        case .logic: return "Logic"
        case .space: return "Space"
        case .sports: return "Sports Simulation"
        case .gambling: return "Gambling and Casino"
        case .cardAndBoard: return "Card and Board"
        case .combat: return "Combat"
        }
    }
    
    var id: Category { self }
    
    func count(_ games: [Game]) -> Int {
        if self == .all { return games.count }
        return (games.filter { $0.category == self }).count
    }
}
