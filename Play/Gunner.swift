//
//  Gunner.swift
//  play
//
//  Created by Joseph Baraga on 1/19/25.
//

import Foundation

class Gunner: BasicGame {
    
    private let moreTrainingString = "Better go back to Fort Sill for refresher training!"
    
    func run() {
        printHeader(title: "Gunner")
        println("You are the officer-in-charge, giving orders to a gun")
        println("crew, telling them the degrees of elevation you estimate")
        println("will place a projectile on target.  A hit within 100 yards")
        println("of the target will destroy it.")
        println()
        
        test()
        
        repeat {
            play()
            println()
        } while Response(input("Try again (y or n)")) == .yes
    
        println("Ok.  Return to base camp.")
        end()
    }
    
    private func play() {
        let range = Int(40000 * rnd(1) + 20000)
        var totalRounds = 0  //S1
        var z = 0
        
        println("Maximum range of your gun is  \(range)  yards.")
        println()
        
        repeat {
            let target = Int(Double(range) * (0.1 + 0.8 * rnd()))
            println("     Distance to the target is \(target) yards.")
            println()
            
            let rounds = fire(on: target, range: range)
            guard rounds < 6 else {
                println()
                println("Boom !!!!   You have just been destroyed by the enemy.")
                println(3)
                println(moreTrainingString)
                return
            }
            
            totalRounds += rounds
            z += 1
            if z < 5 {
                println()
                println("The forward observer has sighted more enemy activity...")
            }
        } while z < 5
        
        println(2)
        println("Total rounds expended were: \(totalRounds)")
        if totalRounds > 18 {
            println(moreTrainingString)
        } else {
            println("Nice shooting !!")
            unlockEasterEgg(.gunner)
        }
    }
    
    //200-480
    private func fire(on target: Int, range: Int, testElevations: [Double] = []) -> Int {
        var testElevations = testElevations
        var rounds = 0
        repeat {
            let elevation = testElevations.first ?? getElevation()
            
            if testElevations.count > 0 {
                testElevations.removeFirst()
                println("Elevation? \(elevation)")
            }
            
            rounds += 1
            
            if rounds < 6 {
                let shotDistance = Double(range) * sin(2 * elevation * .pi / 180)
                let delta = Int(Double(target) - shotDistance)  //E
                
                if abs(delta) < 100 {
                    println("*** Target Destroyed ***   \(rounds) rounds of ammunition expended")
                    return rounds
                }
                
                if delta > 0 {
                    println("Short of target by \(abs(delta)) yards.")
                } else {
                    println("Over target by \(abs(delta)) yards.")
                }
            }
        } while rounds < 6
        
        return rounds
    }
    
    //390-430
    private func getElevation() -> Double {
        println()
        guard let elevation = Double(input("Elevation")) else { return getElevation() }
        if elevation > 89 {
            println("Maximum elevation is 89 degrees.")
            return getElevation()
        }
        if elevation < 1 {
            println("Minimum elevation is one degree.")
            return getElevation()
        }
        return elevation
    }
}
