//
//  Combat.swift
//  play
//
//  Created by Joseph Baraga on 1/29/25.
//

import Foundation

class Combat: BasicGame {
    
    private enum Branch: Int, CaseIterable {
        case army = 1, navy, airForce
        
        var label: String {
            switch self {
            case .army: return "Army"
            case .navy: return "Navy"
            case .airForce: return "A.F."
            }
        }
    }
    
    private struct Forces {
        var army = 30000
        var navy = 20000
        var airForce = 22000
        
        var total: Int { army + navy + airForce }
        
        init() {}
        
        init?(army: Int, navy: Int, airForce: Int) {
            guard army + navy + airForce <= 72000 else { return nil }
            self.army = army
            self.navy = navy
            self.airForce = airForce
        }
        
        func troops(for branch: Branch) -> Int {
            switch branch {
            case .army: return army
            case .navy: return navy
            case .airForce: return airForce
            }
        }
        
        mutating func lost(men: Int, from branch: Branch) {
            switch branch {
            case .army: army -= men
            case .navy: navy -= men
            case .airForce: airForce -= men
            }
        }

        mutating func reduce(branch: Branch, to fraction: Double) {
            switch branch {
            case .army: army = Int(Double(army) * fraction)
            case .navy: navy = Int(Double(navy) * fraction)
            case .airForce: airForce = Int(Double(airForce) * fraction)
            }
        }
    }
    
    func run() {
        printHeader(title: "Combat")
        play()
        end()
    }
    
    private func play() {
        println("I am at war with you.")
        println("We have 72000 soldiers apiece.")
        var computerForces = Forces()
        var userForces = getForces(computer: computerForces)
        
        println("You attack first. Type 1 for army  2 for navy")
        println("and 3 for air force.")
        var branch = Branch(rawValue: Int(input()) ?? 1) ?? .army  //Y
        var attackForceSize = getNumber(for: branch, forces: userForces)  //A,B,C
        var computerForceSize = computerForces.troops(for: branch)
        
        if attackForceSize < computerForceSize / 3 {
            switch branch {
            case .army: println("You lost \(attackForceSize) from your army.")
            case .navy: println("Your attack was stopped!")
            case .airForce: println("Your attack was wiped out.")
            }
            userForces.lost(men: attackForceSize, from: branch)
        } else if attackForceSize < 2 * computerForceSize / 3 {
            switch branch {
            case .army:
                println("You lost \(attackForceSize / 3) men but I lost \(2 * computerForceSize / 3)")
                userForces.lost(men: attackForceSize / 3, from: branch)
                computerForces.reduce(branch: branch, to: 1/3)  //160 D=0 - presumed bug
            case .navy:
                println("You destroyed \(2 * computerForceSize / 3) of my navy")  //500 bug army
                computerForces.reduce(branch: branch, to: 1/3)
            case .airForce:
                println("We had a dogfight- you won- and finished your mission.")
                computerForces.reduce(branch: .army, to: 2/3)
                computerForces.reduce(branch: .navy, to: 1/3)
                computerForces.reduce(branch: .airForce, to: 1/3)
            }
        } else {
            switch branch {
            case .army, .navy:
                println("You sunk 1 of my patrol boats but I wiped out 2")
                println("of your A.F. bases and 3 army bases.")
                userForces.reduce(branch: .army, to: 1/3)
                userForces.reduce(branch: .airForce, to: 1/3)
                computerForces.reduce(branch: .navy, to: 2/3)
            case .airForce:
                println("You wiped out one of my army patrols, but I destroyed")
                println("2 navy bases and bombed 3 army bases.")
                userForces.reduce(branch: .army, to: 1/4)
                userForces.reduce(branch: .navy, to: 1/3)
                computerForces.reduce(branch: .army, to: 2/3)
            }
        }
        
        println()  //500
        println("", "You", "Me")
        for branch in Branch.allCases {
            println(branch.label, " \(userForces.troops(for: branch))", " \(computerForces.troops(for: branch))")
        }
        
        println("What is your next move?")
        println("Army=1  Navy=2  Air Force=3")
        branch = Branch(rawValue: Int(input()) ?? 1) ?? .army  //G
        attackForceSize = getNumber(for: branch, forces: userForces)  //T
        computerForceSize = computerForces.troops(for: branch)
        
        if attackForceSize < computerForceSize / 2 {
            switch branch {
            case .army:
                println("I wiped out your attack!")
                userForces.lost(men: attackForceSize, from: branch)
            case .navy:
                println("I sunk 2 of your battleships, and my air force")
                println("wiped out your unguarded capitol.")  //1751 spelling corrected
                userForces.reduce(branch: .army, to: 1/4)
                userForces.reduce(branch: .navy, to: 1/2)
            case .airForce:
                println("One of your planes crashed into my house.  I am dead.")
                println("My country fell apart.")
                println("You won, oh! Shucks!!!!")
                unlockEasterEgg(.combat)
                return
            }
        } else {
            switch branch {
            case .army:
                println("You destroyed my army!")
                computerForces.reduce(branch: branch, to: 0)
            case .navy:
                println("Your navy shot down three of my XIII planes,")
                println("and sunk 3 battleships.")
                computerForces.reduce(branch: .airForce, to: 2/3)
                computerForces.reduce(branch: .navy, to: 1/2)
            case .airForce:
                //1830 - original code followed but results in defeat with larger air force attack
                println("My navy and air force in a combined attack left")
                println("your country in shambles.")
                Branch.allCases.forEach { userForces.reduce(branch: $0, to: 1/3) }
            }
        }
        
        println()
        println("From the results of both of your attacks,")
        if userForces.total > 3 * computerForces.total / 2 {
            println("you won, oh! Shucks!!!!")
            unlockEasterEgg(.combat)
        } else if userForces.total < 2 * computerForces.total / 3 {
            println("you lost-I conquered your country.  It serves you")
            println("right for playing this stupid game!!!")
        } else {
            println("the Treaty of Paris concluded that we take our")
            println("respective countries and live in peace.")
        }
    }
    
    private func getForces(computer: Forces) -> Forces {
        println("Distribute your forces.")
        println("", "Me", "You")
        print("Army", " \(computer.army)", "")
        let army = Int(input())
        print("Navy", " \(computer.navy)", "")
        let navy = Int(input())
        print("A.F.", " \(computer.airForce)", "")
        let airForce = Int(input())
        guard let army, let navy, let airForce, let forces = Forces(army: army, navy: navy, airForce: airForce) else {
            return getForces(computer: computer)
        }
        return forces
    }
    
    private func getNumber(for branch: Branch, forces: Forces) -> Int {
        println("How many men")
        guard let number = Int(input()), number <= forces.troops(for: branch), number >= 0 else {
            return getNumber(for: branch, forces: forces)
        }
        return number
    }
    
}

