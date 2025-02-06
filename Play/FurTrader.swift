//
//  FurTrader.swift
//  play
//
//  Created by Joseph Baraga on 2/3/25.
//

import Foundation

class FurTrader: BasicGame {
    
    private enum Fort: Int, CaseIterable {
        case hochelaga = 1, stadacona, newYork
    }
    
    private enum PeltKind: CaseIterable, CustomStringConvertible {
        case mink, beaver, ermine, fox
        
        var description: String {
            switch self {
            case .mink: return "mink"
            case .beaver: return "beaver"
            case .ermine: return "ermine"
            case .fox: return "fox"
            }
        }
        
        static var sellOrder: [Self] { [.beaver, .fox, .ermine, .mink] }
    }
    
    private struct Pelt {
        let kind: PeltKind
        var number: Int
        var price = 0.0
        
        var proceeds: Double { Double(number) * price }
    }
    
    func run() {
        printHeader(title: "Fur Trader")
        play()
        end()
    }
    
    private func play() {
        printInstructions()
        println("Do you wish to trade furs?")
        
        var savings = 600  //I
        
        while getResponse() == .yes {
            println()
            println("You have $ \(savings) savings.")
            println("And 190 furs to begin the expedition.")
            println()
            println("Your 190 furs are distributed among the following")
            println("kinds of pelts: mink, beaver, ermine and fox.")
            
            var pelts = PeltKind.allCases.map { Pelt(kind: $0, number: 0) }  //F, zero indexed
            for (index, pelt) in pelts.enumerated() {
                println()
                let number = Int(input("How many \(pelt.kind) pelts do you have")) ?? 0
                pelts[index].number = number
                let total = pelts.reduce(0) { $0 + $1.number}
                guard total <= 190 else {
                    println("You may not have that many furs.")
                    println("Do not try to cheat.  I can add.")
                    println("You must start again.")
                    play()
                    return
                }
                if total == 190 { break }
            }
            
            let fort = getFort(withDescription: true)
            switch fort {
            case .hochelaga:
                savings -= 160  //1160
                println()
                
                for (index, pelt) in pelts.enumerated() {
                    switch pelt.kind {
                    case .mink: pelts[index].price = round((0.2 * rnd() + 0.70) * 100) / 100  //M1
                    case .ermine: pelts[index].price = round((0.2 * rnd() + 0.65) * 100) / 100  //E1
                    case .beaver: pelts[index].price = round((0.2 * rnd() + 0.75) * 100) / 100  //B1
                    case .fox: pelts[index].price = round((0.2 * rnd() + 0.80) * 100) / 100  //D1
                    }
                }
                
                println("Supplies at Fort Hochelaga cost $150.00")
                println("Your travel expenses to Hochelaga were $10.00")
                
            case .stadacona:
                savings -= 140  //1198
                println()
                
                for (index, pelt) in pelts.enumerated() {
                    switch pelt.kind {
                    case .mink: pelts[index].price = round((0.3 * rnd() + 0.85) * 100) / 100  //M1
                    case .ermine: pelts[index].price = round((0.15 * rnd() + 0.80) * 100) / 100  //E1
                    case .beaver: pelts[index].price = round((0.2 * rnd() + 0.90) * 100) / 100  //B1
                    case .fox: break  //D1 - not set, bug
                    }
                }
                
                let p = Int.random(in: 1...10)
                if p <= 2 {
                    pelts.removeAll(where: { $0.kind == .beaver })
                    println("Your beaver were too heavy to carry across")
                    println("the portage.  You had to leave the pelts but found")
                    println("them stolen when you returned")
                } else if p <= 6 {
                    println("You arrived safely at Fort Stadacona")
                } else if p <= 8 {
                    pelts = []
                    println("Your canoe upset in the Lachine Rapids.  You")
                    println("lost all your furs")
                } else {
                    pelts[3].number = 0
                    println("Your fox pelts were not cured properly.")
                    println("No one will buy them.")
                }
                
                println("Supplies at Fort Stadacona cost $125.00")
                println("Your travel expenses to Stadacona were $15.00")
                
            case .newYork:
                savings -= 105  //1250
                println()
                
                for (index, pelt) in pelts.enumerated() {
                    switch pelt.kind {
                    case .mink: pelts[index].price = round((0.15 * rnd() + 1.05) * 100) / 100  //M1
                    case .ermine: pelts[index].price = round((0.15 * rnd() + 0.95) * 100) / 100  //E1
                    case .beaver: pelts[index].price = round((0.25 * rnd() + 1.00) * 100) / 100  //B1
                    case .fox: pelts[index].price = round((0.25 * rnd() + 1.10) * 100) / 100  //D1
                    }
                }
                
                let p = Int.random(in: 1...10)
                if p <= 2 {
                    println("You were attacked by a party of Iroquois.")
                    println("All people in your trading group were")
                    println("killed.  This ends the game.")
                    end()
                } else if p <= 6 {
                    println("You were lucky.  You arrived safely")
                    println("at Fort New York.")
                } else if p <= 8 {
                    pelts = []
                    println("You narrowly escaped an Iroquois raiding party.")
                    println("However, you had to leave all your furs behind.")
                } else {
                    pelts[0].price /= 2
                    pelts[1].price /= 2
                    println("Your mink and beaver were damaged on your trip.")
                    println("You receive only half the current price for these furs.")
                }
                
                println("Supplies at New York cost $80.00")
                println("Your travel expenses to New York were $25.00")
            }
            
            if pelts.count == 4 { println() }
            savings += sell(pelts: pelts)
            println()
            println("You now have $ \(savings) including your previous savings")
            
            println()
            println("Do you wish to trade furs next year?")  //511
        }
        
        if savings > 600 { unlockEasterEgg(.furTrader) }
        end()
    }
    
