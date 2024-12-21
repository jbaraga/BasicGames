//
//  Banner.swift
//  Banner
//
//  Created by Joseph Baraga on 2/14/22.
//

import Foundation

class Banner: GameProtocol {
    
    //Lines 899-940
    private let data: [String: [Int]] = [
        " ": [0,0,0,0,0,0,0],
        "A": [505,37,35,34,35,37,505],
        "G" : [125,131,258,258,290,163,101],
        "E" : [512,274,274,274,274,258,258],
        "T" : [2,2,2,512,2,2,2],
        "W" : [256,257,129,65,129,257,256],
        "L" : [512,257,257,257,257,257,257],
        "S" : [69,139,274,274,274,163,69],
        "O" : [125,131,258,258,258,131,125],
        "N" : [512,7,9,17,33,193,512],
        "F" : [512,18,18,18,18,2,2],
        "K" : [512,17,17,41,69,131,258],
        "B" : [512,274,274,274,274,274,239],
        "D" : [512,258,258,258,258,131,125],
        "H" : [512,17,17,17,17,17,512],
        "M" : [512,7,13,25,13,7,512],
        "?" : [5,3,2,354,18,11,5],
        "U" : [128,129,257,257,257,129,128],
        "R" : [512,18,18,50,82,146,271],
        "P" : [512,18,18,18,18,18,15],
        "Q" : [125,131,258,258,322,131,381],
        "Y" : [8,9,17,481,17,9,8],
        "V" : [64,65,129,257,129,65,64],
        "X" : [388,69,41,17,41,69,388],
        "Z" : [386,322,290,274,266,262,260],
        "I" : [258,258,258,512,258,258,258],
        "C" : [125,131,258,258,258,131,69],
        "J" : [65,129,257,257,257,129,128],
        "1" : [0,0,261,259,512,257,257],
        "2" : [261,387,322,290,274,267,261],
        "*" : [69,41,17,512,17,41,69],
        "3" : [66,130,258,274,266,150,100],
        "4" : [33,49,41,37,35,512,33],
        "5" : [160,274,274,274,274,274,226],
        "6" : [193,289,305,297,293,291,194],
        "7" : [258,130,66,34,18,10,8],
        "8" : [69,171,274,274,274,171,69],
        "9" : [263,138,74,42,26,10,7],
        "=" : [41,41,41,41,41,41,41],
        "!" : [1,1,1,384,1,1,1],
        "0" : [57,69,131,258,131,69,57],
        "." : [1,1,129,449,129,1,1]
        ]
    
    func run() {
        printHeader(title: "Banner")
        println()

        let x = Int(input("Horizontal")) ?? 1
        let y = Int(input("Vertical")) ?? 1
        
        guard x > 0 && y > 0 else {
            println("Invalid dimensions")
            end()
        }
        
        let isCentered = input("Centered").isYes  //G1: 0 = false, 1 = true
        let character = input("Character (type 'ALL' if you want character being printed)").uppercased()  //M$
        let statement = input("Statement").uppercased()  //A$
        let _ = input("Set page")
        println()
        
        consoleIO.startHardcopy()
        //Lines 70-800
        for element in statement {  //T
            let letter = String(element)
            guard let s = data[letter], s.count == 7 else {  //s zero indexed
                println("Unallowed character: " + letter)
                end()
            }
            
            //Line 96
            if letter == " " {
                //Line 812
                println(7*x)
            } else {
                //Line 201
                let outputCharacter = character == "ALL" ? letter : character  //x$
                for var value in s {
                    //Lines 210-280
                    let j: [Bool] = (0...8).reversed().compactMap {
                        guard value > 1 else { return nil }
                        let isPrinted = pow(2,$0) < value
                        if isPrinted { value -= pow(2,$0) }
                        return isPrinted
                    }
    
                    //Lines 445-630
                    for _ in 1...x {
                        if isCentered {
                            print(tab(Int((63 - 4.5 * Double(y)) / Double(outputCharacter.count + 1))))
                        }
                        for b in 0..<j.count {
                            if j[b] {
                                print(String(repeating: outputCharacter, count: y))
                            } else {
                                print(String(repeating: " ", count: outputCharacter.count * y))
                            }
                        }
                        println()  //Line 620
                    }
                }
                                
                //Line 750
                println(2 * x)
            }
        }
        //Line 806
        println(75)
        consoleIO.endHardcopy()
        
        wait(.short)
        let hardcopy = input("Would you like a hardcopy")
        if hardcopy.isYes {
            consoleIO.printHardcopy()
        }
        
        wait(.short)
        let response = input("Hit return to exit", terminator: "")
        if response.isEasterEgg {
            showEasterEgg(.banner)
        }
        end()
    }
    
    func pow(_ base: Int, _ exp: Int) -> Int {
        return Int(Darwin.pow(Double(base) ,Double(exp)))
    }
}
