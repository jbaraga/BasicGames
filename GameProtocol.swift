//
//  GameProtocol.swift
//  BasicGames
//
//  Created by Joseph Baraga on 1/2/22.
//

import AppKit

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
    
    var promptCharacter: String {
        get {
            return consoleIO.promptCharacter
        }
        set {
            consoleIO.promptCharacter = newValue
        }
    }
    
    func sgn(_ x: Int) -> Int {
        return x == 0 ? 0 : (x < 0 ? -1 : 1)
    }
    
    func printHeader(title: String) {
        let creditString = "Creative Computing  Morristown, New Jersey"
        println(tab((creditString.count - title.count) / 2 + 15) + title)
        println(tab(15) + creditString)
    }

    func wait(_ delay: ConsoleIO.Delay) {
        consoleIO.wait(delay)
    }
    
    //Returns random Double from 0 to upperLimit - matches BASIC function
    func rnd(_ upperLimit: Int) -> Double {
        return Double.random(in: 0...Double(upperLimit))
    }
    
    //Returns random Double from 0 to upperLimit - matches BASIC function
    func rnd(_ upperLimit: Double = 1) -> Double {
        return Double.random(in: 0...upperLimit)
    }
    
    func println(_ message: String) {
        consoleIO.println(message)
    }
    
    func println(_ number: Int = 1) {
        consoleIO.println(number)
    }
    
    func print(_ message: String) {
        consoleIO.print(message)
    }
    
    //Tabs to next position after message - for consistent tab position
    /// Tabs to next position after printing message
    /// - Parameters:
    ///   - message: String to print
    ///   - tab: Int tab position
    func printTab(_ message: String, tab: Int) {
        print(message.padded(to: tab))
    }
    
    func tab(_ length: Int) -> String {
        guard length > 0 else { return "" }
        return "".padding(toLength: length, withPad: " ", startingAt: 0)
    }

    func input(terminator: String? = nil) -> String {
        let string = consoleIO.getInput(terminator: terminator)
        wait(.afterEntry)
        return string
    }
    
    func input(_ message: String, terminator: String? = nil) -> String {
        consoleIO.printPrompt(message)
        return input(terminator: terminator)
    }
    
    func showEasterEgg(_ filename: String) {
        consoleIO.wait(.short)
        println()
        println("Opening Easter Egg!!!!!!!!")
        consoleIO.wait(.short)
//        guard let path = Bundle.main.path(forResource: filename, ofType: "pdf") else { return }
//        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        
        let center = DistributedNotificationCenter.default()
        //object has to be  string, userInfo nil for this to properly post
        center.post(name: Notification.Name.showEasterEgg, object: filename, userInfo: nil)
    }
    
    func end() {
        consoleIO.close()
    }
}
