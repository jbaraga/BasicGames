//
//  Roulette.swift
//  play
//
//  Created by Joseph Baraga on 1/25/25.
//

import Foundation

class Roulette: BasicGame {
    
    private enum Color {
        case red, black
        
        var description: String { return self == .red ? "red" : "black" }
        var symbol: String { return self == .red ? "*" : " " }
    }
    
    private struct Wheel {
        static let pockets = (1...38).map { Pocket(number: $0) }
        
        static var rowStrings: [String] {
            var strings = [String]()
            for index in stride(from: 0, through: 33, by: 3) {
                strings.append((pockets[index...index+2].map { $0.label }).joined(separator: "   "))
            }
            strings.append("    \(pockets[37])    \(pockets[36])")
            return strings
        }
    }
    
    private struct Pocket: CustomStringConvertible {
        let number: Int
        
        var color: Color? {
            let redNumbers = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]
            let blackNumbers = [Int](1...36).filter { !redNumbers.contains($0) }
            if redNumbers.contains(number) {
                return .red
            } else if blackNumbers.contains(number) {
                return .black
            } else {
                return nil
            }
        }
        
        var label: String {
            if number == 37 { return "0" }
            if number == 38 { return "00" }
            return (number < 10 ? " \(number)" : "\(number)") + (color?.symbol ?? "")
        }
        
