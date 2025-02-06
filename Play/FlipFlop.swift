//
//  FlipFlop.swift
//  play
//
//  Created by Joseph Baraga on 1/20/25.
//

import Foundation

class FlipFlop: BasicGame {
    
    private enum Element: String, CustomStringConvertible {
        case x = "X"
        case o = "O"
        
        var description: String { rawValue }
    }
    
    private struct Line: CustomStringConvertible {
        private var array: [Element]
        private let q: Double
        
        var description: String { array.map { "\($0)" }.joined(separator: " ")  }
        
        var isFlipped: Bool { return array.filter { $0 == .x }.count == 0 }
        
        init(element: Element, q: Double = 0) {
            array = Array(repeating: element, count: Self.count)
            self.q = q
        }
        
        subscript(_ position: Int) -> Element {
            get { array[position - 1] }
            set { array[position - 1] = newValue }
        }
        
        mutating func reset() {
            array = Array(repeating: .x, count: Self.count)
        }
        
        mutating private func flipElement(at number: Int) -> Element {
            let index = number - 1
            let element = array[index]
            array[index] = element == .x ? .o : .x
            return element
        }
        
        //380-410, 480-500, 590-600
        mutating func flipElement(at number: Int, lastSelection: Int) {
            let element = flipElement(at: number)
            if element == .x || (element == .o && lastSelection == number) {
                flipAdditionalElement(lastNumber: number, lastSelection: lastSelection)
            }
        }
        
        //TODO: Understand the r functions. Simplify algorithm
        //420-500, 530-600
        mutating func flipAdditionalElement(lastNumber: Int, lastSelection: Int) {
            let n = Double(lastNumber)
            let r = lastNumber == lastSelection ?
                tan(q + n / q  - n) - sin(q / n) + 336 * sin(8 * n) :
                0.592 * (1 / tan(q / n + q)) / sin(n * 2 + q) - cos(n)
            let newNumber = Int(10 * (r - floor(r)))
            guard newNumber > 0 else { return }
            let element = flipElement(at: newNumber)
            if element == .o && lastSelection == newNumber {
                flipAdditionalElement(lastNumber: newNumber, lastSelection: lastSelection)
            }
        }
        
        static let count = 10
        static let positions = [Int](1...count)
        static var positionDescriptions: String { Self.positions.map { "\($0)" }.joined(separator: " ") }
    }
    
    func run() {
        printHeader(title: "Flipflop")
        
        //10 REM *** CREATED BY MICHAEL CASS
        println("The object of this puzzle is to change this:")
        println()
        println(Line(element: .x))
        println()
        println("to this:")
        println()
        println(Line(element: .o))
        println()
        println("By typing the number corresponding to the position of the")
        println("letter on some numbers, one position will change, on")
        println("others, two will change.  To reset line to all X's, type 0")
        println("(zero) and to start over in the middle of a game, type")
        println("11 (eleven).")
        
        repeat {
            println()
            play()
        } while Response(input("Do you want to try another puzzle")) != .no
                    
        end()
    }
    
    private func play() {
        //180 REM
        var line = Line(element: .x, q: rnd(1))
        line = Line(element: .x, q: 0.53425894722947161)
        var count = 0
        var lastSelection = 0  //M Tracks users prior choice
        
        println("Here is the starting line of X's.")
        println()
        println(Line.positionDescriptions)
        println(line)
        println()
        
        repeat {
            let number = getNumber()
            if number == 11 {
                play()
                return
            } else if number == 0 {
                line.reset()
            } else {
                line.flipElement(at: number, lastSelection: lastSelection)
                lastSelection = number
                count += 1
            }
            
            println(Line.positionDescriptions)
            println(line)
            if number == 0 { println() }
        } while !line.isFlipped
                    
        if count > 12 {
            println("Try harder next time.  It took you \(count) guesses.")
        } else {
            println("Very good.  You guessed it in only \(count) guesses.")
            unlockEasterEgg(.flipFlop)
        }
    }
        
    private func getNumber() -> Int {
        guard let number = Int(input("Input the number")), number >= 0, number <= 11 else {
            println("Illegal entry--try again")
            return getNumber()
        }
        return number
    }
}
