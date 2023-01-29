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
 

protocol GameProtocol {
    func run()
}

extension GameProtocol {    
    var consoleIO: ConsoleIO {
        return ConsoleIO.shared
    }
        
    var formatter: NumberFormatter {
        return consoleIO.formatter
    }
    
    /// BASIC Sign function
    /// - Parameter x: Integer
    /// - Returns: -1 if x is negative, 0 if x is 0, 1 if x is positive
    func sgn(_ x: Int) -> Int {
        return x == 0 ? 0 : (x < 0 ? -1 : 1)
    }
    
    func printHeader(title: String) {
        let creditString = "Creative Computing  Morristown, New Jersey"
        println(tab((creditString.count - title.count) / 2 + 15), title)
        println(tab(15), creditString)
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
    
    /// Prints message followed by new line
    /// - Parameter message: String to print
    func println(_ message: String) {
        consoleIO.println(message)
    }
    
    /// Prints new lines
    /// - Parameter number: number of new lines to print
    func println(_ number: Int = 1) {
        consoleIO.println(number)
    }
    
    /// Prints message without new line
    /// - Parameter message: String to print
    func print(_ message: String) {
        consoleIO.print(message)
    }
    
    /// Prints message terminated by new line after moving cursor to tab stop
    /// - Parameters:
    ///   - message: String to print
    ///   - tab: Tab stop (zero indexed)
    func println(_ tab: (() -> String)? = nil ,_ message: String) {
        if let tab = tab {
            consoleIO.print(tab())
        }
        consoleIO.println(message)
    }
    
    /// Moves cursor to tab stop
    /// - Parameters:
    ///   - message: String to print
    ///   - tab: Tab stop (zero indexed)
    func print(_ tab: (() -> String)) {
        consoleIO.print(tab())
    }

    /// Prints message after moving cursor to tab stop
    /// - Parameters:
    ///   - message: String to print
    ///   - tab: Tab stop (zero indexed)
    func print(_ tab: (() -> String)? = nil ,_ message: String) {
        if let tab = tab {
            consoleIO.print(tab())
        }
        consoleIO.print(message)
    }
    
    /// Moves cursor to tab stop; provides simplified syntax for use with print
    /// - Parameters:
    ///   - x: Tab stop (zero indexed)
    /// - Returns: Closure which generates string with spaces needed move cursor to desired tab stop
    func tab(_ x: Int) -> () -> String {
        return { consoleIO.tab(x) }
    }
    
    /// Prints multiple items, each item is printed at successive tab stops. Will skip to next tab stop if message length greater than tabInterval
    /// - Parameters:
    ///   - messages: strings to print, separated by comma
    ///   - tabInterval: Tab  interval
    func print(_ messages: String..., tabInterval: Int = 14) {
        var tabIndex = 0
        for string in messages {
            print(tab(tabInterval * tabIndex), string)
            tabIndex += (1 + (string.count / tabInterval))
        }
    }
    
    /// Prints multiple items at successive tab stops, terminating with new line
    /// - Parameters:
    ///   - messages: strings to print, separated by comma
    ///   - tabInterval: Tab  interval
    func println(_ messages: String..., tabInterval: Int = 14) {
        var tabIndex = 0
        for string in messages {
            print(tab(tabInterval * tabIndex), string)
            tabIndex += (1 + (string.count / tabInterval))
        }
        println()
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