        var description: String {
            if number == 37 { return "0" }
            if number == 38 { return "00" }
            if let color { return (" \(number) \(color)") }
            return "\(number)"
        }
    }
    
    private struct Bet: LosslessStringConvertible {
        let type: Int  //1-50
        let amount: Int
        
        var description: String { "\(type) $\(amount)"}
        
        init?(_ description: String) {
            let stringValues = description.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            guard stringValues.count == 2, let type = Int(stringValues[0]), let amount = Int(stringValues[1]) else { return nil }
            self.init(type: type, amount: amount)
        }
        
        init?(type: Int, amount: Int) {
            guard type > 0, type <= 50, amount >= 5, amount <= 500 else {
                return nil
            }
            self.type = type
            self.amount = amount
        }
        
        static func odds(for type: Int) -> Int {
            switch type {
            case 1...36: return 35
            case 37...42: return 2
            case 43...48: return 1
            case 49, 50: return 35
            default:
                fatalError(#function + " invalid bet \(type)")
            }
        }
        
        func isWinner(for pocket: Pocket) -> Bool {
            if pocket.number == 37 { return type == 49 }  //0 does not count for other types
            if pocket.number == 38 { return type == 50 }  //00 does not count for other types
            switch type {
            case 1...36:
                return type == pocket.number
            case 37, 38, 39:
                //2090 REM  1-12(37) 2:1
                //2190 REM  13-24(38) 2:1
                //2220 REM  25-36(39) 2:1
                return (1...12).contains(pocket.number - 12 * (type - 37))
            case 40, 41, 42:
                //2250 REM  FIRST COLUMN(40) 2:1
                //2300 REM  SECOND COLUMN(41) 2:1
                //2350 REM  THIRD COLUMN(42) 2:1
                return ((0...11).map { $0 * 3 + (type - 39) }).contains(pocket.number)
            case 43, 44:
                //2400 REM  1-18(43) 1:1
                //2470 REM  19-36(44) 1:1
                return (1...18).contains(pocket.number - 18 * (type - 43))
            case 45:
                //2500 REM  EVEN(45) 1:1
                return pocket.number % 2 == 0
            case 46:
                //2530 REM  ODD(46) 1:1
                return pocket.number % 2 == 1
            case 47:
                //2560 REM  RED(47) 1:1
                return pocket.color == .red
            case 48:
                //2630 REM  BLACK(48) 1:1
                return pocket.color == .black
            case 49, 50:
                return false
            default:
                fatalError(#function + " invalid type \(type)")
            }
        }
        
        func result(for pocket: Pocket) -> Int {
            return isWinner(for: pocket) ? amount * Self.odds(for: type) : -amount
        }
    }
    
    private var playerPurse = 1000  //P
    private var houseBank = 100000  //D
    
    func run() {
        printHeader(title: "Roulette")
        
        let userDate = input("Enter current date (as in 'January 23, 1978') -")
        
        //1000 REM-ROULETTE
        //1010 REM-DAVID JOSLIN
        println("Welcome to the Roulette Table")
        println()
        if Response(input("Do you want instructions")) != .no {
            printInstructions()
        }
        
        repeat {
            play()
            
            if playerPurse <= 0 {
                println("Oops! You just spent your last dollar")
            }
            
            if houseBank <= 0 {
                println("You broke the house!")
                playerPurse = 101000
            }
        } while playerPurse > 0 && houseBank > 0 && Response(input("Again")) == .yes
                    
        if playerPurse < 1 {
            println("Thanks for your money")
            println("I'll use it to buy a solid gold roulette wheel")
        } else {
            let name = input("To whom should I make the check")
            println()
            println(String(repeating: "-", count: 72))
            println(tab(50), "Check no. \(Int.random(in: 0...99))")
            println()
            println(tab(40), todaysDate(userDate))  //Gosub 3230 to get today's date
            println(2)
            println("Pay to the order of-----\(name)-----$ \(playerPurse)")
            println(2)
            println(tab(10), "The Memory Bank of Virginia")
            println()
            println(tab(40), "The Computer")
            println(tab(40), "----------X-----")
            println()
            println(String(repeating: "-", count: 72))
            println("Come back soon!")
            if playerPurse > 1000 { unlockEasterEgg(.roulette) }
        }
        println()
        
        end()
    }
    
    private func play() {
        //1550 REM-PROGRAM BEGINS HERE
        //1560 REM-TYPE OF BET(NUMBER) ODDS
        //1570 REM  DON'T NEED TO DIMENSION STRINGS
        
        let numberOfBets = getNumberOfBets()  //Y
        let bets = getBets(number: numberOfBets)  //A
        println("Spinning")
        wait(.short)
        println(2)
        let pocket = Pocket(number: Int.random(in: 1...38))  //S
        println(pocket)
        println()
        for (index, bet) in bets.enumerated() {
            let result = bet.result(for: pocket)
            if result < 0 {
                println("You lose \(-result) dollars on bet  \(index + 1)")
            } else {
                println("You win  \(result) dollars on bet  \(index + 1)")
            }
            playerPurse += result
            houseBank -= result
        }
        
        println()
        println("Totals:", "Me", "You")
        println(" ", houseBank, playerPurse)
    }
    
    //1630-1650
    private func getNumberOfBets() -> Int {
        guard let number = Int(input("How many bets")), number > 0 else  {
            return getNumberOfBets()
        }
        return number
    }
    
    //1670-1790
    private func getBets(number: Int, bets: [Bet] = []) -> [Bet] {
        guard let bet = Bet(input("Number \(bets.count + 1)")) else {
            return getBets(number: number, bets: bets)
        }
        
        if bets.contains(where: { $0.type == bet.type }) {
            println("You made that bet once already,dum-dum")
            return getBets(number: number, bets: bets)
        }
        
        var bets = bets
        bets.append(bet)
        if bets.count < number {
            return getBets(number: number, bets: bets)
        }
    
        return bets
    }
    
    //1070-1540
    private func printInstructions() {
        println()
        println("This is the betting layout")
        println("  (*=red)")
        println()
        
        for (index, string) in Wheel.rowStrings.enumerated() {
            println(string)
            if (index + 1) % 4 == 0, index > 0 {
                println(String(repeating: "-", count: 15))
            }
        }
        
        println()
        println("Types of bets")
        println()
        println("The numbers 1 to 36 signify a straight bet")
        println("on that number")
        println("These pay off 35:1")
        println()
        println("The 2:1 bets are:")
        println(" 37) 1-12     40) first column")
        println(" 38) 13-24    41) second column")
        println(" 39) 25-36    42) third column")
        println()
        println("The even money bets are:")
        println(" 43) 1-18     46) odd")
        println(" 44) 19-36    47) red")
        println(" 45) even     48) black")
        println()
        println(" 49)0 and 50)00 pay of 35:1")
        println(" Note: 0 and 00 do not count under any")
        println("       bets except their own")
        println()
        println("When I ask for each bet,type the number")
        println("and the amount,separated by a comma")
        println("For example:to bet $500 on black,type 48,500")
        println("when I ask for a bet")
        println()
        println("Minimum bet is $5,maximum is $500")
        println()
    }
    
    func todaysDate(_ dateString: String) -> String {
        //3230 REM
        //3240 REM    THIS ROUTINE RETURNS THE CURRENT DATE IN M$
        //3250 REM    IF YOU HAVE SYSTEM FUNCTIONS TO HANDLE THIS
        //3260 REM    THEY CAN BE USED HERE.  HOWEVER IN THIS
        //3270 REM    PROGRAM, WE JUST INPUT THE DATE AT THE START OF
        //3280 REM    THE GAME.
        //3290 REM
        //3300 REM    THE DATE IS RETURNED IN VARIABLE M$
        
        //In this implementation, the entered date is used unless it does not parse to a date:
        let dateFormatStyle = Date.FormatStyle()
            .month()
            .day()
            .year()
        do {
            let _  = try dateFormatStyle.parse(dateString)
            return dateString
        } catch {
            return Date().formatted(date: .long, time: .omitted)
        }
    }
    
    func test() {
        let bets = (1...50).compactMap { Bet(type: $0, amount: 10) }
        for bet in bets {
            Wheel.pockets.forEach { pocket in
                Swift.print("Pocket: \(pocket)", " Bet: \(bet)", " isWinner: \(bet.isWinner(for: pocket))", "Win/loss $\(bet.result(for: pocket))")
            }
            Swift.print()
        }
    }
}
