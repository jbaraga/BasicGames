//
//  MasterMind.swift
//  play
//
//  Created by Joseph Baraga on 2/12/25.
//

import Foundation

class MasterMind: BasicGame {
    
    //8000 REM     PROGRAM DATA FOR COLOR NAMES
    private enum Color: String, CaseIterable, CustomStringConvertible {
        case black, white, red, green, orange, yellow, purple, tan
        
        var description: String { rawValue.capitalized }
        var letter: String { String(rawValue.prefix(1)).uppercased() }
        
        init(index: Int){
            guard Self.allCases.indices.contains(index) else { fatalError("Color index out of range \(index)") }
            self = Self.allCases[index]
        }
        
        init(character: String.Element) {
            guard let color = Self.allCases.first(where: { $0.letter == String(character) }) else { fatalError("Invalid letter \(character)") }
            self = color
        }
    }
    
    private struct Guess {
        let value: String  //S$
        let blacks: Int //B
        let whites: Int //W
    }
    
    private struct Score {
        var computer = 0
        var human = 0
    }
    
    private var score = Score()
    private let maxGuesses = 10
    
    func run() {
        printHeader(title: "Master Mind")
        
        //10 REM
        //20 REM     MASTERMIND II
        //30 REM     STEVE NORTH
        //40 REM     CREATIVE COMPUTING
        //50 REM     PO BOX 789-M MORRISTOWN NEW JERSEY 07960
        //60 REM
        //70 REM
        
        play()
    }
    
    private func play() {
        let numberOfColors = getColors()  //C9
        let numberOfPositions = Int(input("Number of positions")) ?? 0  //P9
        let rounds = Int(input("Number of rounds")) ?? 0  //R9
        guard numberOfPositions > 0, rounds > 0 else { end() }
        let possibilities = Int(pow(Double(numberOfColors), Double(numberOfPositions)))
        println("Total possibilities = \(possibilities)")
        
        let colors = Array(Color.allCases[0..<numberOfColors])  //X$
        println(2)
        println("Color     Letter")
        println("=====     ======")
        colors.forEach { println($0.description, tab(13), $0.letter) }
        println()
        
        for round in 1...rounds {
            println()
            println("Round number  \(round) ----")
            println()
            guessComputerCode(colors: colors, numberOfPositions: numberOfPositions)
            guessHumanCode(colors: colors, numberOfPositions: numberOfPositions)
        }
        
        //1160
        println("Game over")
        print("Final ")
        print(score: score)
        
        if rounds > 1, score.human < score.computer {
            unlockEasterEgg(.masterMind)
        }
        
        //9998 REM   ...WE'RE SORRY BUT IT'S TIME TO GO...
        end()
    }
    
    private func getColors() -> Int {
        let max = Color.allCases.count
        guard let colors = Int(input("Number of colors")), colors > 0 else {
            end()
        }
        
        guard colors <= max else {
            println("No more than \(max), please.")
            return getColors()
        }
        
        return colors
    }
    
    //300-650
    private func guessComputerCode(colors: [Color], numberOfPositions: Int) {
        println("Guess my combination.")
        //310 REM     GET A COMBINATION
        let possibilities = Int(pow(Double(colors.count), Double(numberOfPositions)))
        let a = Int.random(in: 0..<possibilities)  //A, shifted from one to zero indexing
        let positions = combination(from: a, colors: colors, numberOfPositions: numberOfPositions)  //350 GOSUB 3500
        
        var guesses = [Guess]()
        while guesses.count < maxGuesses {
            let guessString = getGuess(guesses: guesses, colors: colors, numberOfPositions: numberOfPositions)
            if guessString == "QUIT" {
                //2500 REM
                //2510 REM     QUIT ROUTINE
                //2520 REM
                println("Quitter!  My combination was: " + (positions.map { $0.letter }).joined())  //4000-4060
                println()
                println("Good bye")
                end()
            }
            
            let guessColors = guessString.map { Color(character: $0)}
            let (blacks, whites) = matchCount(array1: positions, array2: guessColors)
            let guess = Guess(value: guessString, blacks: blacks, whites: whites)
            
            //570 REM     SAVE ALL THIS STUFF FOR BOARD PRINTOUT LATER
            guesses.append(guess)
            if guessColors == positions {
                println("You guessed it in  \(guesses.count) moves!")
                score.human += guesses.count
                print(score: score)
                return
            }
            
            //550 REM     TELL HUMAN RESULTS
            println("You have  \(guess.blacks)  blacks and  \(guess.whites)  whites.")
        }
        
        println("You ran out of moves!  That's all you get!")
        score.human += guesses.count
        print(score: score)
        //Bug in original code, does not execute line 622-626 after out of moves, and would and fallthrough to 630 if it did
        println("The actual combination was: " + (positions.map { $0.letter }).joined() )
        println()
    }
    
