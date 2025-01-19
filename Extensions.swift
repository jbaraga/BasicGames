//
//  Extensions.swift
//  OregonTrail
//
//  Created by Joseph Baraga on 10/30/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation
import Cocoa
import PDFKit


extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

extension String {
    var isYes: Bool {
        return self.lowercased().hasPrefix("y")
    }

    var isNo: Bool {
        return self.lowercased().hasPrefix("n")
    }

    var isEasterEgg: Bool {
        return self.lowercased() == "shadow"
    }

    func padded(to length: Int) -> String {
        return self.padding(toLength: length, withPad: " ", startingAt: 0)
    }

    func left(_ length: Int) -> String {
        return String(self.prefix(length))
    }

    func right(_ length: Int) -> String {
        return String(self.suffix(length))
    }

    func removingFirst(_ k: Int) -> String {
        var string = self
        string.removeFirst(k)
        return string
    }

    /// BASIC substring function
    /// - Parameters:
    ///   - index: one indexed location
    ///   - length: length of substring
    /// - Returns: String
    func mid(_ index: Int, length: Int) -> String {
        guard index > 0, index <= self.count else { return "" }
        let range = String.Index(utf16Offset: index - 1, in: self)...String.Index(utf16Offset: index + length - 2, in: self)
        return String(self[range])
    }
}


/// Fuzzy match of string to yes or no
enum Response {
    case yes
    case no
    case other
    
