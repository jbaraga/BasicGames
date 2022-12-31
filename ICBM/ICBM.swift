//
//  ICBM.swift
//  ICBM
//
//  Created by Joseph Baraga on 2/13/22.
//

import Foundation


class ICBM: GameProtocol {
        
    func run() {
        println(tab(26), "ICBM")
        println(tab(20), "Creative Computing")
        println(tab(18), "Morristown, New Jersey")
        println(3)
        intercept()
    }
    
    func intercept() {
        print("-------Missile------")
        print(tab(28), "--------SAM---------")
        println(tab(56), "-----")
        println("Miles", "Miles", "Miles", "Miles", "Heading")
        println("North", "East", "North", "East", "?")
        println(String(repeating: "-", count: 61))
        
        //ICBM coordinates
        var x = rnd(1) * 800 + 200  //East-West
        var y = rnd(1) * 800 + 200  //North-South
        //SAM coordinates
        var x1 = 0.0   //East-West
        var y1 = 0.0   //North-South
        
        let s = rnd(1) * 20 + 50  //ICBM velocity
        let s1 = rnd(1) * 20 + 50 //SAM velocity
        
        for _ in 1...50 {
            print(" \(Int(round(y))) ", " \(Int(round(x))) ", " \(Int(round(y1))) ", " \(Int(round(x1))) ")
            print(tab(56))
            
            if x == 0 {
                println()
                println("Too bad!")
                println("The ICBM just hit your location!!")
                tryAgain()
                return
            }
            
            let t1 = (Double(input()) ?? 0) / (180 / .pi)  //Heading, converted to radians
            let h = Int(rnd(1) * 200 + 1)
            switch h {
            case 1:
                println()
                println("Too bad.  Your SAM fell to the ground!")
                tryAgain()
                return
            case 2:
                println("Your SAM exploded in midair!")
                tryAgain()
                return
            case 3:
                println("Good luck-the ICBM exploded harmlessly in midair!")
                tryAgain()
                return
            case 4:
                println("Good luck-the ICBM turned out to be a friendly aircraft!")
                tryAgain()
                return
            default:
                break
            }
            
            x1 = x1 + s1 * sin(t1)
            y1 = y1 + s1 * cos(t1)
            
            if sqrt(x * x + y * y) > s {
                //Lines 350-4420
                let b = sqrt(x * x + y * y) / 1000
                let t = atan(y / x)
                x = x - s * cos(t) + rnd(1) * 20 * b
                y = y - s * sin(t) + rnd(1) * 20 * b
                let d = sqrt(pow(x - x1, 2) + pow(y - y1, 2))
                if d <= 5 {
                    //Success
                    println("Congratulations!  Your SAM came within \(Int(round(d))) miles of")
                    println("the ICBM and destroyed it!")
                    tryAgain(true)
                }
                println("ICBM & SAM now \(Int(round(d))) miles apart")
            } else  {
                //Lines 320-340 - failure - missed ICBM, triggers ICBM hit
                x = 0
                y = 0
            }
        }
    }
    
    func tryAgain(_ isSuccessful: Bool = false) {
        wait(.long)
        let response = input("Do you want to play more? (y or n)")
        if response.isEasterEgg, isSuccessful {
            showEasterEgg(.icbm)
        }
        
        if response.isYes {
            println()
            intercept()
        } else {
            end()
        }
    }
}