    //380-490
    private func getGuess(guesses: [Guess], colors: [Color], numberOfPositions: Int) -> String {
        let string = input("Move #  \(guesses.count + 1)  guess").uppercased()
        if string == "QUIT" { return string }
        if string == "BOARD" {
            //2000 REM
            //2010 REM     BOARD PRINTOUT ROUTINE
            //2020
            println("MOVE     GUESS          BLACK     WHITE")
            for (index, guess) in guesses.enumerated() {
                println("\(index + 1)", tab(9), guess.value, tab(25), " \(guess.blacks)", tab(35), "\(guess.whites)")
            }
            return getGuess(guesses: guesses, colors: colors, numberOfPositions: numberOfPositions)
        }
        
        guard string.count == numberOfPositions else {
            println("Bad number of positions.")
            return getGuess(guesses: guesses, colors: colors, numberOfPositions: numberOfPositions)
        }
        
        let allowedLetters = colors.map { $0.letter }
        for character in string {
            guard allowedLetters.contains(String(character)) else {
                println("'\(character)' is unrecognized.")
                return getGuess(guesses: guesses, colors: colors, numberOfPositions: numberOfPositions)
            }
        }
        
        return string
    }
    
    //660-1140
    private func guessHumanCode(colors: [Color], numberOfPositions: Int) {
        //660 REM
        //670 REM     NOW COMPUTER GUESSES
        //680 REM
        println("Now I guess.  Think of a combination.")
        let _ = input("Hit return when ready ")
        
        let possibilities = Int(pow(Double(colors.count), Double(numberOfPositions)))
        var guessIndexes = [Int](0..<possibilities)
        for m in 1...maxGuesses {
            //760 REM     FIND A GUESS
            var index = Int.random(in: 0..<possibilities)
            if !guessIndexes.contains(index) {
                if let newIndex = (guessIndexes.filter { $0 > index }).first {
                    index = newIndex
                } else if let newIndex = (guessIndexes.filter { $0 < index }).first {
                    index = newIndex
                } else {
                    println("You dummy, you have given me inconsistent information.")  //850
                    println("Let's try again, and this time, be more careful.")
                    guessHumanCode(colors: colors, numberOfPositions: numberOfPositions)
                    return
                }
            }
                    
            //890 REM     NOW WE CONVERT GUESS #G INTO G$
            let positions = combination(from: index, colors: colors, numberOfPositions: numberOfPositions)  //910 GOSUB 3500
            print("My guess is: \(positions.map { $0.letter }.joined())")
            let (b1, w1) = getMatchNumbers()
            if b1 == numberOfPositions {
                println("I got it in  \(m)  moves!")
                score.computer += m
                print(score: score)
                return
            }
            
            //Target index will be in remaining indexes which have same number of exact and inexact matches, starting from all possible indexes
            guessIndexes = guessIndexes.filter {
                let otherPositions = combination(from: $0, colors: colors, numberOfPositions: numberOfPositions)
                let (b, w) = matchCount(array1: positions, array2: otherPositions)
                return b1 == b && w1 == w
            }
        }
        
        println("I used up all my moves!")  //1090
        println("I guess my CPU is just having an off day")
        score.computer += maxGuesses
        print(score: score)
    }
    
    private func getMatchNumbers() -> (blacks: Int, whites: Int) {
        guard let numbers: Point = input("  Blacks, whites ") else {
            return getMatchNumbers()
        }
        return (numbers.x, numbers.y)
    }
    

    private func combination(from index: Int, colors: [Color], numberOfPositions: Int) -> [Color] {
        //Lines 330-360, 3000-4060
        //Each possibility is encoded as conversion of possibility number (A) to array Q() of length P9 of the digits of A converted to base C9, least significant digit first; elements of Q are indexes of color in colors for position. Here directly returned as array of Color
        //3000 REM
        //3010 REM     INITIALIZE Q(1-P9) TO ZEROS
        //3020 REM
        
        //3500 REM
        //3510 REM     INCREMENT Q(1-P9)
        //3520 REM
        //3524 REM  IF ZERO, THIS IS OUR FIRST INCREMENT: MAKE ALL ONES
        
        //4000 REM
        //4010 REM     CONVERT Q(1-P9) TO A$(1-P9)
        //4020

        return (index.converted(toBase: colors.count, length: numberOfPositions)).map { Color(index: $0) }
    }
    
    private func matchCount(array1: [Color], array2: [Color]) -> (exact: Int, inexact: Int) {
        //4500 REM
        //4510 REM     GET NUMBER OF BLACKS (B) AND WHITES (W)
        //4520 REM     MASHES G% AND A$ IN THE PROCESS
        //4530 REM
        //Here, exact == B, inexact == W
        let unmatchedSequence = zip(array1, array2).filter { $0.0 != $0.1 }
        var unmatchedArray1 = unmatchedSequence.map { $0.0 }
        let unmatchedArray2 = unmatchedSequence.map { $0.1 }
        let inexactMatches = unmatchedArray2.filter {
            if let index = unmatchedArray1.firstIndex(of: $0) {
                unmatchedArray1.remove(at: index)
                return true
            } else {
                return false
            }
        }
        
        return (array1.count - unmatchedSequence.count, inexactMatches.count)
    }
    
    private func print(score: Score) {
        //5000 REM
        //5010 REM     PRINT SCORE
        //5020 REM
        println("Score:")
        println("     Computer  \(score.computer)")
        println("     Human     \(score.human)")
        println()
    }
}


private extension Int {
    func converted(toBase base: Int, length: Int = 0) -> [Int] {
        var number = self
        var array = [Int]()
        while number > 0 {
            array.append(number % base)
            number /= base
        }
        if array.count < length {
            array += Array(repeating: 0, count: length - array.count)
        }
        return array
    }
}
