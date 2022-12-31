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
    case football
    case ftball
    case icbm
    case joust
    case lunar
    case lem
    case rocket
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
        case .football: return "Football"
        case .ftball: return "Ftball"
        case .icbm: return "ICBM"
        case .joust: return "Joust"
        case .lunar: return "Lunar"
        case .lem: return "LEM"
        case .rocket: return "Rocket"
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
        case .blackjack: return .cardAndBoard
        case .bounce: return .plot
        case .calendar: return .plot
        case .depthCharge: return .matrixManipulation
        case .football: return .sports
        case .ftball: return .sports
        case .icbm: return .combat
        case .joust: return .combat
        case .lunar: return .space
        case .lem: return .space
        case .rocket: return .space
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
        return stringValue.replacingOccurrences(of: " ", with: "")
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
        case .animal: return .black
        case .blackjack: return .black
        case .calendar: return .green
        case .starTrek: return .blue
        case .stockMarket: return .purple
        case .target: return .red
        case .threeDPlot: return .black
        default:
            return nil
        }
    }
    
    var urlString: String {
        return "basicGames://" + rawValue
    }

    var url: URL? {
        return URL(string: urlString)
    }
    
    var set: Set<String> {
        return Set([urlString])
    }
        
    init?(url: URL) {
        if let game = Game.allCases.first(where: { $0.url == url }) {
            self = game
        } else {
            return nil
        }
    }
    
    static var allGamesSet: Set<String> {
        return Set(allCases.compactMap { $0.urlString })
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
}
