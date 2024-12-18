//
//  Bombardment.swift
//  Bombardment
//
//  Created by Joseph Baraga on 12/15/24.
//

import Foundation


class Bombardment: GameProtocol {
    
    func run() {
        printHeader(title: "Bombardment")
        println(3)
        println("You are on a battlefield with 4 platoons and you")
        println("have 25 outposts available where they may be placed.")
        println("You can only place one platoon at any one outpost.")
        println()
        println("The object of the game is to fire missiles at the")
        println("outposts of the computer.  It will do the same to you.")
        println("The one who destroys all four of the enemy's platoons")
        println("first is the winner.")
        println()
        println("Good luck... and tell us where you want the bodies sent!")
        println()
        println("Tear off the matrix and use it to check off the numbers.")
        println(5)
        
        wait(.short)
        
        for r in 0...4 {
            let i = r * 5 + 1
            print(" ")
            println(i, i + 1, i + 2, i + 3, i + 4)
        }
        println(10)
        wait(.short)
        
        var computerPositions = [Int]()  //c,d,e,f
        while computerPositions.count < 4 {
            let position = Int.random(in: 1...25)
            if !computerPositions.contains(position) { computerPositions.append(position) }
        }
        
        var userPositions = getUserPositions()
        println()
        
        var computerMissiles = [Int]()
        
        while userPositions.count > 0 || computerPositions.count > 0 {
            //500-560, 630-640
            let y = Int(input("Where do you wish to fire your missile")) ?? 0
            if computerPositions.contains(y) {
                computerPositions.removeAll { $0 == y }
                
                if computerPositions.count == 0 {
                    //890-910
                    println("You got me, I'm going fast.  But I'll get you when")
                    println(" y transistors secupera e")
                    wait(.short)
                    showEasterEgg(.bombardment)
                    end()
                }
                
                //730...860
                println("You got one of my outposts.")
                switch computerPositions.count {
                case 3: println("One down, three to go")
                case 2: println("Two down, two to go")
                case 1: println("Three down, one to go")
                default:
                    fatalError("Invalid computer position count \(computerPositions.count)")
                }
            } else {
                println(" Ha, Ha you missed.  My turn now")
            }
            println(2)
            
            //570-620, 670-680
            var m = Int.random(in: 1...25)
            while computerMissiles.contains(m) { m = Int.random(in: 1...25) }
            computerMissiles.append(m)
            
            if userPositions.contains(m) {
                userPositions.removeAll { $0 == m }
                
                if userPositions.count == 0 {
                    println("You're dead. Your last outpost wat at \(m). Ha, ha, ha.")
                    println("Better luck next time.")
                    end()
                }
                
                //940-1080
                println("I got you.  It won't be long now.  Post \(m) was hit.")
                switch userPositions.count {
                case 3: println("You only have three outposts left.")
                case 2: println("You only have two outposts left.")
                case 1: println("You only have one outpost left.")
                default:
                    fatalError("Invalid user position count \(userPositions.count)")
                }
            } else {
                println("I missed you, you dirty rat.  I picked \(m).  Your turn.")
            }
            println()
        }
    }
    
    //480-490 plus illegal entry checking
    private func getUserPositions() -> [Int] {
        let delimeters = CharacterSet.whitespacesAndNewlines.union(CharacterSet.punctuationCharacters)
        let entries = input("What are your positions").components(separatedBy: delimeters)
        let positions = (entries.compactMap { Int($0) }).filter { $0 > 0  && $0 < 26 }
        guard positions.count == Set(positions).count, positions.count == 4 else {
            println("You must enter 4 unique positions from 1 to 25")
            return getUserPositions()
        }
        return positions
    }
}
