//
//  Craps.swift
//  play
//
//  Created by Joseph Baraga on 1/4/25.
//

import Foundation

class Craps: GameProtocol {
    
    func run() {
        printHeader(title: "Craps")
        println("2,3,12 are losers 4,5,6,8,9,10 points")
        play()
        end()
    }
    
    private func play() {
        //21-26 - does nothing, except maybe a random delay - t, z, x variables not used
        var t = 1
        let z = Int(input("Pick a number and input to roll dice")) ?? 0
        repeat {
            let _ = rnd()
            t += 1
        } while t <= z
        
        var wallet = 0  //R
        
        repeat {
            let wager = Int(input("Input the amount of your wager.")) ?? 0  //F
            println(" I will now throw the dice")
            let roll1 = Int.random(in: 1...6) + Int.random(in: 1...6)
            switch roll1 {
            case 2:
                //195
                println(" \(roll1) Snake Eyes....you lose")
                println("You lose \(wager) dollars")
                wallet -= wager
            case 3, 12:
                //200
                println(" \(roll1) Craps...you lose")
                println("You lose \(wager) dollars")
                wallet -= wager
            case 4, 5 ,6, 8, 9, 10:
                //220
                println(" \(roll1) point I will roll again")
                let roll2 = rollAgain(firstRoll: roll1)
                switch roll2 {
                case 7:
                    println(" \(roll2) Craps...you lose")
                    println("You lose $\(wager)")
                    wallet -= wager
                case roll1:
                    println(" \(roll1) a winner.........Congrats!!!!!!!!")
                    println(" \(roll1) at 2 to 1 odds pays you...let me see... \(2 * wager) dollars")
                    wallet += 2 * wager
                default:
                    fatalError("Invalid roll again \(roll2)")
                }
            case 7, 11:
                //180
                println(" \(roll1) Natural....a winner!!!!")
                println(" \(roll1) pays even money,you win \(wager) dollars")
                wallet += wager
            default:
                fatalError("Invalid roll \(roll1)")
            }
        } while playAgain(wallet: wallet)
        
        if wallet < 0 {
            println("Too bad, you are in the hole. Come again.")
        } else if wallet > 0 {
            println("Congratulations---You came out a winner.  Come again.")
            unlockEasterEgg(.craps)
        } else {
            println("Congratulations---You came out even, not bad for an amateur.")
        }
    }
    
    private func playAgain(wallet: Int) -> Bool {
        let m = Int(input(" If you want to play again print 5 if not print 2")) ?? 2
        if wallet < 0 {
            println("You are now under $ \(-wallet)")
        } else if wallet > 0 {
            println("You are now ahead $ \(wallet)")
        } else {
            println("You are now even at 0")
        }
        return m == 5
    }
    
    private func rollAgain(firstRoll: Int) -> Int {
        let roll = Int.random(in: 1...6) + Int.random(in: 1...6)
        if roll == 7 || roll == firstRoll { return roll }
        println("\(roll) no point I will roll again")
        return rollAgain(firstRoll: firstRoll)
    }
}
