//
//  HiLo.swift
//  play
//
//  Created by Joseph Baraga on 1/8/25.
//

import Foundation

class HiLo: BasicGame {
    
    func run() {
        printHeader(title: "Hi Lo")
        println("This is the game of Hi Lo.")
        println()
        println("You will have 6 tries to guess the amount of money in the")
        println("Hi Lo jackpot, which is between 1 and 100 dollars.  If you")
        println("guess the amount, you win all the money in the jackpot!")
        println("Then you get another chance to win more money.  However,")
        println("if you do not guess the amount, the game ends.")
        play()
    }
    
    private func play() {
        var winnings = 0 //R
        
        repeat {
            println()
            let y = Int.random(in: 1...100)
            var count = 0  //B
            while count < 6 {
                let a = Int(input("Your guess")) ?? 0
                count += 1
                if a == y {
                    println("Got it!!!!!!!!!!   You win \(y) dollars.")
                    winnings += y
                    println("Your total winnings are now \(winnings) dollars.")
                    println()
                    count = 6
                } else {
                    println("Your guess is too \(a < y ? "low" : "high")")
                    println()
                    if count == 6 {
                        println("You blew it...too bad...the number was \(y)")
                        println()
                        winnings = 0
                    }
                }
            }
         } while Response(input("Play again (yes or no)")) == .yes
                    
        println()
        println("So long.  Hope you enjoyed yourself!!!")
        if winnings > 20 {
            unlockEasterEgg(.hiLo)
        }
        end()
    }
}
