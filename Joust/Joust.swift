//
//  Joust.swift
//  Joust
//
//  Created by Joseph Baraga on 2/11/22.
//

import Foundation


class Joust: GameProtocol {
    
    private enum AimingPoint: Int, CaseIterable {
        case helm = 1
        case upperLeft = 2
        case upperMiddle = 3
        case upperRight = 4
        case lowerLeft = 5
        case lowerMiddle = 6
        case lowerRight = 7
        case baseOfShield = 8
        
        var stringValue: String {
            switch self {
            case .helm: return "Helm"
            case .upperLeft: return "Upper Left"
            case .upperMiddle: return "Upper Middle"
            case .upperRight: return "Upper Right"
            case .lowerLeft: return "Lower Left"
            case .lowerMiddle: return "Lower Middle"
            case .lowerRight: return "Lower Right"
            case .baseOfShield: return "Base of Shield"
            }
        }
        
        var description: String {
            switch self {
            case .upperLeft: return "\(rawValue)- " + stringValue + " (of shield)"
            default: return "\(rawValue)- " + stringValue
            }
        }
        
        var defensePositions: [DefensePosition] {
            switch self {
            case .helm, .lowerLeft, .lowerRight:
                return [.steadySeat, .shieldHigh, .shieldLow]  //Line 1550
            case .upperLeft:
                return [.leftLean, .steadySeat, .shieldHigh, .shieldLow]  //Line 1650
            case .upperMiddle, .lowerMiddle:
                return [.lowerHelm, .rightLean, .leftLean, .shieldLow, .shieldHigh, .shieldLow]  //Line 1750
            case .upperRight:
                return [.rightLean, .steadySeat, .shieldHigh, .shieldLow]  //Line 1850
            case .baseOfShield:
                return [.lowerHelm, .steadySeat, .shieldHigh, .shieldLow]  //Line 1950
            }
        }
        
        var positionsString: String {
            return (defensePositions.map { $0.description }).joined(separator: ", ")
        }
    }
    
    private enum DefensePosition: Int {
        case lowerHelm = 1
        case rightLean = 2
        case leftLean = 3
        case steadySeat = 4
        case shieldHigh = 5
        case shieldLow = 6
        
        var stringValue: String {
            switch self {
            case .lowerHelm: return "Lower Helm"
            case .rightLean: return "Right Lean"
            case .leftLean: return "Left Lean"
            case .steadySeat: return "Steady Seat"
            case .shieldHigh: return "Shield High"
            case .shieldLow: return "Shield Low"
            }
        }
        
        var description: String {
            return "\(rawValue)-" + stringValue
        }
    }
    
    private enum ResultState {
        case defense
        case offense
    }
    
    private enum Result {
        case missed
        case glancedOff
        case deHelmed
        case brokeLance
        case unseated
        case brokeLanceInjuredAndUnseated
        case injuredAndUnseated
        case brokeLanceAndUnseated
        
        func description(for state: ResultState) -> String {
            switch state {
            case .defense:
                switch self {
                case .missed:
                    return "He missed you!" //Line 2600
                case .glancedOff:
                    return "He hit your shield but it glanced off."  //Line 2650
                case .deHelmed:
                    return "He knocked off your helm!"  //Line 2700
                case .brokeLance:
                    return "He broke his lance."  //Line 2750
                case .unseated:
                    return "He has unseated you (thud!)"  //Line 2800
                case .brokeLanceInjuredAndUnseated:
                    return "He has broken his lance, injured and unseated you (ouch!)" //Line 2850
                case .injuredAndUnseated:
                    return "He has injured and unseated you (crash!)"  //Line 2900
                case .brokeLanceAndUnseated:
                    return "He has broken his lance and unseated you (clang!)"  //Line 2950
                }
            case .offense:
                switch self {
                case .missed:
                    return "You missed him (hiss!)"
                case .glancedOff:
                    return "You hit his shield but glanced off."
                case .deHelmed:
                    return "You knocked off his helm! (Cheers!)"
                case .brokeLance:
                    return "You broke your lance (crack..)"
                case .unseated:
                    return "You unseated him (loud cheers and huzzahs!!)"
                case .brokeLanceInjuredAndUnseated:
                    return "You broke your lance, but unseated and injured your foe."
                case .injuredAndUnseated:
                    return "You injured and unseated your opponent."
                case .brokeLanceAndUnseated:
                    return "You broke your lance but unseated your opponent."
                }
            }
        }
        
        //S and T
        var value: Int {
            switch self {
            case .missed, .glancedOff, .deHelmed, .brokeLance:
                return 0
            case .unseated, .brokeLanceAndUnseated, .injuredAndUnseated, .brokeLanceInjuredAndUnseated:
                return 5
            }
        }
        
