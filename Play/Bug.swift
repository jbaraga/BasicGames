//
//  Bug.swift
//  Bug
//
//  Created by Joseph Baraga on 1/14/23.
//

import Foundation


class Bug: BasicGame {
    private enum Player {
        case computer
        case user
        
        var isUser: Bool {
            return self == .user
        }
        
        var pronoun: String {
            switch self {
            case .computer: return "I"
            case .user: return "You"
            }
        }
    }
    
    private enum BodyPart: Int, CaseIterable, CustomStringConvertible {
        case body = 1
        case neck = 2
        case head = 3
        case feeler = 4
        case tail = 5
        case leg = 6
        
        var description: String {
            switch self {
            case .body: return "Body"
            case .neck: return "Neck"
            case .head: return "Head"
            case .feeler: return "Feeler"
            case .tail: return "Tail"
            case .leg: return "Leg"
            }
        }
        
        var instructionStringValue: String {
            switch self {
            case .body, .neck, .head, .tail:
                return description
            case .feeler:
                return "Feelers"
            case .leg:
                return "Legs"
            }
        }
        
        var rollResultStringValue: String {
            switch self {
            case .body, .neck, .head, .tail, .leg:
                return description
            case .feeler:
                return "Feelers"
            }
        }

        
        var prerequistePart: BodyPart? {
            switch self {
            case .body: return nil
            case .neck, .tail, .leg: return .body
            case .head: return .neck
            case .feeler: return .head
            }
        }
    }
    
    private struct LadyBug {
        let player: Player
        
        var parts = [BodyPart: Int]()
        
        var partCount: Int {
            return parts.reduce(0, { $0 + $1.value })
        }
        
        var isComplete: Bool {
            return BodyPart.allCases.reduce(true) { result, part in
                return result && number(of: part) == Self.required(numberOf: part)
            }
        }
        
        func number(of part: BodyPart) -> Int {
            return parts[part] ?? 0
        }
        
        func isMissing(_ part: BodyPart) -> Bool {
            return number(of: part) < Self.required(numberOf: part)
        }
        
        mutating func add(_ part: BodyPart) -> String {
            switch part {
            case .body:
                if isMissing(part) {
                    parts[part] = (parts[part] ?? 0) + 1
                    return "\(player.pronoun) now have a body."
                } else {
                    return "\(player.pronoun) do not need a body."
                }
            case .neck:
                if isMissing(part) {
                    if let requiredPart = part.prerequistePart, isMissing(requiredPart) {
                        return "\(player.pronoun) do not have a \(requiredPart)."
                    } else {
                        parts[part] = (parts[part] ?? 0) + 1
                        return "\(player.pronoun) now have a neck."
                    }
                } else {
                    return "\(player.pronoun) do not need a neck."
                }
            case .head:
                if let requiredPart = part.prerequistePart, isMissing(requiredPart) {
                    return player.pronoun + " do not have a \(requiredPart)."
                } else {
                    if isMissing(part) {
                        parts[part] = (parts[part] ?? 0) + 1
                        return "\(player.pronoun) needed a head."
                    } else {
                        return player.isUser ? "You have a head." : "I do not need a head."
                    }
                }
            case .feeler:
                if let requiredPart = part.prerequistePart, isMissing(requiredPart) {
                    return "\(player.pronoun) do not have a \(requiredPart)."
                } else {
                    if isMissing(part) {
                        parts[part] = (parts[part] ?? 0) + 1
                        return player.isUser ? "I now give you a feeler." : "I get a feeler."
                    } else {
                        return "\(player.pronoun) have two feelers already."
                    }
                }
            case .tail:
                if let requiredPart = part.prerequistePart, isMissing(requiredPart) {
                    return "\(player.pronoun) do not have a \(requiredPart)."
                } else {
                    if isMissing(part) {
                        parts[part] = (parts[part] ?? 0) + 1
                        return player.isUser ? "I now give you a tail." : "I now have a tail."
                    } else {
                        return player.isUser ? "You already have a tail." : "I do not need a tail."
                    }
                }
            case . leg:
                if isMissing(part) {
                    if let requiredPart = part.prerequistePart, isMissing(requiredPart) {
                        return "\(player.pronoun) do not have a \(requiredPart)."
                    } else {
                        let l = (parts[part] ?? 0) + 1
                        parts[part] = l
                        return "\(player.pronoun) now have \(l) legs."
                    }
                } else {
                    return player.isUser ? "You have 6 feet already." : "I have 6 feet."
                }
            }
        }
                
