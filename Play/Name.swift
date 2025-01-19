//
//  Name.swift
//  Name
//
//  Created by Joseph Baraga on 12/27/24.
//

import Foundation

class Name: GameProtocol {
    
    private struct Name {
        var first = ""
        var last = ""
        
        var full: String { [first, last].joined(separator: " ").trimmingCharacters(in: .whitespaces) }
        var reversed: String { String(full.reversed()) }  //40-50
        var sorted: String { String((first + last).sorted()) }  //100-140
        
        init(_ string: String) {
            let components = (string.components(separatedBy: .whitespaces.union(CharacterSet(charactersIn: ","))).map { $0.trimmingCharacters(in: .whitespaces) }).filter { !$0.isEmpty }
            first = components.first ?? ""
            last = components.last ?? ""
            if first.isEmpty && last.isEmpty {
                first = "Hondo"
            }
        }
    }
    
    func run() {
        printHeader(title: "Name")
        play()
    }
    
    private func play() {
        println("Hello.")
        println("My name is Creative Computer.")
        let name = Name(input("What's your name (first and last)"))
        println()
        println("Thank you, " + name.reversed + ".")
        println("Oops!  I guess I got it backwards.  A smart")
        println("computer like me shouldn't make a mistake like that!")
        println()
        println("But I just noticed your letters are out of order.")
        println("Let's put them in order like this: " + name.sorted)
        println()
        let response = Response(input("Don't you like that better"))
        println()
        if response.isYes {
            println("I knew you'd agree!!")
        } else {
            println("I'm sorry you didn't like it that way.")
        }
        println()
        println("I really enjoyed meeting you " + name.full + ".")
        println("Have a nice day!")
        
        unlockEasterEgg(.name)
        end()
    }
}
