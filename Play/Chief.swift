//
//  Chief.swift
//  play
//
//  Created by Joseph Baraga on 1/4/25.
//

import Foundation

class Chief: BasicGame {
    func run() {
        printHeader(title: "Chief")
        println(" I am Chief Numbers Freek, the Great Indian Math God.")
        
        if !Response(input("Are you ready to take the test you called me out for")).isYes {
            println("Shutup pale face with wise tongue.")
        }
        play()
        
        println("Bye!!!!!")
        end()
    }
    
    private func play() {
        println(" Take a number and add 3. Divide this number by 5 and")
        println("multiply by 8. Divide by 5 and add the same. Subtract 1.")
        let b = Double(input("  What do you have")) ?? 0
        let c = (b + 1 - 5) * 5 / 8 * 5 - 3
        
        if Response(input("I bet your number was  \(c.formatted(.basic))  was I right")).isYes {
            return
        }
        
        let k = Double(input("What was your original number")) ?? 0
        let f = k + 3
        let g = f / 5
        let h = g * 8
        let i = h / 5 + 5
        let j = i - 1
        println("So you think you're so smart, eh?")
        println("Now watch.")
        println(" \(k.formatted(.basic)) plus 3 equals \(f.formatted(.basic)).  This divided by 5 equals \(g.formatted(.basic));")
        println("This times 8 equals \(h.formatted(.basic)).  If we divide by 5 and add 5,")
        println("We get \(i.formatted(.basic)), which, minus 1 equals \(j.formatted(.basic)).")
        if Response(input("Now do you believe me")).isYes {
            return
        }
        
        wait(.short)
        println("Now you have made me mad!!!")
        println("There must be a great lightning bolt!")
        println(2)
        for x in stride(from: 30, through: 8, by: -1) {
            switch x {
            case 22...30: println(tab(x), "X X")
            case 21: println(tab(x), "X XXX")
            case 20: println(tab(x), "X   X")
            case 19: println(tab(x), "XXX X")
            case 11...18:  println(tab(x+2), "X X")
            case 10: println(tab(x+2), "XX")
            case 9: println(tab(x+2), "X")
            case 8: println(tab(x+2), "*")
            default: break
            }
        }
        println()
        println(String(repeating: "#", count: 25))
        println()
        println("I hope you believe me now, for your sake!!")
        
        unlockEasterEgg(.chief)
        end()
    }
}
