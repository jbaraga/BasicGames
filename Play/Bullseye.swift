//
//  Bullseye.swift
//  Bullseye
//
//  Created by Joseph Baraga on 12/17/24.
//

import Foundation


class Bullseye: BasicGame {
    
    func run() {
        printHeader(title: "Bullseye")
        println("In this game, up to 20 players throw darts at a target")
        println("with 10, 20, 30, and 40 point zones.  The objective is")
        println("to get 200 points.")
        println("Throw", tab(20), "Description", tab(45), "Probable score")
        println(" 1", tab(20), "Fast overarm", tab(45), "Bullseye or complete miss")
        println(" 2", tab(20), "Controlled overarm", tab(45), "10, 20 or 20 points")
        println(" 3", tab(20), "Underarm", tab(45), "Anything")
        println()
        
        play()
    }
    
    private func play() {
        var players: [String] = []  //A$
        var scores: [Int] = []  //S
        
        let n = Int(input("How many players")) ?? 0
        guard n > 0 else { end() }
        
        for i in 0..<n {
            players.append(input("Name of player # \(i+1)"))
            scores.append(0)
        }
        
        var round = 0  //R
        while (scores.max() ?? 0) < 200 {
            round += 1
            println()
            println("Round", round)
            for i in 0..<n {
                var t = 0
                while t < 1 || t > 3 {
                    println()
                    t = Int(input("\(players[i])'s throw")) ?? -1
                    if t < 1 || t > 3 {
                        print("Input 1, 2, or 3!")
                    }
                }
                var p1 = 0.0
                var p2 = 0.0
                var p3 = 0.0
                var p4 = 0.0
                switch t {
                case 1:
                    p1 = 0.65
                    p2 = 0.55
                    p3 = 0.5
                    p4 = 0.5
                case 2:
                    p1 = 0.99
                    p2 = 0.77
                    p3 = 0.43
                    p4 = 0.01
                case 3:
                    p1 = 0.95
                    p2 = 0.75
                    p3 = 0.45
                    p4 = 0.05
                default:
                    fatalError( "Invalid throw \(t)!")
                }
                
                let u = rnd()
                var b = 0  //B
                if u >= p1 {
                    println("Bullseye!!  40 points!")
                    b = 40
                } else if u >= p2 {
                    println("30-point zone!")
                    b = 30
                } else if u >= p3 {
                    println("20-point zone")
                    b = 20
                } else if u >= p4 {
                    println("Whew!  10 points")
                    b = 10
                } else {
                    println("Missed the target!  Too bad.")
                    b = 0
                }
                scores[i] += b
                println("Total score \(scores[i])")
            }
        }
        
        println()
        println("We have a winner!!")
        println()
        zip(players, scores).forEach { player, score in
            if score >= 200 {
                println(player + " scored \(score) points.")
            }
        }
        
        wait(.short)
        println()
        println("Thanks for the game.")
        println()
        
        unlockEasterEgg(.bullseye)
        end()
    }
}
