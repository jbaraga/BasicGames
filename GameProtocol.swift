//
//  GameProtocol.swift
//  BasicGames
//
//  Created by Joseph Baraga on 1/2/22.
//

import AppKit

/*
 BASIC behavior:
 INT(_:) - rounds Double values in most cases.
 PRINT(_:); - the semicolon suppresses new line. Numeric values are padded with a space before and after
 PRINT(_, _, _) - multiple items separated by column are printed at successive tab stops. Default tab stop is 14
*/

protocol GameProtocol {
    func run()
}

extension GameProtocol {    
    var consoleIO: ConsoleIO { ConsoleIO.shared }
    
    /// BASIC Sign function
    /// - Parameter x: Integer
    /// - Returns: -1 if x is negative, 0 if x is 0, 1 if x is positive
    func sgn(_ x: Int) -> Int {
        return x == 0 ? 0 : (x < 0 ? -1 : 1)
    }
    
    func chr$(_ value: UInt8) -> String {
        let scalar = UnicodeScalar(value)
        return String(Character(scalar))
    }
    
    func wait(_ delay: ConsoleIO.Delay) {
        consoleIO.wait(delay)
    }
    
    /// Returns random Double - matches BASIC function; rnd(1) returns a random number between 0 and 0.999999 per Basic Games book
    /// - Parameters:
    ///   - upperLimit: Double. Default 1.0
    /// - Returns: Random double within range 0..<upperLimit
    func rnd(_ upperLimit: Double = 1) -> Double {
        return Double.random(in: 0..<upperLimit)
    }
    
    /// Moves cursor to tab stop; provides simplified syntax for use with print
    /// - Parameters:
    ///   - x: Tab stop (zero indexed)
    /// - Returns: Closure which generates string with spaces needed move cursor to desired tab stop
    func tab(_ x: Int) -> ConsoleIO.Tab {
        return .init(position: x)
    }
    
    /// Prints string representation of multiple items at successive tab stops
    /// - Parameters:
    ///   - items: Comma separated items to print, item must be Tab or conform to LosslessStringConvertible protocol. For variable tab, insert specified tab stop as item between each item to print, e.g. item1, tab(12), item2, tab(18), item3
    ///   - tabInterval: interval between tab  stops if not specified by tab(n) between LosslessStringConvertible items
    func print(_ items: Any..., tabInterval: Int = 14) {
        var tabStop = 0
        for (index, item) in items.enumerated() {
            switch item {
            case let item as CustomStringConvertible:
                if index + 1 < items.count, items[index + 1] is ConsoleIO.Tab {
                    consoleIO.print(item.description)
                } else {
                    if tabStop > 0 { consoleIO.print(tab: tab(tabStop)) }
                    tabStop += tabInterval
                    consoleIO.print(item.description)
                }
            case let item as ConsoleIO.Tab:
                consoleIO.print(tab: item)
                tabStop = item.position
           default:
                fatalError("Illegal print item: " + String(describing: item))
            }
        }
    }

    /// Prints string representation String(item) of multiple items at successive tab stops, terminating with new line
    /// - Parameters:
    ///   - items: Comma separated items to print, item must be a Tab or conform to LosslessStringConvertible protocol. For variable tab, insert specified tab stop as item between each item to print, e.g. item1, tab(12), item2, tab(18), item3.
    ///   - tabInterval: interval between tab  stops if not specified by tab(n) between LosslessStringConvertible items
    func println(_ items: Any..., tabInterval: Int = 14) {
        print(items, tabInterval: tabInterval)
        println()
    }
    
    /// Prints new lines
    /// - Parameter number: number of new lines to print
    func println(_ number: Int = 1) {
        consoleIO.println(number)
    }
    
    func printHeader(title: String, newlines: Int = 3) {
        let creditString = "Creative Computing  Morristown, New Jersey"
        println(tab((creditString.count - title.count) / 2 + 15), title)
        println(tab(15), creditString)
        println(newlines)
    }

    /// Gets keyboard input
    /// - Parameter terminator: If specified, replaces default prompt character (?)
    /// - Returns: Entered string
    func input(terminator: String? = nil) -> String {
        let string = consoleIO.getInput(terminator: terminator)
        wait(.afterEntry)
        return string
    }
    
    /// Gets keyboard input after printing message
    /// - Parameters:
    ///   - message: Prompt message
    ///   - terminator: If specified, replaces default prompt character (?)
    /// - Returns: Entered string
    func input(_ message: String, terminator: String? = nil) -> String {
        consoleIO.print(message)
        return input(terminator: terminator)
    }
    
    /// Gets keyboard input after printing message
    /// - Parameters:
    ///   - message: Prompt message
    ///   - terminator: If specified, replaces default prompt character (?)
    /// - Returns: Optional value from string representation
    func input<T>(_ message: String, terminator: String? = nil) -> T? where T: LosslessStringConvertible {
        consoleIO.print(message)
        return T(input(terminator: terminator))
    }
    
    /// Gets keyboard input after printing message
    /// - Parameters:
    ///   - message: Prompt message
    ///   - terminator: If specified, replaces default prompt character (?)
    /// - Returns: Optionally 2 values from entered string representation, separated by comma or whitespace
    func input<T>(_ message: String, terminator: String? = nil) -> (T, T)? where T: LosslessStringConvertible {
        consoleIO.print(message)
        let stringValues = (input(terminator: terminator).components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }).filter { !$0.isEmpty }
        guard stringValues.count == 2, let value1 = T(stringValues[0]), let value2 = T(stringValues[1]) else { return nil }
        return (value1, value2)
    }
    
    /// Gets keyboard input after printing message
    /// - Parameters:
    ///   - message: Prompt message
    ///   - terminator: If specified, replaces default prompt character (?)
    /// - Returns: 2 optional values from entered string representation, separated by comma or whitespace
    func input<T>(_ message: String, terminator: String? = nil) -> (T?, T?) where T: LosslessStringConvertible {
        consoleIO.print(message)
        let stringValues = (input(terminator: terminator).components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }).filter { !$0.isEmpty }
        switch stringValues.count {
        case 0: return (nil, nil)
        case 1: return (T(stringValues[0]), nil)
        default: return (T(stringValues[0]), T(stringValues[1]))
        }
    }

    @discardableResult
    func pauseForEnter() -> String {
        return consoleIO.pauseForEnter()
    }
    
    func unlockEasterEgg(_ game: Game) {
        guard let url = game.unlockURL else { return }
        NSWorkspace.shared.open(url)
    }
    
    func end(_ message: String? = nil) -> Never {
        wait(.short)
        consoleIO.close(message)
    }
}
