//
//  Bagels.swift
//  Bagels
//
//  Created by Joseph Baraga on 12/15/24.
//

import Foundation


class Bagels: GameProtocol {
    
    var y = 0  //Number of correct guess
    
    func run() {
        printHeader(title: "Bagels")
        
        //15 REM *** BAGELS GUESSING GAME
        //20 REM *** ORIGINAL SOURCE UNKNOWN BUT SUSPECTED TO BE
        //25 REM *** LAWRENCE HALL OF SCIENCE, U.C. BERKELEY
        
        println(3)
        if Response(input("Would you like the rules (yes or no)")).isYes {
            println()
            println("I am thinking of a three-digit number.  Try to guess")
            println("my number and I will give you clues as follows:")
            println("   Pico   - one digit correct but in the wrong position")
            println("   Fermi  - one digit correct and in the right position")
            println("   Bagel  - no digits correct")
        }
        
        var response = Response.yes
        repeat {
            play()
            response = Response(input("Play again (yes or no)"))
        } while response.isYes

        println()
        println("A \(y) point bagels buff!!")
        println("Hope you had fun.  Bye.")
        
        if response == .easterEgg, y > 1 { showEasterEgg(.bagels) }
        end()
    }
    
    private func play() {
        var a = [Int]()  //Computer digits
        
        //150-200
        while a.count < 3 {
            let number = Int.random(in: 0...9)
            if !a.contains(number) { a.append(number) }
        }
        println()
        println("O.K.  I have a number in mind.")
        
        for i in 1...20 {
            let b = getGuess(number: i)
            if b == a {
                println("You got it!!!")
                println()
                y += 1
                return
            }
            
            var pico = 0
            var fermi = 0
            for j in 0..<3 {
                if b[j] == a[j] {
                    fermi += 1
                } else if a.contains(b[j]) {
                    pico += 1
                }
            }
            let result = (Array(repeating: "Pico", count: pico) + Array(repeating: "Fermi", count: fermi)).joined(separator: " ")
            println(result.isEmpty ? "Bagels" : result)
        }
    }
    
    private func getGuess(number: Int) -> [Int] {
        print("Guess # \(number)", tab(14))
        guard let guess = Int(input()), guess >= 0 else {
            println("What?")
            return getGuess(number: number)
        }
        
        let digits = Array(String(guess)).compactMap { Int(String($0)) }
        guard digits.count == 3 else {
            println("Try guessing a three-digit number.")
            return getGuess(number: number)
        }
        
        guard Set(digits).count == digits.count else {
            println("Oh, I forgot to tell you that the number I have in mind")
            println("has no two digits the same.")
            return getGuess(number: number)
        }
        
        return digits
    }
}
