//
//  RussianRoulette.swift
//  play
//
//  Created by Joseph Baraga on 1/14/25.
//

import Foundation

class RussianRoulette: BasicGame {
    
    func run() {
        printHeader(title: "Russian Roulette")
        println("This is a game of >>>>>>>>>>Russian Roulette.")
        
        while true {
            play()
        }
    }
    
    private func play() {
        println()
        println("Here is a revolver.")
        println("Type '1' to spin chamber and pull trigger.")
        println("Type '2' to give up.")
        print("Go")
        
        var n = 0
        while n < 10 {
            let i = Int(input()) ?? 2
            if i == 2 {
                println("     Chicken!!!!!")
                println(3)
                println("...Next victim...")
                return
            }
            
            n += 1
            
            if rnd(1) > 0.8333333 {
                println("     Bang!!!!!   You're dead!")
                println("Condolences will be sent to your relatives.")
                println(3)
                println("...Next victim...")
                return
            }
            
            println("- Click -")
            println()
        }

        println("You win!!!!!")
        println("Let someone else blow his brains out.")
        unlockEasterEgg(.russianRoulette)
    }
}
