//
//  Love.swift
//  Love
//
//  Created by Joseph Baraga on 12/28/24.
//

import Foundation

class Love: GameProtocol {
    
    private let maskByRow: [Int: [IndexSet]] = [
        0: [],
        
    ]
    
    //600-710 - successive numbers alternate between # characters to print and # of spaces to print
    private let data = [
        60,1,12,26,9,12,3,8,24,17,8,4,6,23,21,6,4,6,22,12,5,6,5,
        4,6,21,11,8,6,4,4,6,21,10,10,5,4,4,6,21,9,11,5,4,
        4,6,21,8,11,6,4,4,6,21,7,11,7,4,4,6,21,6,11,8,4,
        4,6,19,1,1,5,11,9,4,4,6,19,1,1,5,10,10,4,4,6,18,2,1,6,8,11,4,
        4,6,17,3,1,7,5,13,4,4,6,15,5,2,23,5,1,29,5,17,8,
        1,29,9,9,12,1,13,5,40,1,1,13,5,40,1,4,6,13,3,10,6,12,5,1,
        5,6,11,3,11,6,14,3,1,5,6,11,3,11,6,15,2,1,
        6,6,9,3,12,6,16,1,1,6,6,9,3,12,6,7,1,10,
        7,6,7,3,13,6,6,2,10,7,6,7,3,13,14,10,8,6,5,3,14,6,6,2,10,
        8,6,5,3,14,6,7,1,10,9,6,3,3,15,6,16,1,1,
        9,6,3,3,15,6,15,2,1,10,6,1,3,16,6,14,3,1,10,10,16,6,12,5,1,
        11,8,13,27,1,11,8,13,27,1,60
    ]
    
    func run() {
        printHeader(title: "Love")
        println(3)
        println("A tribute to the great American artist, Robert Indiana.")
        println("His great work will be reproduced with a message of")
        println("your choice up to 60 characters.  If you can't think of")
        println("a message, simply type the word 'LOVE'")
        println()
        wait(.short)
        play()
        
    }
    
    private func play() {
        var a$ = input("Your message, please")
        if a$.isEmpty { a$ = "LOVE" }
        let fullLine = String(repeating: a$, count: (60 / a$.count) + 1).prefix(60)
        
        println(10)
        var index = 0
        var line = fullLine
        var stringIndex = 0
        while index < data.count {
            stringIndex += data[index]
            index += 1
            if stringIndex < line.count {
                let startIndex = line.index(line.startIndex, offsetBy: stringIndex)
                let endIndex = line.index(startIndex, offsetBy: data[index])
                line.replaceSubrange(startIndex..<endIndex, with: String(repeating: " ", count: data[index]))
                stringIndex += data[index]
                index += 1
            } else {
                //Start new line
                println(line)
                line = fullLine
                stringIndex = 0
            }
        }
        wait(.short)
        println(10)
         
        unlockEasterEgg(.love)
        end()
    }
}

