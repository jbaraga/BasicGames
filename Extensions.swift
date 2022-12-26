//
//  Extensions.swift
//  OregonTrail
//
//  Created by Joseph Baraga on 10/30/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation
import Cocoa


extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

extension String {
    var isYes: Bool {
        return self.contains("Y") || self.contains("y")
    }
}

extension String {
    var isNo: Bool {
        return self.contains("N") || self.contains("n")
    }
}

extension String {
    var isEasterEgg: Bool {
        return self.lowercased() == "shadow"
    }
}

enum Response {
    case yes
    case no
    case easterEgg
    case other
    
    init(_ string: String) {
        switch string {
        case _ where string.isYes: self = .yes
        case _ where string.isNo: self = .no
        case _ where string.isEasterEgg: self = .easterEgg
        default: self = .other
        }
    }
    
    var isYes: Bool {
        return self == .yes
    }
    
    var isNo: Bool {
        return self == .no
    }
    
    var isYesOrNo: Bool {
        return isYes || isNo
    }
}

extension String {
    func padded(to length: Int) -> String {
        return self.padding(toLength: length, withPad: " ", startingAt: 0)
    }
}

extension String {
    static let deleteCharacter = String(UnicodeScalar(127))
}

extension String {
    func left(_ length: Int) -> String {
        return String(self.prefix(length))
    }
}

extension String {
    func right(_ length: Int) -> String {
        return String(self.suffix(length))
    }
}

extension String {
    func removingFirst(_ k: Int) -> String {
        var string = self
        string.removeFirst(k)
        return string
    }
}

extension String {
    /// BASIC substring function
    /// - Parameters:
    ///   - index: one indexed location
    ///   - length: length of substring
    /// - Returns: String
    func mid(_ index: Int, length: Int) -> String {
        let range = String.Index(utf16Offset: index - 1, in: self)...String.Index(utf16Offset: index + length - 2, in: self)
        return String(self[range])
    }
}

extension NumberFormatter {
    func string(from value: Double) -> String {
        if abs(value) < 1e6 {
            self.numberStyle = .none
        } else {
            self.numberStyle = .scientific
        }
        return string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

//Improved subscripting notation for 2d array
extension Array where Element == [Int] {
    subscript(index: (Int, Int)) -> Element.Element {
        get {
            return self[index.0][index.1]
        }
        set {
            self[index.0][index.1] = newValue
        }
    }
}

extension Notification.Name {
    static let terminalWindowWillClose = Notification.Name("com.starwaresoftware.basicGames.close")
    static let consoleInputDidBegin = Notification.Name("com.starwaresoftware.basicGames.input")
    static let consoleWillPrint = Notification.Name("com.starwaresoftware.basicGames.print")
    static let showEasterEgg = Notification.Name("com.starwaresoftware.basicGames.egg")
}


//MARK: Terminal Colors
extension NSColor {
    static let terminalBackground = NSColor(colorSpace: .deviceRGB, hue: 0, saturation: 0, brightness: 0.1, alpha: 1)
    static let terminalWhite = NSColor(colorSpace: .deviceRGB, hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
    static let terminalGreen = NSColor(red: 100/255, green: 225/255, blue: 100/255, alpha: 1)
    static let terminalBlue = NSColor(red: 75/255, green: 175/255, blue: 255/255, alpha: 1)
    
    var displayName: String {
        switch self {
        case .terminalWhite: return "White"
        case .terminalGreen: return "Green"
        case .terminalBlue: return "Blue"
        default:
            fatalError("Missing terminal color")
        }
    }
    
    static var allTerminalColors: [NSColor] { [.terminalWhite, .terminalGreen, .terminalBlue] }
}


enum Egg {
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

    var filename: String {
        switch self {
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
