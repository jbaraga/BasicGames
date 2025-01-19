//
//  Slots.swift
//  play
//
//  Created by Joseph Baraga on 1/14/25.
//

import Foundation

class Slots: GameProtocol {
    
    private var purse = 0  //P
    
    private var testSpins = [[4,6,2], [1,6,6], [4,1,2], [2,2,1], [1,5,1], [3,3,3], [1,1,1]]
    
    func run() {
        printHeader(title: "Slots")
        
        //100 REM PRODUCED BY FRED MIRABELLE AND BOB HARPER ON JAN. 29, 1973
        //110 REM IT SIMULATES THE SLOT MACHINE.
        
        println("You are in the H&M Casino, in front of one of our")
        println("one-armed bandits. Bet from $1 to $100.")
        println("To pull the arm, punch the return key after making your bet.")

        repeat {
            play()
        } while Response(input("Again")) == .yes
                 
        println()
        if purse < 0 {
            println("Pay up!  Please leave your money on the terminal.")
        } else if purse > 0 {
            println("Collect your winnings from the H&M cashier.")
            unlockEasterEgg(.slots)
        } else {
            println("Hey, you broke even.")
        }
        end()
    }
    
    
    private func play() {
        let bet = getBet()  //M
        consoleIO.ringBell()
        println(2)
        
        let spin = (1...3).map { _ in Int.random(in: 1...6) }  //X, Y, Z
        println(displayString(for: spin))
        println()
        computeResult(for: spin, bet: bet)
        println("Your standings are $ \(purse)")  //510
    }
    
     //160-210, 860-890
    private func getBet() -> Int {
        println()
        guard let bet = Double(input("Your bet")), bet > 0 else {
            println("Minimum bet is $1")
            return getBet()
        }
        guard bet <= 100 else {
            println("House limits are $100")
            return getBet()
        }
        return Int(bet)
    }
    
    //270-440, 910-1260
    private func displayString(for spin: [Int]) -> String {
        return (spin.map {
            switch $0 {
            case 1: return "Bar"
            case 2: return "Bell"
            case 3: return "Orange"
            case 4: return "Lemon"
            case 5: return "Plum"
            case 6: return "Cherry"
            default:
                fatalError("Invalid spin number \($0)")
            }
        }).joined(separator: " ")
    }
    
    //450-500, 600-660, 730-850, 1341-1344
    private func computeResult(for spin: [Int], bet: Int) {
        guard let (value, count) = spin.mode else { fatalError("Invalid spin \(spin)") }
        switch count {
        case 3:
            if value == 1 {
                //780
                println("***Jackpot***")
                purse += 100 * bet + bet
            } else {
                //740
                println("**Top Dollar**")
                purse += 10 * bet + bet
            }
            println("You won!")

        case 2:
            if value == 1 {
                //820
                println("*Double Bar*")
                purse += 5 * bet + bet
            } else {
                //1341
                println("Double!!")
                purse += 2 * bet + bet
            }
            println("You won!")

        default:
            //490
            println("You lost.")
            purse -= bet
        }
    }
    
    func test () {
        testSpins.forEach { spin in
            println()
            let bet = [5, 10, 25].randomElement()!
            println("Bet $ \(bet)")
            consoleIO.ringBell()
            println()
            
            println(displayString(for: spin))
            println()
            computeResult(for: spin, bet: bet)
            
            //510
            println("Your standings are $ \(purse)")
        }
    }
}

private extension Array where Element: Hashable {
    var mode: (value: Element, count: Int)? {
        let counts = self.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        guard let (value, count) = counts.max(by: { $0.1 < $1.1 }) else { return nil }
        return (value, count)
    }
}