    private func getResponse() -> Response {
        print("Answer yes or no", tab(28))
        return Response(input())
    }
    
    //1091-1099
    private func printInstructions() {
        println("You are the leader of a French fur trading expedition in")
        println("1776 leaving the Lake Ontario area to sell furs and get")
        println("supplies for the next year.  You have a choice of three")
        println("forts at which you may trade.  The cost of supplies")
        println("and the amount you receive for your furs will depend")
        println("on the fort that you choose.")
    }
    
    //1100-1155
    private func getFort(withDescription: Bool = false) -> Fort {
        if withDescription {
            println("Do you want to trade your furs at fort 1, fort 2,")
            println("or fort 3?  Fort 1 is Fort Hochelaga (Montreal)")
            println("and is under the protection of the French Army.")
            println("Fort 2 is Fort Stadacona (Quebec) and is under the")
            println("protection of the French Army.  However, you must")
            println("make a portage and cross the Lachine Rapids.")
            println("Fort 3 is Fort New York and is under Dutch control.")
            println("You must cross through Iroquois land.")
        }
        println("Answer 1, 2, or 3.")
        guard let rawValue = Int(input()), let fort = Fort(rawValue: rawValue) else {
            return getFort()
        }
        
        switch fort {
        case .hochelaga:
            println("You have chosen the easiest route.  However, the fort")
            println("is far from any seaport.  The value")
            println("you receive for your furs will be low and the cost")
            println("of supplies higher than at Forts Stadacona or New York.")
        case .stadacona:
            println("You have chosen a hard route.  It is, in comparison,")
            println("harder than the route to Hochelaga but easier than")
            println("the route to New York.  You will receive an average value")
            println("for your furs and the cost of your supplies will be average.")
        case .newYork:
            println("You have chosen the most difficult route.  At")
            println("Fort New York you will receive the highest value")
            println("for your furs.  The cost of your supplies")
            println("will be lower than at all the other forts.")
        }
        
        //1400-1404
        println("Do you want to trade at another fort?")
        if getResponse() == .yes { return getFort() }
        return fort
    }
    
    //1412-1420
    private func sell(pelts: [Pelt]) -> Int {
        let sortedPelts = pelts.sorted(by: { (PeltKind.sellOrder.firstIndex(of: $0.kind) ?? 0) < (PeltKind.sellOrder.firstIndex(of: $1.kind) ?? 0) })
        for pelt in sortedPelts {
            println("Your \(pelt.kind) sold for $ \(pelt.proceeds.formatted(.basic))")
        }
        return Int(round(sortedPelts.reduce(0.0) { $0 + $1.proceeds }))
    }
}
