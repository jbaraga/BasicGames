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

