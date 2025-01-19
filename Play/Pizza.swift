//
//  Pizza.swift
//  Pizza
//
//  Created by Joseph Baraga on 1/10/24.
//

import Foundation

class Pizza: GameProtocol {
    
    private var name = ""
    private let customers = Array("ABCDEFGHIJKLMNOP")  //S$, zero indexed
    
    func run() {
        printHeader(title: "Pizza")
        println("Pizza Delivery Game")
        println()
        name = input("What is your first name")
        println()
        println("Hi, \(name).  In this game you are to take orders")
        println("for pizzas.  Then you are to tell a delivery boy")
        println("where to deliver the ordered pizzas.")
        println(2)
        
        println("Map of the city of Hyattsville")
        println()
        printMap()
        println()
        println("The above is a map of the homes where")
        println("you are to send pizzas.")
        println()
        println("Your job is to give a truck driver")
        println("the location or coordinates of the")
        println("home ordering the pizza.")
        println()
        
        var response = Response(input("Do you need more directions"))
        while !response.isYesOrNo {
            println("'Yes' or 'no' please, now then,")
            response = Response(input("Do you need more directions"))
        }
        
        if response.isYes {
            println()
            println("Somebody will ask for a pizza to be")
            println("delivered.  Then a delivery boy will")
            println("ask you for the location.")
            println("     Example:")
            println("This is J.  please send a pizza.")
            println("Driver to \(name).  Where does J live?")
            println("Your answer would be 2,3")
            println()
            
            if !Response(input("Understand")).isYes {
                println("This job is definitely too difficult for you.  Thanks anyway")
                end()
            }
            
            println("Good.  You are now ready to start taking orders.")
            println()
            println("Good luck!!")
            println()
        }
        
        wait(.short)
        
        repeat {
            deliverPizzas()
            wait(.short)
        } while Response(input("Do you want to deliver more pizzas")).isYes
        
        println()
        println("O.K. \(name), see you later!")
        println()
        unlockEasterEgg(.pizza)
        end()
    }
    
    //Lines 250-440
    private func printMap() {
        let xAxis = " -----1-----2-----3-----4-----"
        println(xAxis)
        (1...4).reversed().forEach { k in
            (1...4).forEach { _ in println("-") }
            let s1 = (k - 1) * 4
            println("\(k)", customers[s1], customers[s1+1], customers[s1+2], customers[s1+3], "\(k)", tabInterval: 6)
        }
        (1...4).forEach { _ in println("-") }
        println(xAxis)
    }
    
    //Line 750-970
    private func deliverPizzas() {
        for _ in 1...5 {
            let s = customers.indices.randomElement() ?? 0
            let customer = customers[s]
            println()
            println("Hello \(name)'s Pizza.  This is \(customer).")
            println("  Please send a pizza.")
            
            var isDelivered = false
            while !isDelivered {
                if let point: Point = input("  Driver to \(name).  Where does \(customer) live"), point.x > 0, point.x < 5, point.y > 0, point.y < 5 {
                    let t = point.x - 1 + (point.y - 1) * 4
                    if t == s {
                        println("Hello \(name).  This is \(customer), thanks for the pizza.")
                        isDelivered = true
                    } else {
                        println("This is \(customers[t]).  I did not order a pizza.")
                        println("I live at \(point.x), \(point.y)")
                    }
                } else {
                    println("  Driver to \(name).  No one at that address.")  //Added to handle invalid address entry
                }
            }
        }
        
        println()
    }
}
