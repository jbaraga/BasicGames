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
    case banner
    case blackjack
    case bounce
    case bug
    case calendar
    case checkers
    case civilWar
    case depthCharge
    case digits
    case evenWins1
    case evenWins2
    case football
    case ftball
    case guess
    case hamurabi
    case hockey
    case icbm
    case joust
    case king
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
        case .bug: return "Bug"
        case .calendar: return "Calendar"
        case .checkers: return "Checkers"
        case .civilWar: return "Civil War"
        case .depthCharge: return "Depth Charge"
        case .digits: return "Digits"
        case .evenWins1: return "Even Wins (version 1)"
        case .evenWins2: return "Even Wins (version 2)"
        case .football: return "Football"
        case .ftball: return "Ftball"
        case .guess: return "Guess"
        case .hamurabi: return "Hamurabi"
        case .hockey: return "Hockey"
        case .icbm: return "ICBM"
        case .joust: return "Joust"
        case .king: return "King"
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
        case .bug: return .plot
        case .calendar: return .plot
        case .checkers: return .cardAndBoard
        case .civilWar: return .educational
        case .depthCharge: return .matrixManipulation
        case .digits: return .logic
        case .evenWins1: return .removeObject
        case .evenWins2: return .removeObject
        case .football: return .sports
        case .ftball: return .sports
        case .guess: return .characterGuessing
        case .hamurabi: return .educational
        case .hockey: return .sports
        case .icbm: return .combat
        case .joust: return .combat
        case .king: return .educational
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
        case .evenWins1: return "EvenWins1"
        case .evenWins2: return "EvenWins2"
        default:
            return stringValue.replacingOccurrences(of: " ", with: "")
        }
    }
    
    var pdfFilename: String {
        switch self {
        case .ftball: return "Football"
        case .evenWins1, .evenWins2: return "EvenWins"
        case .lem, .rocket: return "Lunar"
        default:
            return executableName
        }
    }
    
    var imageName: String { stringValue }
    
    var imageSystemName: String? {
        switch self {
        case .aceyDucey: return "suit.heart.fill"
        case .animal: return "pawprint.fill"
        case .blackjack: return "suit.club.fill"
        case .bug: return "ladybug"
        case .calendar: return "calendar"
        case .checkers: return "rectangle.checkered"
        case .digits: return "hand.raised.fingers.spread.fill"
        case .evenWins2: return "circle.hexagongrid.circle"
        case .guess: return "questionmark.app"
        case .hamurabi: return "crown.fill"
        case .hockey: return "figure.hockey"
        case .king: return "crown"
        case .orbit: return "atom"
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
        case .blackjack: return .black
        case .bug: return .red
        case .calendar: return .green
        case .checkers: return .red
        case .digits: return .teal
        case .evenWins2: return .blue
        case .guess: return .mint
        case .hamurabi: return .purple
        case .hockey: return .green
        case .king: return .indigo
        case .orbit: return .blue
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
