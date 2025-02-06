//
//  Buzzword.swift
//  Buzzword
//
//  Created by Joseph Baraga on 12/20/24.
//

import Foundation


class Buzzword: BasicGame {
    
    private struct PhraseGenerator {
        var group1 = ["ability", "basal", "behavioral", "child-centered", "differentiated", "discovery", "flexible", "heterogeneous", "homogeneous", "manipulative", "modular", "tavistock", "individualized"]
        
        var group2 = ["learning", "evaluative", "objective", "cognitive", "enrichment", "scheduling", "humanistic", "integrated", "non-graded", "training", "vertical age", "motivational", "creative"]
        
        var group3 = ["grouping", "modification", "accountability", "process", "core curriculum", "algorithm", "performance", "reinforcement", "open classroom", "resource", "structure", "facility", "environment"]
        
        func getPhrase() -> String {
            return ([group1.randomElement(), group2.randomElement(), group3.randomElement()].compactMap { $0 }).joined(separator: " ")
        }
    }
    
    func run() {
        printHeader(title: "Buzzword Generator", newlines: 1)
        println("This program prints highly acceptable phrases in")
        println("'educator-speak' that you can work into reports")
        println("and speeches.  Whenever a question mark is printed,")
        println("type a 'y' for another phrase or 'n' to quit.")
        wait(.short)
        println(3)

        play()
    }
    
    private func play() {
        println("Here's the first phrase:")
        
        let phraseGenerator = PhraseGenerator()
        repeat {
            println(phraseGenerator.getPhrase())
            println()
        } while Response(input()).isYes
        
        wait(.short)
        println("Come back when you need help with another report!")
        
        unlockEasterEgg(.buzzword)
        end()
    }
}
