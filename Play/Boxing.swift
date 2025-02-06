//
//  Boxing.swift
//  play
//
//  Created by Joseph Baraga on 2/3/25.
//

import Foundation

class Boxing: BasicGame {
    
    private enum Punch: Int, CaseIterable, CustomStringConvertible {
        case fullSwing = 1, hook, uppercut, jab
        
        var description: String {
            switch self {
            case .fullSwing: return "Full Swing"
            case .hook: return "Hook"
            case .uppercut: return "Uppercut"
            case .jab: return "Jab"
            }
        }
    }
    
    private struct Boxer: CustomStringConvertible {
        let name: String  //J$, L$
        var bestPunch = Punch.fullSwing  //B1, B
        var vulnerabilty = Punch.hook  //D1, D
        
        var score = 0  //Y, X
        var roundsWon: Int = 0  //J, L
        
        var description: String { name }
    }
    
    func run() {
        printHeader(title: "Boxing")
        println("Boxing Olympic Style (3 rounds -- 2 out of 3 wins)")
        play()
    }
    
    private func play() {
        var computer = Boxer(name: input("What is your opponent's name"))  //J$
        var user = Boxer(name: input("Input your man's name"))  //L$
        
        println("Different punches are " + Punch.allCases.map { "\($0.rawValue) \($0)" }.joined(separator: " "))
        user.bestPunch = Punch(rawValue: Int(input("What is your man's best")) ?? 1) ?? .fullSwing
        user.vulnerabilty = Punch(rawValue: Int(input("What is his vulnerability")) ?? 1) ?? .fullSwing
        
        computer.bestPunch = Punch.allCases.randomElement() ?? .fullSwing
        computer.vulnerabilty = Punch.allCases.filter { $0 != computer.bestPunch }.randomElement() ?? .hook
        println("\(computer)'s advantage is \(computer.bestPunch.rawValue) and vulnerability is secret.")
        
        for round in 1...3 {
            println("Round \(round) begins...")
            println()
            computer.score = 0  //Y
            user.score = 0  //X
            
            //185-950
            for _ in 1...7 {
                let i = Int.random(in: 1...10)
                if i > 5 {
                    //600-940
                    let punch = Punch.allCases.randomElement() ?? .fullSwing
                    if punch == computer.bestPunch { computer.score += 2 }
                    switch punch {
                    case .fullSwing:
                        //720-800
                        print("\(computer)  takes a full swing")
                        if user.vulnerabilty == punch || Int.random(in: 1...60) < 30 {
                            println(" pow!!! He hits him right in the face!")
                            if computer.score > 35 {
                                print("\(user) is knocked cold and \(computer) is the winner and champ ")
                                boutOver()
                            }
                            computer.score += 15
                        } else {
                            println(" but it's blocked ")
                        }
                    case .hook, .uppercut:
                        //810-940
                        if punch == .hook {
                            println("\(computer) gets \(user) in the jaw (ouch!)")
                            computer.score += 7
                            println("....and again!")
                            computer.score += 7
                            if computer.score > 35 {
                                print("\(user) is knocked cold and \(computer) is the winner and champ ")
                                boutOver()
                            }
                        }
                        
                        println("\(user) is attacked by an uppercut (oh,oh)...")
                        if user.vulnerabilty == .uppercut || Int.random(in: 1...200) <= 75 {
                            println(" and \(computer) connects...")
                            computer.score += 7
                        } else {
                            println(" blocks and hits \(computer) with a hook.")
                            user.score += 5
                        }
                    case .jab:
                        //640-710
                        print("\(computer) jabs and ")
                        if user.vulnerabilty == punch || Int.random(in: 1...7) > 4 {
                            println(" blood spills")  //Bug in line 645, skips this line
                            computer.score += 5
                        } else {
                            println(" it's blocked !")
                        }
                    }
                } else {
                    //210-590
                    let punch = Punch(rawValue: Int(input("\(user)'s punch")) ?? 1) ?? .fullSwing
                    if punch == user.bestPunch { user.score += 2 }
                    switch punch {
                    case .fullSwing:
                        //340-440
                        print("\(user) swings and ")
                        if computer.vulnerabilty == punch || Int.random(in: 1...30) < 10 {
                            println("he connects!")
                            if user.score > 35 {
                                print("\(computer) is knocked cold and \(user) is the winnner and champ")
                                boutOver()
                            }
                            user.score += 15
                        } else {
                            println("he misses ")
                            if user.score != 1 { println(2) }
                        }
                    case .hook:
                        //450-490
                        print("\(user) gives the hook... ")
                        if computer.vulnerabilty == punch || Int.random(in: 1...2) == 2 {
                            println("connects...")  //Bug in 455, skips this line
                            user.score += 7
                        } else {
                            println("but it's blocked!!!!!!!!!!!!!")
                        }
                    case .uppercut:
                        //520-590
                        print("\(user)  tries an uppercut   ")
                        if computer.vulnerabilty == .uppercut || Int.random(in: 1...100) < 51 {
                            println("and he connects!")
                            user.score += 4
                        } else {
                            println(" and it's blocked (lucky block!)")
                        }
                    case .jab:
                        //270-330
                        println("\(user) jabs at \(computer)'s head ")  //Bug no return
                        if computer.vulnerabilty == punch || Int.random(in: 1...8) >= 4 {
                            user.score += 3
                        } else {
                            println("it's blocked")
                        }
                    }
                }
            }
            
            if computer.score > user.score {
                println("\(computer) wins round \(round)")
                computer.roundsWon += 1
            } else {
                println("\(user) wins round \(round)")
                user.roundsWon += 1
            }

            if computer.roundsWon >= 2 {
                println("\(computer) wins (nice going \(computer))")
                boutOver()
            }
            
            if user.roundsWon >= 2 {
                println("\(user) amazingly wins  ")
                unlockEasterEgg(.boxing)
                boutOver()
            }
        }
    }
    
    private func boutOver() -> Never {
        println(2)
        println("And now goodbye from the Olympic arena.")
        println()
        end()
    }
}