    init(_ string: String) {
        switch string {
        case _ where string.isYes: self = .yes
        case _ where string.isNo: self = .no
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
    
    var code: Int {
        switch self {
        case .yes: return 1
        case .no: return 0
        case .other: return -1
        }
    }
}


//MARK: Number Formatting
struct BasicFormatStyle: FormatStyle {
    func format(_ value: Double) -> String {
        if value == 0 || (abs(value) < 1e6 && abs(value) > 1e-6) {
            return value.formatted(.number
                .precision(.significantDigits(0...6))
                .grouping(.never)
            )
        } else {
            return value.formatted(.number
                .notation(.scientific)
                .precision(.significantDigits(0...6))
            )
        }
    }
}

extension FormatStyle where Self == BasicFormatStyle {
    static var basic: BasicFormatStyle { .init() }
}

//Improved subscripting notation for 2d array
extension Array where Element == [Int] {
    subscript(_ row: Int, _ column: Int) -> Element.Element {
        get {
            return self[row][column]
        }
        set {
            self[row][column] = newValue
        }
    }
}

extension Array where Element == [String] {
    subscript(_ row: Int, _ column: Int) -> Element.Element {
        get {
            return self[row][column]
        }
        set {
            self[row][column] = newValue
        }
    }
}

/// Create 2 dimensional array of Integer
/// - Parameters:
///   - rows: # of rows
///   - columns: # of columns
///   - value: initial value for each element
/// - Returns: 2-d integer array of dimensions row x column [row, column] with each element set to value
func dim(_ rows: Int, _ columns: Int, value: Int = 0) -> [[Int]] {
    return Array(repeating: Array(repeating: value, count: columns), count: rows)
}

/// Create 2 dimensional array of type T
/// - Parameters:
///   - rows: # of rows
///   - columns: # of columns
///   - value: initial value for each element
/// - Returns: 2-d T array of dimensions row x column [row, column] with each element set to value
func dim<T>(_ rows: Int, _ columns: Int, value: T) -> [[T]] {
    return Array(repeating: Array(repeating: value, count: columns), count: rows)
}

extension Notification.Name {
    static let terminalCommand = Notification.Name("com.starwaresoftware.basicGames.terminalCommand")
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


extension NSScreen {
    //Pixels per inch
    var scale: NSSize? {
        return self.deviceDescription[.resolution] as? NSSize
    }
    
    func size(for width: CGFloat, height: CGFloat) -> NSSize? {
        guard let scale else { return nil }
        return NSSize(width: width * scale.width, height: height * scale.height)
    }
}

extension NSView {
    func firstSubview<T>(ofType type: T.Type) -> T? {
        for subview in subviews {
            if let subview = subview as? T {
                return subview
            } else if let subview = subview.firstSubview(ofType: type) {
                return subview
            }
        }
        return nil
    }
}

extension PDFDocument {
    static let pwd: String = {
        let data = Data([116, 75, 82, 107, 107, 66, 117, 71, 75, 68, 67, 114, 73, 57, 52, 87, 88, 70, 82, 88, 122, 72, 83, 114, 106, 52, 74, 78, 120, 65, 105])
        return String(data: data, encoding: .utf8) ?? ""
    }()
    
    convenience init(document: PDFDocument, pageNumbers: ClosedRange<Int>) {
        document.unlock(withPassword: Self.pwd)
        self.init()
        let pages = pageNumbers.compactMap { document.page(at: $0 - 1) }  //Page numbers in sidebar are 1 indexed, in PDFDocument are 0 indexed
        pages.forEach { self.insert($0, at: self.pageCount) }
    }
}

extension URL {
    static let basicGamesScheme = "basicgames"
}

extension ClosedRange<Int> {
    init?(string: String) {
        let components = string.components(separatedBy: "...")
        guard components.count == 2, let start = Int(components[0]), let end = Int(components[1]), start <= end else { return nil }
        self = start...end
    }
}


/// ANSI/VT100 Terminal Control Escape Sequences
/// "\u{1B}[" == Control Sequence Introducer
/// SwiftTerm does not support all sequences
/// break is special internal sequence, not part of ANSI specification
/// https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
public enum TerminalCommand: String, CaseIterable, Codable {
    case reset = "\u{1B}[c"
    case cursorPosition = "\u{1B}[6n"
    case cursorHome = "\u{1B}[H"
    case cursorForward = "\u{1B}[1C"
    case cursorBack = "\u{1B}[1D"
    case cursorUp = "\u{1B}[1A"
    case cursorSavePosition = "\u{1B}7"
    case cursorRestorePosition = "\u{1B}8"
    case delete = "\u{7F}"
    case eraseLineToCursor = "\u{1B}[1K"
    case eraseLine = "\u{1B}[2K"
    case eraseScreenToCursor = "\u{1B}[1J"
    case clearScreen = "\u{1B}[2J"
    case printScreen = "\u{1B}[i"
    case bell = "\u{7}"
    case `break` = "\u{18}"  //ascii cancel, used internally
    
    var escapeSequence: String { return rawValue}
    
    var description: String {
        switch self {
        case .reset: return "Reset"
        case .cursorPosition: return "Cursor Position"
        case .cursorHome: return "Cursor Home"
        case .cursorForward: return "Cursor Forward"
        case .cursorBack: return "Cursor Back"
        case .cursorUp: return "Cursor Up"
        case .cursorSavePosition: return "Cursor Save Position"
        case .cursorRestorePosition: return "Cursor Restore Position"
        case .delete: return "Delete"
        case .eraseLineToCursor: return "Erase Line to Cursor"
        case .eraseLine: return "Erase Line"
        case .eraseScreenToCursor: return "Erase Screen to Cursor"
        case .clearScreen: return "Clear Screen"
        case .printScreen: return "Print Screen"
        case .bell: return "Bell"
        case .break: return "Break"
        }
    }
    
    static func moveCursorUp(lines: Int) -> String {
        return "\u{1B}[\(lines)A"
    }
}

extension TerminalCommand: Identifiable {
    public var id: TerminalCommand { self }
}


//https://stackoverflow.com/questions/39889568/how-to-transpose-an-array-more-swiftly
extension Collection where Self.Iterator.Element: RandomAccessCollection {
    // PRECONDITION: `self` must be rectangular, i.e. every row has equal size.
    func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
        guard let row = self.first else { return [] }
        return row.indices.map { index in
            self.map { $0[index] }
        }
    }
    
    func flipped() -> [[Self.Iterator.Element.Iterator.Element]] {
        return self.map { $0.reversed() }
    }
}


