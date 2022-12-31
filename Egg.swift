//
//  Egg.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/30/22.
//

import Foundation

enum Egg {
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
    case guess
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

    var filename: String {
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
    
    static var urlString: String {
        return "basicGames://easterEgg"
    }

    static var url: URL? {
        return URL(string: Self.urlString)
    }
    
    static var set: Set<String> {
        return Set([Self.urlString])
    }
}
