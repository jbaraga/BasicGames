//
//  Trap.swift
//  Trap
//
//  Created by Joseph Baraga on 12/30/24.
//

import Foundation

class Trap: BasicGame {
    
    private let n = 100  //maximum
    private let g = 6  //number of guesses
    
    func run() {
        printHeader(title: "Trap")
        
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
        
        while true {
            play()
        }
    }
    
    private func play() {
        guess(x: Int.random(in: 1...n))
        println()
        println("Try again.")
        println()
    }
    
    private func guess(x: Int) {
        for guessNumber in 1...g {
            println()
            let guess: ClosedRange<Int> = input("Guess # \(guessNumber)") ?? 0...0
            if guess.lowerBound == x && guess.upperBound == x {
                println("You got it!!!")
                if guessNumber < 6 { unlockEasterEgg(.trap) }
                return
            }
            
            if guess.contains(x) {
                println("You have trapped my number.")
            } else {
                println("My number is \(x < guess.lowerBound ? "smaller" : "larger") than your trap numbers.")
            }
        }
        println("Sorry, that's \(g) guesses. Number was \(x)")
    }
}


extension ClosedRange<Int>: @retroactive LosslessStringConvertible {
    public init?(_ description: String) {
        let stringValues = description.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard stringValues.count == 2, let x = Int(stringValues[0]), let y = Int(stringValues[1]) else { return nil }
        self = x < y ? x...y : y...x
    }
}

