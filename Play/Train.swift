//
//  Train.swift
//  Train
//
//  Created by Joseph Baraga on 12/30/24.
//

import Foundation

class Train: GameProtocol {
    
    func run() {
        printHeader(title: "Train")
        println("Time - speed distance exercise")

        wait(.short)
        repeat {
            play()
        } while Response(input("Another problem (yes or no)")).isYes
        
        println()
        end()
    }
    
    private func play() {
        let c = Int(25 * rnd(1)) + 40
        let d = Int(15 * rnd(1)) + 4
        let t = Int(19 * rnd(1)) + 20
        println()
        println(" A car traveling at \(c) mph can make a certain trip in")
        println(" \(d) hours less than a train traveling at \(t) mph.")
        let a = Double(input("How long does the trip take by car")) ?? 0
        let v = Double(d * t) / Double(c - t)
        let e = Int(abs(v - a) * 100 / a + 0.5)  //Rounds to nearest integer
        if e > 5 {
            println("Sorry, you were off by \(e) percent.")
        } else {
            println("Good! Answer within \(e) percent.")
        }
        println("Correct answer is \(v.formatted(.basic)) hours.")
        println()
        if e < 1 { unlockEasterEgg(.train) }
    }
}
