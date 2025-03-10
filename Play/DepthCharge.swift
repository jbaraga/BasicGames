//
//  DepthCharge.swift
//  DepthCharge
//
//  Created by Joseph Baraga on 2/12/22.
//

import Foundation


class DepthCharge: BasicGame {
    
    func run() {
        printHeader(title: "Depth Charge")
        println("Depth Charge Game")
        println()
        
        let g = Double(input("Dimension of search area")) ?? 10
        
        //Added safety check
        guard g > 0 else {
            println("Invalid dimension")
            end()
        }
        
        let n = Int(log(g) / log(2)) + 1
        
        println()
        println("You are the captain of the destroyer USS Computer.")
        println("An enemy sub has been causing you trouble. Your")
        println("mission is to destroy it.  You have \(n) shots.")
        println("Specify depth charge explosion point with a")
        println("trio of numbers -- the first two are the")
        println("surface coordinates; the third is the depth.")
        
        repeat {
            println(3)
            play(dimension: g)
            wait(.long)
        } while Response(input("Another game (y or n)")).isYes
        
        println("Ok.  Hope you enjoyed yourself.")
        end()
    }
    
    private func play(dimension g: Double) {
        println()
        println("Good luck !")
        println()
        
        let a = Int(g * rnd(1))
        let b = Int(g * rnd(1))
        let c = Int(g * rnd(1))
        
        let n = Int(log(g) / log(2)) + 1
        
        for d in 1...n {
            println()
            print("Trial # \(d) ")
            let (x,y,z) = getInput()
            if abs(x - a) + abs(y - b) + abs(z - c) == 0 {
                println("B O O M ! ! You found it in \(d) tries!")
                if d < Int(g / 10) { unlockEasterEgg(.depthCharge) }
                return
            }
            
            print("Sonar reports shot was ")
            print(y > b ? "North" : (y < b ? "South" : ""))
            print(x > a ? "East" : (x < a ? "West" : ""))
            if x != a || y != b {
                print(" and ")
            }
            println(z > c ? "too low." : (z < c ? "too high." : "depth ok."))
        }
        
        //Failure
        println()
        println("You have been torpedoed!  Abandon ship!")
        println("The submarine was at \(a),\(b),\(c)")
    }
    
    private func getInput() -> (x: Int, y: Int, z: Int) {
        let components = input().components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 3 else { return (0,0,0) }
        return (Int(components[0]) ?? 0, Int(components[1]) ?? 0, Int(components[2]) ?? 0)
    }
}
