//
//  Number.swift
//  Number
//
//  Created by Joseph Baraga on 12/28/24.
//

import Foundation

class Number: GameProtocol {
    
    func run() {
        printHeader(title: "Number")
        println(3)
        println("You have 100 points.  By guessing numbers from 1 to 5, you")
        println("can gain or lose points depending upon how close you get to")
        println("a random number selected by the computer.")
        println()
        println("You occasionally will get a jackpot which will double(!)")
        println("your point count.  You win when you get 500 points.")
        println()
        wait(.short)
        play()
    }
    
    private func play() {
        var p = 100
        while p < 500 {
            let g: Int = input("Guess a number from 1 to 5") ?? 6
            
            if g <= 5 {
                if g == fnr() {
                    p -= 5
                } else if g == fnr() {
                    p += 5
                } else if g == fnr() {
                    p += p
                    println("You hit the jackpot!!!")
                } else if g == fnr() {
                    p += 1
                } else if g == fnr() {
                    p -= Int(Double(p) * 0.5)
                } else {
                    p -= 5
                }
                
                if p < 500 {
                    println("You have \(p) points.")
                } else {
                    println("!!!!You win!!!! with \(p) points.")
                }
            }
        }
        
        unlockEasterEgg(.number)
    }
    
    //10
    private func fnr() -> Int {
        return Int.random(in: 1...5)
    }
}
