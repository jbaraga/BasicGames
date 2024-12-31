//
//  Change.swift
//  Change
//
//  Created by Joseph Baraga on 12/20/24.
//

import Foundation


class Change: GameProtocol {
    
    func run() {
        printHeader(title: "Change")
        println(3)
        println("I, your friendly microcomputer, will determine")
        println("the correct change for items costing up to $100.")
        println(2)
        
        play()
    }
    
    private enum Currency: Double, CaseIterable, CustomStringConvertible {
        case ten = 10
        case five = 5
        case one = 1
        case halfDollar = 0.5
        case quarter = 0.25
        case dime = 0.1
        case nickel = 0.05
        case penny = 0.01
        
        var description: String {
            switch self {
            case .ten: return "Ten dollar bill(s)"
            case .five: return "Five dollar bill(s)"
            case .one: return "One dollar bill(s)"
            case .halfDollar: return "One half dollar(s)"
            case .quarter: return "Quarter(s)"
            case .dime: return "Dime(s)"
            case .nickel: return "Nickel(s)"
            case .penny: return "Penny(s)"
            }
        }
    }
    
    private func play() {
        while true {
            let cost = getCost()
            let payment = getPayment()
            switch payment {
            case _ where payment == cost:
                println("Correct amount, thank you.")
            case _ where payment < cost:
                println("You have short changed me $ " + (cost - payment).formatted(.currency(code: "USD")))
            case _ where payment > cost:
                var change = payment - cost
                println("Your change, $ " + change.formatted(.currency(code: "USD")))
                Currency.allCases.forEach {
                    let number = Int(change / $0.rawValue)
                    if number > 0 {
                        println(" \(number) " + $0.description)
                        change -= Double(number) * $0.rawValue
                    }
                }
                println("Thank you, come again.")
                println(2)
                unlockEasterEgg(.change)
            default:
                fatalError("Missing case payment - cost: \(payment - cost)")
            }
        }
    }
                
    private func getCost() -> Double {
        guard let cost = Double(input("Cost of item")), cost >= 0, cost <= 100 else {
            return getCost()
        }
        return cost
    }
    
    private func getPayment() -> Double {
        guard let payment = Double(input("Amount of payment")), payment >= 0 else {
            return getPayment()
        }
        return payment
    }
}