        init(for point: AimingPoint, position: DefensePosition) {
            switch point {
            case .helm:
                switch position {
                case .lowerHelm: self = .missed
                case .rightLean: self = .missed
                case .leftLean: self = .missed
                case .steadySeat: self = .deHelmed
                case .shieldHigh: self = .unseated
                case .shieldLow: self = .missed
                }
            case .upperLeft:
                switch position {
                case .lowerHelm: self = .unseated
                case .rightLean: self = .brokeLance
                case .leftLean: self = .missed
                case .steadySeat: self = .brokeLance
                case .shieldHigh: self = .brokeLance
                case .shieldLow: self = .missed
                }
            case .upperMiddle:
                switch position {
                case .lowerHelm: self = .brokeLanceInjuredAndUnseated
                case .rightLean: self = .unseated
                case .leftLean: self = .glancedOff
                case .steadySeat: self = .brokeLance
                case .shieldHigh: self = .brokeLanceAndUnseated
                case .shieldLow: self = .injuredAndUnseated
                }
            case .upperRight:
                switch position {
                case .lowerHelm: self = .glancedOff
                case .rightLean: self = .missed
                case .leftLean: self = .brokeLance
                case .steadySeat: self = .glancedOff
                case .shieldHigh: self = .glancedOff
                case .shieldLow: self = .unseated
                }
            case .lowerLeft:
                switch position {
                case .lowerHelm: self = .brokeLance
                case .rightLean: self = .brokeLanceAndUnseated
                case .leftLean: self = .missed
                case .steadySeat: self = .brokeLance
                case .shieldHigh: self = .missed
                case .shieldLow: self = .brokeLance
                }
            case .lowerMiddle:
                switch position {
                case .lowerHelm: self = .brokeLanceAndUnseated
                case .rightLean: self = .glancedOff
                case .leftLean: self = .brokeLance
                case .steadySeat: self = .brokeLanceAndUnseated
                case .shieldHigh: self = .brokeLanceInjuredAndUnseated
                case .shieldLow: self = .brokeLance
                }
            case .lowerRight:
                switch position {
                case .lowerHelm: self = .glancedOff
                case .rightLean: self = .missed
                case .leftLean: self = .brokeLanceAndUnseated
                case .steadySeat: self = .glancedOff
                case .shieldHigh: self = .glancedOff
                case .shieldLow: self = .glancedOff
                }
            case .baseOfShield:
                switch position {
                case .lowerHelm: self = .brokeLance
                case .rightLean: self = .glancedOff
                case .leftLean: self = .brokeLanceInjuredAndUnseated
                case .steadySeat: self = .brokeLance
                case .shieldHigh: self = .brokeLanceInjuredAndUnseated
                case .shieldLow: self = .brokeLance
                }
            }
        }
    }
        
    func run() {
        println(tab(26), "Joust")
        println(tab(20), "Creative Computing")
        println(tab(18), "Morristown, New Jersey")
        println(3)
        let name = input("What is your name, please")
        println("Sir " + name + ", you are a medieval knight in a jousting tournament.")
        println("The prize to the winner is the princess' hand in marriage.")
        println("To win, you must beat four other knights.")
        println("To joust, you pick an aiming point for the lance,")
        println("and then one of from 3 to 6 different possible defense positions.")
        println("The aiming points are:")
        AimingPoint.allCases.forEach {
            println($0.description)
        }
        println()
        println("If you break a lance or lose a helm, you will be given another.")
        println("Good luck, sir!")
        println()
        
        //Line 700 REM OFF YOU GO TO THE FOUR JOUSTS
        //Lines 600-1270
        for a in 1...4 {
            switch a {
            case 1:
                println("This is your first joust. You are up against the Gold Knight.")
            case 2:
                println("This is your second joust. Your opponent is the Silver Knight.")
            case 3:
                println("You are doing well! Your third joust is against the Red Knight.")
            case 4:
                println("This is your final test!! If you win this one the princess")
                println("is yours!! This fight is against the fierce Black Knight!!!!")
            default:
                fatalError("Illegal round")
            }
            
            joust()
        }
        
        println("Hooray! You are the winnner. Here comes the bride!")
        wait(.short)
        let response = input("Hit return to exit")
        if response.isEasterEgg {
            showEasterEgg(Egg.joust.filename)
        }
        end()
    }
    
    private func joust() {
        var b = 0  //Line 1400 - Aiming point
        while b < 1 || b > 8 {
            b = Int(input("Your aiming point(1-8)")) ?? 0
        }
        guard let aimingPoint = AimingPoint(rawValue: b) else {
            fatalError("Illegal aim point")
        }
        
        print("You may use one of these defenses:")
        println(" " + aimingPoint.positionsString + ".")
        let c = Int(input("What is your choice")) ?? 1  //Defense position
        let position = DefensePosition(rawValue: c) ?? aimingPoint.defensePositions.first ?? .steadySeat
        
        //Opponent aimPoint
        let d = Int(rnd(1) * 8) + 1
        guard let opponentAimPoint = AimingPoint(rawValue: d) else {
            fatalError("Illegal opponent aim point")
        }
        
        //Opponent position
        let e = Int(rnd(1) * 6) + 1
        guard let opponentPosition = DefensePosition(rawValue: e) else {
            fatalError("Illegal opponent position")
        }
        let defenseResult = Result(for: opponentAimPoint, position: position)
        let attackResult = Result(for: aimingPoint, position: opponentPosition)
        
        println(defenseResult.description(for: .defense))
        println(attackResult.description(for: .offense))
        
        let s = defenseResult.value
        let t = attackResult.value
        
        switch s {
        case _ where s == t:
            if s == 0 {
                println("You are now ready to try again.")
                joust()
            } else {
                println("Too bad, you both lost. At least your honor is intact.")
                failure()
            }
        case _ where s < t:
            println("You have won this joust.")
            println()
            return
        case _ where s > t:
            println("Too bad, you lost. Hope your insurance was paid up.")
            failure()
        default:
            fatalError()
        }
    }
    
    func failure() {
        println("Sorry, better luck next joust.")
        end()
    }
}
