//
//  BombsAway.swift
//  BombsAway
//
//  Created by Joseph Baraga on 12/16/24.
//

import Foundation
import RegexBuilder


class BombsAway: GameProtocol {
    
    private var successes: Int = 0  //Added var for Easter Egg
    
    func run() {
        printHeader(title: "Bombs Away")
        println(2)
        
        var response = Response.yes
        repeat {
            play()
            wait(.long)
            response = Response(input("Another mission (y or n)"))
        } while response.isYes
        
        if response == .easterEgg, successes > 1 {
            showEasterEgg(.bombsAway)
        } else {
            println("Chicken !!!")
        }
        end()
    }
    
    static let regex = Regex {
        OneOrMore {
            "("
            Capture {
                .digit
            } transform: { Int($0) }
            ")"
        }
    }
    
    private func play() {
        println("You are a pilot in a World War II bomber.")
        
        let a = getChoice(prompt: "What side -- Italy(1), Allies(2), Japan(3), Germany(4)")
        switch a {
        case 1:
            let b = getChoice(prompt: "Your target -- Albania(1), Greece(2), North Africa(3)")
            switch b {
            case 1: println("Should be easy -- you're flying a Nazi-made plane.")
            case 2: println("Be careful!!!")
            case 3: println("You're going for the oil , eh?")
            default:
                fatalError("Invalid option b \(b)")
            }
        case 2:
            let g = getChoice(prompt: "Aircraft -- Liberator(1), B-29(2), B-17(3), Lancaster(4)")
            switch g {
            case 1: println("You've got 2 tons of bombs flying for Ploesti.")
            case 2: println("You're dumping the A-bomb on Hiroshima.")
            case 3: println("You're chasing the Bismarck in the North Sea")
            case 4: println("You're busting a German heavy water plant in the Ruhr.")
            default:
                fatalError("Invalid option g \(g)")
            }
        case 3:
            println("You're flying a kamikaze mission over the USS Lexington.")
            if Response(input("Your first kamikaze mission (y or n)")).isYes {
                println()
                if rnd() > 0.65 {
                    success()
                } else {
                    boom()
                }
            } else {
                payForLying()
            }
            return
        case 4:
            let prompt = "A Nazi, eh?  Oh well.  Are you going for Russia(1),\nEngland(2), or France(3)"
            let m = getChoice(prompt: prompt)
            switch m {
            case 1: println("You're nearing Stalingrad.")
            case 2: println("Nearing London.  Be careful, they've got radar.")
            case 3: println("Nearing Versailles.  Duck soup.  They're nearly defenseless.")
            default:
                fatalError("Invalid option m \(m)")
            }
        default:
            fatalError("Invalid option a \(a)")
        }
        
        //280
        println()
        let d = getMissions()
        println()
        
        if d < Int(160 * rnd()) {
            println("Missed the target by \(Int(2 + 30 * rnd())) miles!")
            println("Now you're really in for it !!")
            println()
            let r = getChoice(prompt: "Does the enemy have guns(1), missiles(2), or both(3)")
            
            var s = 0
            let t = r > 1 ? 35 : 0
            if r != 2 {
                s = getHitRate()
                if s < 10 {
                    payForLying()
                    return
                }
            }
            println()
            if s + t > Int(100 * rnd()) {
                boom()
                return
            } else {
                println("You made it through tremendous flak!!")
            }
        } else {
            success()
        }
    }
    
    private func getChoice(prompt: String) -> Int {
        let options = prompt.matches(of: Self.regex).compactMap { $0.output.1 }
        guard let number = Int(input(prompt)), options.contains(number) else {
            println("Try again...")
            return getChoice(prompt: prompt)
        }
        return number
    }
    
    //285-310
    private func getMissions() -> Int {
        guard let d = Int(input("How many missions have you flown")), d >= 0 else {
            return getMissions()
        }
        guard d < 160 else {
            println("Missions, not miles...")
            println("150 missions is high even for old-timers.")
            print("Now then, ")
            return getMissions()
        }
        
        println()
        if d > 99 {
            println("That's pushing the odds!")
        } else if d < 25 {
            println("Fresh out of training, eh?")
        }
        
        return d
    }
    
    //325-327
    private func success() {
        println("Direct hit!!!! \(Int(100 * rnd())) killed.")
        println("Mission successful.")
        successes += 1
    }
    
    //355 Added invalid input check
    private func getHitRate() -> Int {
        guard let s = Int(input("What's the percent hit rate of enemy gunners")), s >= 0 && s <= 50 else {
            println("Try again...")
            return getHitRate()
        }
        return s
    }
    
    //357-8
    private func payForLying() {
        println("You lie, but you'll pay...")
        boom()
    }
    
    //380-387
    private func boom() {
        println("* * * * Boom * * * *")
        println("You have been shot down.....")
        println("Dearly beloved, we are gathered here today to pay our")
        println("last tribute...")
    }
}
