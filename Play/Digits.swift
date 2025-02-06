//
//  Digits.swift
//  Digits
//
//  Created by Joseph Baraga on 1/2/23.
//

import Foundation


class Digits: BasicGame {
    
    private let a = 0
    private let b = 1
    private let c = 3

    func run() {
        printHeader(title: "Digits")
        println("This is a game of guessing.")
        let e = Int(input("For instructions, type '1', else type '0'")) ?? 1
        if e != 0 {
            println()
            println("Please take a piece of paper and write down")
            println("the digits '0', '1', or '2' thirty times at random.")
            println("Arrange them in three lines of ten digits.")
            println("I will ask for them 10 at a time.")
            println("I will always guess them first, and then look at your")
            println("next number to see if I was right.  By pure luck")
            println("I ought to be right 10 times.  But I hope to do better")
            println("than that *****")
            println(2)
            wait(.long)
        }
        
        repeat {
            println(3)
            play()
            wait(.short)
        } while Int(input("Do you want to try again (1 for yes, 0 for no)")) == 1
        
        println()
        println("Thanks for the game.")
        end()
    }
    
    private func play() {
        //Line 380-910
        //Arrays are zero indexed
        var m = dim(27, 3, value: 1)
        var k = dim(3, 3, value: 9)
        var l = dim(9, 3, value: 3)
        l[0,0] = 2
        l[4,1] = 2
        l[8,2] = 2
        
        var z = 26
        var z1 = 8
        var z2 = 2
        var x = 0
        
        var t = 0
        while t < 3 {
            println()
            let string = input("Ten numbers, please")
            let set = CharacterSet.decimalDigits.inverted
            let components = string.components(separatedBy: set)
            let numbers = components.compactMap { Int($0) }  //Zero indexed; represents array N() which is one indexed
            
            let isAllowed = numbers.reduce(true) {
                let w = $1 - 1
                return $0 && w == sgn(w)
            }
            
            if isAllowed && numbers.count == 10 {
                //Line 630
                println()
                println("My Guess", "Your No.", "Result", "No. Right")
                println()
                
                for number in numbers {
                    var s = 0
                    var g = 0
                    for j in 0...2 {
                        let s1 = a * k[z2,j]  + b * l[z1,j] + c * m[z,j]  //a = 0, so k is never used ? bug
                        if s < s1 || (s == s1 && rnd(1) > 0.5) {
                            s = s1
                            g = j
                        }
                    }
                    let result: String
                    if g == number {
                        result = "Right"
                        //Lines 810-870
                        x += 1
                        m[z,number] += 1
                        l[z1,number] += 1
                        k[z2,number] += 1
                        z -= Int(Double(z) / 9) * 9
                        z = 3 * z + number
                    } else {
                        result = "Wrong"
                    }
                    //Lines 880-890
                    z1 = z - Int(Double(z) / 9) * 9
                    z2 = number
                    
                    //Line 770
                    println(" \(g)", " \(number)", result, " \(x)")
                }
                t += 1
            } else {
                if !isAllowed {
                    println("Only use the digits '0', '1', or '2'.")
                }
                println("Let's try again.")
            }
        }
        
        //Line 920
        println()
        switch x {
        case _ where x < 10:
            println("I guessed less than 1/3 of your numbers.")
            println("You beat me.  Congratulations *****")
            unlockEasterEgg(.digits)
        case _ where x > 10:
            println("I guessed more than 1/3 of your numbers.")
            println("I win.")
            ringBell(10)
        default:
            println("I guessed exactly 1/3 of your numbers.")
            println("It is a tie game.")
        }
        
        println()
    }
}