        static func required(numberOf part: BodyPart) -> Int {
            switch part {
            case .body:
                return 1
            case .neck:
                return 1
            case .head:
                return 1
            case .feeler:
                return 2
            case .tail:
                return 1
            case .leg:
                return 6
            }
        }
    }
    
    func run() {
        printHeader(title: "Bug")
        println("The Game Bug")
        println("I hope you enjoy this game.")
        println()
        
        let response = Response(input("Do you want instructions"))
        switch response {
        case .no:
            break
        default:
            printInstructions()
            wait(.short)
        }
        
        play()
    }
    
    //Lines 120-290
    private func printInstructions() {
        println("The object of Bug is to finish your bug before I finish")
        println("mine.  Each number stands for a part of the bug body.")
        println("I will roll the die for you, tell you what I rolled for you")
        println("what the number stands for, and if you can get the part,")
        println("If you can get the part I will give it to you.")
        println("The same will happen on my turn.")
        println("If there is a change in either bug I will give you the")
        println("option of seeing the pictures of the bugs.")
        println("The numbers stand for parts as follows:")
        println("Number", "Part", "Number of Part Needed")
        
        BodyPart.allCases.forEach { part in
            let partName: String
            switch part {
            case .body, .neck, .head, .tail:
                partName = part.description
            case .feeler:
                partName = "Feelers"
            case .leg:
                partName = "Legs"
            }
            println("\(part.rawValue)", partName, "\(LadyBug.required(numberOf: part))")
        }
                    
        println(2)
    }
    
    //MARK: Play game
    private func play() {
        var yourBug = LadyBug(player: .user)
        var myBug = LadyBug(player: .computer)
        
        //Lines 300-1740: main loop
        while !yourBug.isComplete && !myBug.isComplete {
            let yourCount = yourBug.partCount
            let myCount = myBug.partCount
            
            wait(.short)
            
            let z = Int(6 * rnd(1) + 1)
            println("You rolled a  \(z)")
            guard let yourPart = BodyPart(rawValue: z) else {
                fatalError("BodyPart rawValue \(z) out of range.")
            }
            println("\(z)=" + yourPart.rollResultStringValue)
            println(yourBug.add(yourPart))
            
            wait(.short)
            
            let x = Int(6 * rnd(1) + 1)
            println("I rolled a \(x)")
            guard let myPart = BodyPart(rawValue: x) else {
                fatalError("BodyPart rawValue \(x) out of range.")
            }
            println("\(x)=" + myPart.rollResultStringValue)
            println(myBug.add(myPart))
            
            if yourBug.isComplete {
                println("Your bug is finished.")
            }
            
            if myBug.isComplete {
                println("My bug is finished.")
            }

            if yourCount != yourBug.partCount || myCount != myBug.partCount {
                let response = Response(input("Do you want the pictures"))
                switch response {
                case .no:
                    break
                default:
                    println("*****Your Bug*****")
                    println(2)
                    print(bug: yourBug)
                    println(4)
                    println("******My Bug******")
                    println(3)
                    print(bug: myBug)
                    
                }
            }
        }
        
        wait(.short)
        println("I hope you enjoyed the game, play it again soon!!")
        
        if yourBug.isComplete { unlockEasterEgg(.bug) }
        end()
    }
    
    //Lines 1780-2530
    private func print(bug: LadyBug) {
        if bug.number(of: .feeler) > 0 {
            for _ in 1...4 {
                print(tab(10))
                for _ in 1...bug.number(of: .feeler) {
                    print(bug.player.isUser ? "A " : "F ")
                }
                println()
            }
        }
        
        if !bug.isMissing(.head) {
            println("        HHHHHHH")
            println("        H     H")
            println("        H O O H")
            println("        H     H")
            println("        H  V  H")
            println("        HHHHHHH")
        }
        
        if !bug.isMissing(.neck) {
            println("          N N")
            println("          N N")
        }
        
        if !bug.isMissing(.body) {
            println("     BBBBBBBBBBBB")
            println("     B          B")
            println("     B          B")
            if bug.isMissing(.tail) {
                println("     B          B")
            } else {
                println("TTTTTB          B")
            }
            println("     BBBBBBBBBBBB")
        }
        
        if bug.number(of: .leg) > 0 {
            for _ in 1...2 {
                print(tab(5))
                for _ in 1...bug.number(of: .leg) {
                    print(" L")
                }
                println()
            }
        }
    }
    
    func test() {
        //TODO: Implement
    }
}

