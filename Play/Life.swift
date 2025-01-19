//
//  Life.swift
//  play
//
//  Created by Joseph Baraga on 1/12/25.
//

import Foundation

class Life: GameProtocol {
    
    private let testPattern = [
        "   ***",
        "  *  *",
        " *   *"
    ]
    
    private var isCRT = false
    
    func run() {
        printHeader(title: "Life")
        
        if Response(input("Would you like instructions")) == .yes {
            printInstructions()
            println()
            wait(.short)
        }
        
        isCRT = Response(input("Are you running on a CRT")) == .yes  //Add on
        println()
        
        play()
    }
    
    private func play() {
        var a = dim(24, 70, value: 0)  //A, but zero-indexed
        println("Enter your pattern:")
        let pattern = getPattern()
        
        //Lines 80-180 - convert pattern to 0/1 and center in array a
        let rowOffset = 11 - pattern.count / 2  //X1
        let columnOffset = 33 - ((pattern.map { $0.count }).max() ?? 24) / 2
        for (row, line) in pattern.enumerated() {
            for (column, character) in line.enumerated() {
                if character != " " { a[row + rowOffset, column + columnOffset] = 1 }
            }
        }
        
        var isValid = true
        var generation = 0
        while true {
            if isCRT {
                enterCRTmode()
            } else {
                println(3)
            }
            
            let population = a.reduce(0) { $0 + $1.reduce(0, +) }
            print("Generation: \(generation)", tab(29), "Population: \(population)" + (isValid ? "" : " invalid"))
            for row in a {
                let string = row.reduce("") { $0 + ($1 == 0 ? " " : "*") }
                println(string)
            }
            
            //Next generation
            generation += 1
            let b = a  //Copy which is not mutated, for simultaneous births/deaths based on current state
            for rowIndex in b.indices {
                if rowIndex > b.startIndex && rowIndex < b.endIndex - 1 {
                    let row = b[rowIndex]
                    for columnIndex in row.indices {
                        if columnIndex > row.startIndex && columnIndex < row.endIndex - 1 {
                            let neighbors = b[rowIndex - 1][(columnIndex-1)...(columnIndex+1)] + [row[columnIndex-1], row[columnIndex+1]] + b[rowIndex + 1][(columnIndex-1)...(columnIndex+1)]
                            let count = (neighbors.filter { $0 > 0 }).count
                            if b[rowIndex, columnIndex] == 0 {
                                if count == 3 {
                                    a[rowIndex, columnIndex] = 1
                                    if rowIndex < 2 || rowIndex > 21 || columnIndex < 2 || columnIndex > 67 { isValid = false }
                                }
                            } else {
                                if count < 2 || count > 3 {
                                    a[rowIndex, columnIndex] = 0
                                }
                            }
                        }
                    }
                }
            }
            
            if generation > 16 { unlockEasterEgg(.life) }
            
            if isCRT { moveCursorToHome() }
        }
    }
    
    private func getPattern(_ pattern: [String] = []) -> [String] {
        var entry = input().lowercased()
        if entry == "done" { return pattern }
        if entry.hasPrefix(".") {
            entry.removeFirst()
            entry = " " + entry
        }
        return getPattern(pattern + [entry])
    }
    
    //Add on from original, to make playable for new user
    private func printInstructions() {
        println("When prompted to enter your pattern, for each line")
        println("of the pattern enter a space for an empty cell")
        println("and an asterisk (*) for a counter.")
        println("Enter 'done' to complete pattern entry.")
        println("To stop the simulation type control-c.")
    }
}
