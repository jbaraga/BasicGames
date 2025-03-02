//
//  Game.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import Foundation
import SwiftUI
import PDFKit

enum Game: String, CaseIterable, Codable, CustomStringConvertible {
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
    case starTrek
    case stars
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
    
    var description: String {
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
        case .starTrek: return "Star Trek"
        case .stars: return "Stars"
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
        case .starTrek: return .space
        case .stars: return .characterGuessing
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
    
    //For file in bundle
    var pdfFilepath: String {
        switch self {
        case .icbm, .joust: return URL.basicGamesScheme + ":///BasicGames2.pdf"
        case .oregonTrail: return URL.basicGamesScheme + ":///OregonTrail.pdf"
        default:
            return Self.basicGamesPath
        }
    }
    
    //Page numbers in BasicGames.pdf
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
        case .starTrek: return 171...177
        case .stars: return 167...167
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
    
    var eggURL: URL? {
        if let pdfPageNumbers {
            return URL(string: pdfFilepath + "#pages=" + pdfPageNumbers.description)
        } else {
            return URL(string: pdfFilepath)
        }
    }
    
    static var basicGamesPath: String { URL.basicGamesScheme + ":///BasicGames.pdf" }
    
    static var basicGamesIntroURL: URL? {
        URL(string: Self.basicGamesPath + "#pages=" + (1...15).description)
    }
    
    static var basicGamesAppendixURL: URL? {
        URL(string: Self.basicGamesPath + "#pages=" + (197...201).description)
    }
    
    var unlockURL: URL? {
        return URL(string: URL.basicGamesScheme + ":///#game=" + rawValue)
    }
    
    var preferredSet: Set<String> { Set([unlockURL].compactMap { $0?.absoluteString }) }
        
    var imageName: String { description }
    
    var imageSystemName: String? {
        switch self {
        case .aceyDucey: return "suit.heart.fill"
        case .animal: return "pawprint.fill"
        case .awari: return "globe.europe.africa"
        case .basketball: return "basketball.fill"
        case .battle: return "ferry"
        case .blackjack: return "suit.club.fill"
        case .bowling: return "figure.bowling"
        case .boxing: return "figure.boxing.circle"
        case .bullfight: return "figure.strengthtraining.functional"
        case .bullseye: return "target"
        case .bug: return "ladybug"
        case .bunny: return "hare"
        case .buzzword: return "text.bubble"
        case .calendar: return "calendar"
        case .change: return "dollarsign.circle"
        case .checkers: return "rectangle.checkered"
        case .chemist: return "flask"
        case .chief: return "bolt"
        case .chomp: return "fork.knife.circle"
        case .combat: return "helmet"
        case .craps: return "dice.fill"
        case .cube: return "cube"
        case .diamond: return "diamond.fill"
        case .dice: return "dice"
        case .digits: return "hand.raised.fingers.spread.fill"
        case .evenWins1, .evenWins2: return "circle.hexagongrid.circle"
        case .flipFlop: return "x.circle"
        case .furTrader: return "hare"
        case .golf: return "figure.golf"
        case .gomoko: return "5.square"
        case .guess: return "questionmark.app"
        case .gunner: return "dot.scope"
        case .hamurabi: return "crown.fill"
        case .hangman: return "figure"
        case .hello: return "text.bubble"
        case .hexapawn: return "person.bust.fill"
        case .hiLo: return "arrow.up.arrow.down"
        case .highIQ: return "brain"
        case .hockey: return "figure.hockey"
        case .horserace: return "figure.equestrian.sports"
        case .hurkle: return "squareshape.split.3x3"
        case .joust: return "shield.pattern.checkered"
        case .kinema: return "cricket.ball"
        case .king: return "crown.fill"
        case .letter: return "characters.uppercase"
        case .life: return "microbe"
        case .lifeForTwo: return "microbe.fill"
        case .literatureQuiz: return "book.pages"
        case .love: return "heart"
        case .masterMind: return "brain.fill"
        case .mathDice: return "dice.fill"
        case .mugwump: return "mug"
        case .name: return "person.circle"
        case .nicomachus: return "divide.circle"
        case .nim: return "minus.circle"
        case .number: return "number.circle.fill"
        case .oneCheck: return "01.square"
        case .orbit: return "atom"
        case .poetry: return "text.alignleft"
        case .poker: return "suit.spade.fill"
        case .queen: return "crown"
        case .reverse: return "arrow.left.arrow.right.square"
        case .rockScissorsPaper: return "scissors"
        case .roulette: return "00.circle"
        case .russianRoulette: return "die.face.6"
        case .salvo: return "scope"
        case .sineWave: return "water.waves"
        case .slalom: return "figure.skiing.downhill"
        case .slots: return "entry.lever.keypad"
        case .stars: return "staroflife.fill"
        case .stockMarket: return "chart.line.uptrend.xyaxis.circle.fill"
        case .synonym: return "repeat.circle"
        case .target: return "dot.scope"
        case .threeDPlot: return "view.3d"
        case .threeDTicTacToe: return "square.3.layers.3d"
        case .ticTacToe1: return "grid"
        case .ticTacToe2: return "grid"
        case .tower: return "building.2.crop.circle"
        case .train: return "tram"
        case .trap: return "numbers.rectangle"
        case .twentyThreeMatches: return "flame"
        case .war: return "suit.diamond.fill"
        case .word: return "questionmark.circle.dashed"
        default:
            return nil
        }
    }
    
    var imageTint: Color? {
        switch self {
        case .aceyDucey: return .red
        case .animal: return .brown
        case .awari: return .orange
        case .basketball: return .brown
        case .batnum: return .orange
        case .battle: return .gray
        case .blackjack: return .black
        case .bombardment: return .blue
        case .bombsAway: return .indigo
        case .bowling: return .brown
        case .boxing: return .yellow
        case .bug: return .red
        case.bullfight: return .orange
        case .bullseye: return .blue
        case .bunny: return .pink
        case .buzzword: return .teal
        case .calendar: return .purple
        case .change: return .green
        case .checkers: return .red
        case .chemist: return .blue
        case .chief: return .yellow
        case .chomp: return .red
        case .combat: return .gray
        case .craps: return .white
        case .cube: return .green
        case .diamond: return .blue
        case .dice: return .yellow
        case .digits: return .teal
        case .evenWins1: return .indigo
        case .evenWins2: return .blue
        case .flipFlop: return .yellow
        case .furTrader: return .white
        case .golf: return .brown
        case .gomoko: return .green
        case .guess: return .mint
        case .gunner: return .red
        case .hamurabi: return .purple
        case .hangman: return .brown
        case .hello: return .yellow
        case .hexapawn: return .brown
        case .hiLo: return .blue
        case .highIQ: return .pink
        case .hockey: return .green
        case .horserace: return .brown
        case .hurkle: return .teal
        case .joust: return .orange
        case .kinema: return .purple
        case .king: return .indigo
        case .letter: return .pink
        case .life: return .green
        case .lifeForTwo: return .teal
        case .literatureQuiz: return .blue
        case .love: return .red
        case .masterMind: return .brown
        case .mathDice: return .yellow
        case .mugwump: return .red
        case .name: return .brown
        case .nicomachus: return .indigo
        case .nim: return .green
        case .number: return .teal
        case .oneCheck: return .orange
        case .orbit: return .blue
        case .poetry: return .teal
        case .poker: return .black
        case .queen: return .pink
        case .reverse: return .purple
        case .rockScissorsPaper: return .orange
        case .roulette: return .cyan
        case .russianRoulette: return .yellow
        case .salvo: return .gray
        case .sineWave: return .teal
        case .slalom: return .purple
        case .slots: return .indigo
        case .stars: return .green
        case .starTrek: return .blue
        case .stockMarket: return .purple
        case .synonym: return .orange
        case .target: return .blue
        case .threeDPlot: return .indigo
        case.threeDTicTacToe: return .green
        case .ticTacToe1: return .red
        case .ticTacToe2: return .blue
        case .tower: return .yellow
        case .train: return .green
        case .trap: return .teal
        case .twentyThreeMatches: return .orange
        case .war: return .red
        case .word: return .purple
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
    #if DEBUG
    case completed
    case notCompleted
    #endif
    
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
        #if DEBUG
        case .completed: return "Completed"
        case .notCompleted: return "Not Completed"
        #endif
        }
    }
    
    var id: Category { self }
    
    var games: [Game] {
        switch self {
        case .all: return Game.allCases
        #if DEBUG
        case .completed: return Game.allCases.filter { $0.imageSystemName != nil || Bundle.main.image(forResource: $0.imageName) != nil }
        case .notCompleted: return Game.allCases.filter { $0.imageSystemName == nil && Bundle.main.image(forResource: $0.imageName) == nil }
        #endif
        default:
            return Game.allCases.filter { $0.category == self }
        }
    }
}
