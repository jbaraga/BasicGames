//
//  Synonym.swift
//  Synonym
//
//  Created by Joseph Baraga on 12/30/24.
//

import Foundation

class Synonym: GameProtocol {
    
    private let n = 10  //Number of rounds
    
    //500-605
    private let synonymGroups = [
        ["First", "Start", "Beginning", "Onset", "Initial"],
        ["Similar", "Alike", "Same", "Like", "Resembling"],
        ["Model", "Pattern", "Prototype", "Standard", "Criterion"],
        ["Small", "Insignificant", "Little", "Tiny", "Minute"],
        ["Stop", "Halt", "Stay", "Arrest", "Check", "Standstill"],
        ["House", "Dwelling", "Residence", "Domicile", "Lodging", "Habitation"],
        ["Pit", "Hole", "Hollow", "Well", "Gulf", "Chasm", "Abyss"],
        ["Push", "Shove", "Thrust", "Prod", "Poke", "Butt", "Press"],
        ["Red", "Rouge", "Scarlet", "Crimson", "Flame", "Ruby"],
        ["Pain", "Suffering", "Hurt", "Misery", "Distress", "Ache", "Discomfort"]
    ]
    
    private let responses = ["Right", "Correct", "Fine", "Good!", "Check"]
    
    func run() {
        printHeader(title: "Synonym")
        println("A synonym of a word means another word in the English")
        println("language which has the same or very nearly the same meaning.")
        println("I choose a word -- you type a synonym.")
        println("If you can't think of a synonym, type the word 'help'")
        println("and I will tell you a synonym.")
        println()
        wait(.short)
        play()
    }
    
    private func play() {
        var groups = synonymGroups
        while let index = groups.indices.randomElement() {
            // 170-230 get random group, not repeating any group
            var words = groups.remove(at: index)  //W$
            words = words.map { $0.uppercased() }
            let word = words.removeFirst()
            println(2)
            
            //232-237 setup for help, random suggestion from group without repeating
            var helpList = words
            
            //240-300, 340-370
            var isSynonym = false
            repeat {
                let a$ = input("     What is a synonym of " + word).uppercased()
                isSynonym = words.contains(a$)
                if a$ == "HELP" {
                    //340-370 will crash if helpList exhausted (L[0] negative)
                    guard let index = helpList.indices.randomElement() else { fatalError("Help exceeded")}
                    let synonym = helpList.remove(at: index)
                    println("**** A synonym of \(word) is \(synonym).")
                    println()
                } else if !isSynonym {
                    println("     Try again.")
                }
            } while !isSynonym
           
            //320 - success
            println(responses.randomElement()!)
        }
        
        unlockEasterEgg(.synonym)
        end("Synonym drill completed.")
    }
}
