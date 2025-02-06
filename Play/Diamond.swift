//
//  Diamond.swift
//  Diamond
//
//  Created by Joseph Baraga on 12/23/24.
//

import Foundation


class Diamond: BasicGame {
    func run() {
        printHeader(title: "Diamond")
        play()
    }
    
    private func play() {
        println("For a pretty diamond pattern,")
        let r = Int(input("type in an odd number between 5 and 21"))
        guard let r else { end() }  //Max width of diamond (# of characters)
        
        let characters = getCharacters()  //A$
        println()
        
        let q = Int(60 / Double(r))  //Number of diamonds
        let counts = Array(stride(from: 1, through: r, by: 2)) + Array(stride(from: r - 2, through: 1, by: -2))  //Top half + bottom half character count of each diamond by line

        (1...q).forEach { _ in  //l - vertical
            for n in counts {
                for m in 1...q {  //Index of diamond horizontal
                    print(tab(r * (m - 1) + (r - n) / 2))
                    print((characters + String(repeating: "!", count: n)).prefix(n))
                }
                println()
            }
        }
        
        println()
        unlockEasterEgg(.diamond)
        end()
    }
    
    //Add on for line 6
    private func getCharacters() -> String {
        let characters = input("Enter characters to use for diamond pattern")
        guard characters.count > 0 else { return "CC" }
        return characters
    }
}
