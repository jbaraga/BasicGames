//
//  Poetry.swift
//  Poetry
//
//  Created by Joseph Baraga on 1/10/24.
//

import Foundation

class Poetry: GameProtocol {
    
    private var phraseGroups: [[String]] = [
        ["midnight dreary", "fiery eyes", "bird or fiend", "thing of evil", "prophet"],
        ["beguiling me", "thrilled me", "still sitting....", "never flitting", "burned"],
        ["and my soul", "darkness there", "shall be lifted", "quoth the raven", "sign of parting"],
        ["nothing more", "yet again", "slowly creeping", "...evermore", "nevermore"],
    ]
    
    private var u = 0
    private var i = 0
    private var j = -1 //J group index - initialized at -1 as first access increments, and group index is zero indexed
    private var k = 0  //K line counter
    
    func run() {
        printHeader(title: "Poetry")
        println()
        
        printPhrase(groupIndex: 0, phraseIndex: 0)
        printNextPhrase()
    }
    
    private func printNextPhrase() {
        while k <= 20 {
            //Lines 215-220
            i = Int(10 * rnd(1) / 2)  //Zero indexed
            j += 1
            k += 1
            
            //Lines 230-
            if u == 0 && j % 2 == 0 { print("     ") }
            if j < 4 {
                printPhrase(groupIndex: j, phraseIndex: i)
                printNextPhrase()
            }
            
            j = 0
            println()
        }
        
        println()
        u = 0
        k = 0
        
        let response = Response(pauseForEnter())
        if response == .easterEgg {
            showEasterEgg(.poetry)
            end()
        } else {
            printPhrase(groupIndex: 1, phraseIndex: i)
            printNextPhrase()
        }
    }
    
    private func printPhrase(groupIndex: Int, phraseIndex: Int) {
        let phrase = phraseGroups[groupIndex][phraseIndex]
        print(phraseGroups[groupIndex][phraseIndex])
        
        switch (groupIndex, phraseIndex) {
        case (1,0), (1,4): u = 2  //For line 111 and 114 exceptions
        default:
            break
        }
        
        //Lines 210-211
        if !phrase.hasSuffix(".") {  //For line 113 exception - GOTO 212 - inhibits comma after period
            if u > 0 || rnd(1) < 0.19 {
                print(",")
                u = 2
            }
        }
        
        //Lines 212-214
        if rnd(1) > 0.65 {
            println()
            u = 0
        } else {
            print(" ")
            u += 1
        }
    }
}
