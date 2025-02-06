//
//  Guess.swift
//  Guess
//
//  Created by Joseph Baraga on 12/31/22.
//

import Foundation


class Guess: BasicGame {
    
    func run() {
        printHeader(title: "Guess")
        println("This is a number guessing game.  I'll think")
        println("of a number between 1 and any limit you want.")
        println("Then you have to guess what it is.")
        println()
        let limit = Int(input("What limit do you want")) ?? 1
        println()
        
        //Added safety check
        guard limit > 0 else {
            println("Invalid limit")
            end()
        }
        
        while true {
            play(limit)
        }
    }
    
    private func play(_ limit: Int) {
        println("I'm thinking of a number between 1 and \(limit)")
        println ("Now you try to guess what it is.")
        
        let l1 = Int(round(log(Double(limit)) / log(2))) + 1
        var g = 0
        let m = Int(Double(limit) * rnd(1) + 1)
        var n = 0
        while n != m {
            n = Int(input()) ?? -1
            g += 1
            guard n > 0 else {
                println(5)
                run()
                return
            }
            if n < m {
                println("Too low.  Try a bigger answer.")
            }
            
            if n > m {
                println("Too high.  Try a smaller answer.")
            }
        }
        
        println("That's it!  You got it in \(g) tries.")
        if g < l1 {
            println("Very good.")
            unlockEasterEgg(.guess)
        } else if g == l1 {
            println("Good.")
        } else {
            println("You should have been able to get it in only \(l1)")
        }
        
        println(5)
    }
}
