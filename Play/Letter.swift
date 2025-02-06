//
//  Letter.swift
//  play
//
//  Created by Joseph Baraga on 1/21/25.
//

import Foundation

class Letter: BasicGame {
    
    func run() {
        printHeader(title: "Letter")
        println("Letter Guessing Game")
        println("I'll think of a letter of the alphabet, A to Z.")
        println("Try to guess my letter and I'll give you clues")
        println("as to how close you're getting to my letter.")
        
        while true {
            play()
        }
    }
    
    private func play() {
        //Uppercase letter ascii codes 65...90
        let targetCode = UInt8.random(in: 65...90)
        var guesses = 0
        println()
        println("O.K., I have a letter.  Start guessing.")
        
        var code: UInt8 = 0
        repeat {
            println()
            let letter = input("What is your guess").uppercased()
            println()
            code = letter.data(using: .ascii)?.first ?? 0
            guesses += 1
            if code < targetCode {
                println("Too low.  Try a higher letter.")
            } else if code > targetCode {
                println("Too high.  Try a lower letter.")
            }
        } while code != targetCode
        
        println()
        println("You got it in \(guesses) guesses!!")
        if guesses <= 5 {
            println("Good job !!!!!")
            ringBell()
            unlockEasterEgg(.letter)
        } else {
            println("But it shouldn't take more than 5 guesses!")
        }
        
        println()
        println("Let's play again.....")
    }
}
