//
//  Cube.swift
//  play
//
//  Created by Joseph Baraga on 1/4/25.
//

import Foundation

class Cube: BasicGame {
    
   private var account = 500  //A1
    
    func run() {
        printHeader(title: "Cube")
        if (Int(input("Do you want to see the instructions? (yes--1,no--0)?\n")) ?? 0) != 0 {
            println("This is a game in which you will be playing against the")
            println("random decision of the computer. The field of play is a")
            println("cube of side 3. Any of the 27 locations can be designated")
            println("by inputing three numbers such as 2,3,1.  At the start,")
            println("you are automatically at location 1,1,1.  The object of")
            println("the game is to get to location 3,3,3.  One minor detail,")
            println("the computer will pick, at random, 5 locations at which")
            println("it will plant land mines.  If you hit one of these locations")
            println("you lose.  One other detail, yo may move only one space")
            println("in one direction each move.  For example: from 1,1,2 you")
            println("may move to 2,1,2 or 1,1,3.  You may not change")
            println("two of the numbers on the same move.  If you make an illegal")
            println("move, you lose and the computer takes the money you may")
            println("have bet on that round.")
            println(2)
            println("All yes or no questions will be answered by a 1 for yes")
            println("or a 0 (zero) for no.")
            println()
            println("When stating the amount of a wager, print only the number")
            println("of dollars (example: 250)  You are automatically started with")
            println("500 dollar account.")
            println()
            println("Good Luck")
            wait(.short)
        }
        
        repeat {
            play()
        } while account > 0 && Int(input("Do you want to try again?\n")) == 1
        
        println("Tough luck")
        println()
        println(" Goodbye")
        if account > 500 {
            unlockEasterEgg(.cube)
        }
        end()
    }
    
    private func play() {
        //380-820
        let mineLocations = [Coordinate(yMin: 2), Coordinate(xMin: 1), Coordinate(zMin: 2), Coordinate(yMin: 2), Coordinate(yMin: 1)]
        var userLocation = Coordinate(x: 1, y: 1, z: 1)
        
        var wager = 0
        if Int(input("Want to make a wager?\n")) ?? 1 != 0 {
            println("How much?")
            repeat {
                wager = Int(input()) ?? 0
                if wager > account || wager < 0 { print("Tried to fool me; bet again") }
            } while wager > account || wager < 0
        }
        
        println("Its your move")
        while userLocation != .goal {
            let newLocation = Coordinate(input()) ?? userLocation
            do {
                try userLocation.move(to: newLocation)
                if userLocation == .goal {
                    println("Congratulations")
                    account += wager
                } else if mineLocations.contains(userLocation) {
                    throw MoveError.mine
                } else {
                    println("Next move")
                }
            } catch {
                switch error as! MoveError {
                case .illegal:
                    println("Illegal move", "You lose")
                case .mine:
                    println("******Bang******")
                    println("You lose")
                    println(2)
                }
                //1440
                if wager > 0 {
                    println()
                    account -= wager
                }
                break
            }
        }
        
        guard account > 0 else {
            println("You bust")
            return
        }
        
        if wager > 0 {
            println(" You now have \(account) dollars")
        }
    }
}


private struct Coordinate: Equatable {
    var x: Int
    var y: Int
    var z: Int
    
    mutating func move(to location: Coordinate) throws {
        let delta = location.x - x + location.y - y + location.z - z
        if delta > 1 { throw MoveError.illegal }
        if x < 1 || x > 3 || y < 1 || y > 3 || z < 1 || z > 3 { throw MoveError.illegal }
        x = location.x
        y = location.y
        z = location.z
    }
    
    static let goal = Coordinate(x: 3, y: 3, z: 3)
}

extension Coordinate {
    /// Initializer for random mine location
    /// - Parameters:
    ///   - xMin: x value if initially randomized to 0
    ///   - yMin: y value if initially randomized to 0
    ///   - zMin: z value if initially randomized to 0
    init(xMin: Int = 3, yMin: Int = 3, zMin: Int = 3) {
        x = Int.random(in: 0...2)
        if x == 0 { x = xMin }
        y = Int.random(in: 0...2)
        if y == 0 { y = yMin }
        z = Int.random(in: 0...2)
        if z == 0 { z = zMin }
    }
    
    init?(_ string: String) {
        let stringValues = (string.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }).filter { !$0.isEmpty }
        guard stringValues.count == 3, let x = Int(stringValues[0]), let y = Int(stringValues[1]), let z = Int(stringValues[2]) else { return nil }
        self.x = x
        self.y = y
        self.z = z
    }
}

private enum MoveError: Error {
    case illegal
    case mine
}
