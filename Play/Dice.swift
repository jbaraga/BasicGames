//
//  Dice.swift
//  Dice
//
//  Created by Joseph Baraga on 12/25/24.
//

import Foundation

class Dice: BasicGame {
    
    func run() {
        printHeader(title: "Dice")
        //20 REM  DANNY FREIDUS
        println("This program simulates the rolling of a")
        println("pair of dice.")
        println("You enter the number of times you want the computer to")
        println("'roll' the dice.  Watch out, very large numbers take")
        println("a long time.  In particular, numbers over 5000.")
        wait(.short)
        
        repeat {
            play()
            wait(.short)
        } while Response(input("Try again")).isYes
        
        unlockEasterEgg(.dice)
        end()
    }
    
    private func play() {
        println()
        let x = Int(input("How many rolls")) ?? 0
        
        let f = (1...x).reduce(into: [Int: Int]()) { (dict, _) in
            let r = Int.random(in: 1...6) + Int.random(in: 1...6)
            dict[r] = (dict[r] ?? 0) + 1
        }
        
        println()
        println("Total Spots", "Number of Times")
        for key in f.keys.sorted() {
            println(" \(key)", f[key] ?? 0)
        }
        
        println()
    }
}
