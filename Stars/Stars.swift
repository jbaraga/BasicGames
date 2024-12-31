//
//  Stars.swift
//  Stars
//
//  Created by Joseph Baraga on 12/28/24.
//

import Foundation

class Stars: GameProtocol {
    
    //140 REM *** A IS LIMIT ON NUMBER, M IS NUMBER OF GUESSES
    private let a = 100
    private let m = 7
    
    func run() {
        printHeader(title: "Stars")
        println(3)
        
        //100 REM *** STARS - PEOPLE'S COMPUTER CENTER, MENLO PARK, CA
        let response = Response(input("Do you want instructions"))
        if !response.isNo {
            //200 REM *** INSTRUCTIONS ON HOW TO PLAY
            println("I am thinking of a whole number from 1 to \(a)")
            println("Try to guess my number.  After you guess, I")
            println("will type one or more stars (*).  The more")
            println("stars I type, the closer you are to my number.")
            println("One star (*) means far away, seven stars (*******)")
            println("means really close!  You get \(m) guesses.")
        }
        
        //270 REM *** COMPUTER THINKS OF A NUMBER
        wait(.short)
        play()
    }
    
    //280-650
    private func play() {
        while true {
            println(2)
            let number = Int.random(in: 1...a)  //X
            println("Ok, I am thinking of a number, start guessing.")
            guess(number: number)
        }
    }
    
    private func guess(number: Int) {
        //320 REM *** GUESSING BEGINS, HUMAN GETS M GUESSES
        var k = 0
        while k < m {
            println()
            let guess = Int(input("Your guess")) ?? 200  //G
            k += 1
            if guess == number {
                //590 REM *** WE HAVE A WINNER
                println(String(repeating: "*", count: 50) + "!!!")
                println("You got it in \(k) guesses!!!  Let's play again...")
                unlockEasterEgg(.stars)
                return
            }
            
            let delta = abs(guess - number)
            //390-440
            let stars = 7 - Int(log2(Double(delta)))
            println(String(repeating: "*", count: stars < 1 ? 1 : stars))
        }
        
        //540 REM *** DID NOT GUESS IN M GUESSES
        println()
        println("Sorry, that's \(m) guesses, number was \(number)")
    }
}
