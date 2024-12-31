//
//  Trap.swift
//  Trap
//
//  Created by Joseph Baraga on 12/30/24.
//

import Foundation

class Trap: GameProtocol {
    
    private let n = 100  //maximum
    private let g = 6  //number of guesses
    
    func run() {
        printHeader(title: "Trap")
        println(3)
        
        //30 REM-TRAP
        //40 REM-STEVE ULLMAN, 8-1-72
        if Response(input("Instructions")).isYes {
            println("I am thinking of a number between 1 and \(n)")
            println("Try to guess my number. On each guess,")
            println("you are to enter 2 numbers, trying to trap")
            println("my number between the two numbers. I will")
            println("tell you if you have trapped my number, if my")
            println("number is larger than your two numbers, or if")
            println("my number is smaller than your two numbers.")
            println("If you want to guess one single number, type")
            println("your guess for both your trap numbers.")
            println("You get \(g) guesses to get my number.")
            wait(.short)
        }
        play()
    }
    
    private func play() {
        while true {
            guess(x: Int.random(in: 1...n))
            println()
            println("Try again.")
            println()
        }
    }
    
    private func guess(x: Int) {
        for guessNumber in 1...g {
            println()
            var (a, b): (Int, Int) = input("Guess # \(guessNumber)") ?? (0, 0)
            if a == x && b == x {
                println("You got it!!!")
                if guessNumber < 6 { unlockEasterEgg(.trap) }
                return
            }
            
            if a > b { (a, b) = (b, a) }
            if (a...b).contains(x) {
                println("You have trapped my number.")
            } else {
                println("My number is \(x < a ? "smaller" : "larger") than your trap numbers.")
            }
        }
        println("Sorry, that's \(g) guesses. Number was \(x)")
    }
}
