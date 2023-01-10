//
//  Game.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import Foundation
import SwiftUI
import PDFKit

enum Game: String, CaseIterable {
    case aceyDucey
    case amazing
    case animal
    case banner
    case blackjack
    case bounce
    case calendar
    case depthCharge
    case digits
    case evenWins1
    case evenWins2
    case football
    case ftball
    case guess
    case icbm
    case joust
    case lunar
    case lem
    case rocket
    case orbit
    case oregonTrail
    case splat
    case starTrek
    case stockMarket
    case target
    case threeDPlot
    case weekday
    
    var stringValue: String {
        switch self {
        case .aceyDucey: return "Acey Ducey"
        case .amazing: return "Amazing"
        case .animal: return "Animal"
        case .banner: return "Banner"
        case .blackjack: return "Blackjack"
        case .bounce: return "Bounce"
        case .calendar: return "Calendar"
        case .depthCharge: return "Depth Charge"
        case .digits: return "Digits"
        case .evenWins1: return "Even Wins (version 1)"
        case .evenWins2: return "Even Wins (version 2)"
        case .football: return "Football"
        case .ftball: return "Ftball"
        case .guess: return "Guess"
        case .icbm: return "ICBM"
        case .joust: return "Joust"
        case .lunar: return "Lunar"
        case .lem: return "LEM"
        case .rocket: return "Rocket"
        case .orbit: return "Orbit"
        case .oregonTrail: return "Oregon Trail"
        case .splat: return "Splat"
        case .starTrek: return "Star Trek"
        case .stockMarket: return "Stock Market"
        case .target: return "Target"
        case .threeDPlot: return "3D Plot"
        case .weekday: return "Weekday"
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
        case .banner: return .plot
        case .blackjack: return .gambling
        case .bounce: return .plot
        case .calendar: return .plot
        case .depthCharge: return .matrixManipulation
        case .digits: return .logic
        case .evenWins1: return .removeObject
        case .evenWins2: return .removeObject
        case .football: return .sports
        case .ftball: return .sports
        case .guess: return .characterGuessing
        case .icbm: return .combat
        case .joust: return .combat
        case .lunar: return .space
        case .lem: return .space
        case .rocket: return .space
        case .orbit: return .space
        case .oregonTrail: return .educational
        case .splat: return .space
        case .starTrek: return .space
        case .stockMarket: return .educational
        case .target: return .space
        case .threeDPlot: return .plot
        case .weekday: return .introductoryFun
        }
    }
    
    var executableName: String {
        switch self {
        case .evenWins1:
            return "EvenWins1"
        case .evenWins2:
            return "EvenWins2"
        default:
            return stringValue.replacingOccurrences(of: " ", with: "")
        }
    }
    
    var imageName: String {
        return stringValue
    }
    
    var imageSystemName: String? {
        switch self {
        case .aceyDucey:
            return "suit.heart.fill"
        case .animal:
            return "pawprint.fill"
        case .blackjack:
            return "suit.club.fill"
        case .calendar:
            return "calendar"
        case .digits:
            return "hand.raised.fingers.spread.fill"
        case .evenWins2:
            return "circle.hexagongrid.circle"
        case .guess:
            return "questionmark.app"
        case .orbit:
            return "atom"
        case .stockMarket:
            return "chart.line.uptrend.xyaxis.circle.fill"
        case .target:
            return "target"
        case .threeDPlot:
            return "view.3d"
        default:
            return nil
        }
    }
    
    var imageTint: Color? {
        switch self {
        case .aceyDucey: return .red
        case .animal: return .brown
        case .blackjack: return .black
        case .calendar: return .green
        case .digits: return .teal
        case .evenWins2: return .blue
        case .guess: return .mint
        case .orbit: return .blue
        case .starTrek: return .blue
        case .stockMarket: return .purple
        case .target: return .red
        case .threeDPlot: return .indigo
        default:
            return nil
        }
    }
    
    var urlString: String {
        return Self.baseURLString + rawValue
    }

    var url: URL? {
        return URL(string: urlString)
    }
    
    var set: Set<String> {
        return Set([urlString])
    }
    
    var pdfFilename: String {
        switch self {
        case .aceyDucey:
            return "101_123022"
        case .amazing:
            return "101_121818"
        case .animal:
            return "101_031622"
        case .banner:
            return "101_021422"
        case .blackjack:
            return "101_022022"
        case .bounce:
            return "101_032722"
        case .calendar:
            return "101_021922"
        case .depthCharge:
            return "101_021222"
        case .digits:
            return "101_010223"
        case .evenWins1, .evenWins2:
            return "101_010823"
        case .football:
            return "101_022222"
        case .ftball:
            return "101_022222"
        case .guess:
            return "101_123122"
        case .icbm:
            return "101_021322"
        case .joust:
            return "101_021122"
        case .lunar:
            return "101_010222"
        case .lem:
            return "101_010222"
        case .rocket:
            return "101_010222"
        case .orbit:
            return "101_010123"
        case .oregonTrail:
            return "101_103018"
        case .splat:
            return "101_032222"
        case .starTrek:
            return "101_020522"
        case .stockMarket:
            return "101_032022"
        case .target:
            return "101_032422"
        case .threeDPlot:
            return "101_031922"
        case .weekday:
            return "101_021722"
        }
    }
        
    init?(url: URL) {
        if let game = Game.allCases.first(where: { $0.url == url }) {
            self = game
        } else {
            return nil
        }
    }
    
    static let baseURLString = "basicGames://"
    
    static var allGamesSet: Set<String> {
        return Set(allCases.compactMap { $0.urlString })
    }
    
    static var eggURLString: String {
        return "basicGames://easterEgg"
    }

    static var eggURL: URL? {
        return URL(string: Self.eggURLString)
    }
    
    static var eggSet: Set<String> {
        return Set([Self.eggURLString])
    }
}


enum Category: String, CaseIterable, Identifiable {
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
        case .all:
            return "All Games"
        case .introductoryFun:
            return "Introductory Fun"
        case .educational:
            return "Educational"
        case .plot:
            return "Plotting and Pictures"
        case .characterGuessing:
            return "Number or Letter Guessing"
        case .removeObject:
            return "Remove an Object"
        case .matrixManipulation:
            return "Matrix Manipulation"
        case .logic:
            return "Logic"
        case .space:
            return "Space"
        case .sports:
            return "Sports Simulation"
        case .gambling:
            return "Gambling and Casino"
        case .cardAndBoard:
            return "Card and Board"
        case .combat:
            return "Combat"
        }
    }
    
    var id: Category { self }
    
    func count(_ games: [Game]) -> Int {
        if self == .all { return games.count }
        return (games.filter { $0.category == self }).count
    }
}
