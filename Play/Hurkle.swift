//
//  Hurkle.swift
//  play
//
//  Created by Joseph Baraga on 1/8/25.
//

import Foundation

class Hurkle: GameProtocol {
    
    private let g = 10  //G
    private var n: Int { g / 2 }  //N=5
    
    func run() {
        printHeader(title: "Hurkle")
        println("A Hurkle is hiding on a \(g) by \(g) grid. Homebase")
        println("on the grid is point  0,0  and any gridpoint is a")
        println("pair of whole numbers separated by a comma. Try to")
        println("guess the Hurkle's gridpoint. You get \(g) tries.")
        println("After each try, I will tell you the approximate")
        println("direction to go to look for the Hurkle.")
        println()
        
        wait(.short)
        while true {
            play()
            println()
            println("Let's play again. Hurkle is hiding.")
            println()
        }
    }
    
    private func play() {
        let a = Int.random(in: 0..<g)
        let b = Int.random(in: 0..<g)
        
        var guesses = 1
        repeat {
            let guess: Point = input("Guess # \(guesses)") ?? .zero
            if guess.x == a && guess.y == b {
                println("You found him in \(guesses) guesses!")
                if guesses < n - 1 { unlockEasterEgg(.hurkle) }
                return
            } else {
                //350 REM PRINT INFO
                if guess.y < b { print("North") }
                if guess.y > b { print("South") }
                if guess.x < a { print("East") }
                if guess.x > a { print("West") }
                println(2)
            }
            guesses += 1
        } while guesses <= n
        
        println("Sorry, that's \(n) guesses.")
        println("The Hurkle is at \(a),\(b)")
    }
}
