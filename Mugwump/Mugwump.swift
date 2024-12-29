//
//  Mugwump.swift
//  Mugwump
//
//  Created by Joseph Baraga on 12/27/24.
//

import Foundation

class Mugwump: GameProtocol {
    
    struct Wump {
        let x: Int
        let y: Int
        var isHidden = true
        
        var location: String { "( \(x) , \(y) )" }
        
        init() {
            x = Int.random(in: 0...9)
            y = Int.random(in: 0...9)
        }
        
        init(location x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
        
        //380-390
        func distance(from m: Int, _ n: Int) -> Double {
            return Double(Int(sqrt(pow(Double(x - m), 2) + pow(Double(y - n), 2)) * 10)) / 10
        }
    }
    
    func run() {
        printHeader(title: "Mugwump")
        println(3)
        println("The object of this game is to find four Mugwumps")
        println("hidden on a 10 by 10 grid.  Homebase is position 0,0")
        println("Any guess you make must be two numbers with each")
        println("number between 0 and 9, inclusive.  First number")
        println("is distance to right of homebase and second number")
        println("is distance above homebase.")
        println()
        println("You get 10 tries.  After each try, I will tell")
        println("you how far you are from each mugwump.")
        println()
        wait(.short)
        play()
    }
    
    private func play() {
        while true {
            var turn = 0
            var mugwumps = (1...4).reduce(into: [Wump]()) { array, _ in array.append(Wump()) }
            
            while turn < 10 {
                turn += 1
                println(2)
                let (m, n): (Int, Int) = input("Turn no. \(turn) what is your guess") ?? (0, 0)
                                
                for (index, wump) in mugwumps.enumerated() {
                    if wump.isHidden {
                        if m == wump.x, n == wump.y {
                            println("You have found Mugwump \(index + 1)")
                            mugwumps[index].isHidden = false
                        } else {
                            let distance = wump.distance(from: m, n).formatted(.number)
                            println("You are \(distance) units from Mugwump \(index + 1)")
                        }
                    }
                }
                println()
                if (mugwumps.reduce(true) { $0 && !$1.isHidden }) {
                    println("You got them all in \(turn) turns!")
                    unlockEasterEgg(.mugwump)
                    turn = 10
                } else {
                    if turn == 10 {
                        println()
                        println("Sorry, that's 10 tries.  Here is where they're hiding")
                        for (index, wump) in mugwumps.enumerated() {
                            if wump.isHidden {
                                println("Mugwump \(index + 1) is at " + wump.location)
                            }
                        }
                        println()
                    }
                }
            }
            
            println("That was fun!  Let's play again.......")
            println("Four more Mugwumps are now in hiding.")
        }
    }
    
    private func getGuess() -> (m: Int, n: Int) {
        let guess = input()
        let components = guess.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return (Int(components.first ?? "") ?? -1, Int(components.last ?? "") ?? -1)
    }
}
