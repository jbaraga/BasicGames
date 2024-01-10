//
//  GameProtocol.swift
//  BasicGames
//
//  Created by Joseph Baraga on 1/2/22.
//

import AppKit

/*
 BASIC observations:
 INT(_:) - rounds Double values in most cases.
 PRINT(_:); - the semicolon suppresses new line. Numeric values are padded with a space before and after
 PRINT(_, _, _) - multiple items separated by column are printed at successive tab stops. Default tab stop is 14
*/
 
typealias Tab = () -> String

protocol GameProtocol {
    func run()
}

extension GameProtocol {    
    var consoleIO: ConsoleIO { ConsoleIO.shared}
        
    var formatter: NumberFormatter { consoleIO.formatter }
    
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
    
    /// Returns random Double - matches BASIC function
    /// - Parameters:
    ///   - upperLimit: Int
    /// - Returns: Random double within range 0...upperLimit
    func rnd(_ upperLimit: Int) -> Double {
        return Double.random(in: 0...Double(upperLimit))
    }
    
    /// Returns random Double - matches BASIC function
    /// - Parameters:
    ///   - upperLimit: Double
    /// - Returns: Random double within range 0...upperLimit
    func rnd(_ upperLimit: Double = 1) -> Double {
        return Double.random(in: 0...upperLimit)
    }
    
    /// Moves cursor to tab stop; provides simplified syntax for use with print
    /// - Parameters:
    ///   - x: Tab stop (zero indexed)
    /// - Returns: Closure which generates string with spaces needed move cursor to desired tab stop
    func tab(_ x: Int) -> Tab {
        return { consoleIO.tab(x) }
    }
    
    /// Prints string representation String(item) of multiple items at successive tab stops, terminating with new line
    /// - Parameters:
    ///   - items: items to print, separated by comma.
    ///   - tabInterval: Tab  interval
    func print(_ items: Any..., tabInterval: Int = 14) {
        var tabIndex = 0
        for item in items {
            switch item {
            case let item as LosslessStringConvertible: 
                let string = String(item)
                consoleIO.print(tab(tabInterval * tabIndex)())
                consoleIO.print(string)
                tabIndex += (1 + (string.count / tabInterval))
            case let item as Tab:
                let string = item()
                consoleIO.print(item())
                tabIndex += string.count / tabInterval
            default:
                fatalError("Illegal print item: " + String(describing: item))
            }
        }
    }

    /// Prints string representation String(item) of multiple items at successive tab stops, terminating with new line
    /// - Parameters:
    ///   - items: items to print, separated by comma.
    ///   - tabInterval: Tab  interval
    func println(_ items: Any..., tabInterval: Int = 14) {
        print(items, tabInterval: tabInterval)
        println()
    }
    
    /// Prints new lines
    /// - Parameter number: number of new lines to print
    func println(_ number: Int = 1) {
        consoleIO.println(number)
    }
    
    func printHeader(title: String) {
        let creditString = "Creative Computing  Morristown, New Jersey"
        println(tab((creditString.count - title.count) / 2 + 15), title)
        println(tab(15), creditString)
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
    /// - Returns: Optional 2 values from entered string representation, separated by comma or whitespace
    func input<T>(_ message: String, terminator: String? = nil) -> (T, T)? where T: LosslessStringConvertible {
        consoleIO.print(message)
        let stringValues = (input(terminator: terminator).components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }).filter { !$0.isEmpty }
        guard stringValues.count == 2, let value1 = T(stringValues[0]), let value2 = T(stringValues[1]) else { return nil }
        return (value1, value2)
    }
    
    @discardableResult
    func pauseForEnter() -> String {
        return consoleIO.pauseForEnter()
    }
    
    func showEasterEgg(_ game: Game) {
        consoleIO.wait(.short)
        println()
        println("Opening Easter Egg!!!!!!!!")
        consoleIO.wait(.short)
        
        let center = DistributedNotificationCenter.default()
        //object has to be  string, userInfo nil for this to properly post
        center.post(name: Notification.Name.showEasterEgg, object: game.pdfFilename, userInfo: nil)
    }
    
    func end() -> Never {
        consoleIO.close()
    }
}
