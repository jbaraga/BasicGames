//
//  Nicomachus.swift
//  Nicomachus
//
//  Created by Joseph Baraga on 12/28/24.
//

import Foundation

class Nicomachus: GameProtocol {
    
    func run() {
        printHeader(title: "Nicoma")
        println(3)
        println("Boomerang puzzle from Arithmetica of Nicomachus -- A.D. 90!")
        wait(.short)
        play()
    }
    
    private func play() {
        while true {
            println()
            println("Please think of a number between 1 and 100.")
            let a = Int(input("Your number divided by 3 has a remainder of")) ?? 0
            let b = Int(input("Your number divided by 5 has a remainder of")) ?? 0
            let c = Int(input("Your number divided by 7 has a remainder of")) ?? 0
            println()
            println("Let me think a moment...")
            wait(.long)
            var d = 70 * a + 21 * b + 15 * c
            while d > 105 { d -= 105 }
            print("Your number was \(d), right")
            var response = Response.other
            while response == .other {
                let string = input()
                println()
                response = Response(string)
                if response == .other {
                    println("I don't understand '" + string + "'  Try 'yes' or 'no'.")
                }
            }
            
            if response == .yes {
                println("How about that!!")
                unlockEasterEgg(.nicomachus)
            } else {
                println("I feel your arithmetic is in error.")
            }
            println()
            println("Let's try another")
        }
    }
}
