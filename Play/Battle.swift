//
//  Battle.swift
//  play
//
//  Created by Joseph Baraga on 1/26/25.
//

import Foundation

class Battle: BasicGame {
    
    typealias Coordinate = Point
    
    private enum ShipType {
        case destroyer
        case cruiser
        case carrier
        
        var length: Int {
            switch self {
            case .destroyer: return 2
            case .cruiser: return 3
            case .carrier: return 4
            }
        }
    }
    
    private struct Ship {
        let number: Int
        let type: ShipType
        var hits: Int = 0
        
        var isSunk: Bool { hits >= type.length }
    }
    
    private enum Square: Equatable, CustomStringConvertible {
        case water
        case ship(Int)
        case hit(Int)
        
        var description: String {
            switch self {
            case .water: return "0"
            case .ship(let number): return "\(number)"
            case .hit(let number): return "\(number)"
            }
        }
    }
    
    private enum ShotResult {
        case splash
        case hit(Ship)
        case reHit(Ship)
        case hitSunkShip(Ship)
    }
    
    private struct Board {
        private var grid: Matrix<Square>
        
        var ships = [
            Ship(number: 1, type: .destroyer),
            Ship(number: 2, type: .destroyer),
            Ship(number: 3, type: .cruiser),
            Ship(number: 4, type: .cruiser),
            Ship(number: 5, type: .carrier),
            Ship(number: 6, type: .carrier)
        ]

        //The visualized grid has rows and columns swapped
        var rowStrings: [String] {
            return (grid.columns.reduce(into: [String]()) { $0.append($1.map { element in element.description  }.joined(separator:  " ")) }).reversed()
        }
        
        //The coded grid has row and column indices swapped
        var codedRowStrings: [String] {
            return grid.rows.reduce(into: [String]()) { $0.append($1.reversed().map { element in element.description  }.joined(separator:  " ")) }
        }
        
        var isGameOver: Bool {
            return (ships.filter { $0.isSunk }).count == ships.count
        }
        
        init() {
            grid = .init(rows: 6, columns: 6, value: .water)
            for ship in ships.reversed() {
                add(ship: ship)
            }
        }
        
        //In game row and column 1 indexed
        subscript(_ x: Int, _ y: Int) -> Square {
            get { grid[x - 1, y - 1] }
            set { grid[x - 1, y - 1] = newValue }
        }
        
        subscript(_ coordinate: Coordinate) -> Square {
            get { self[coordinate.x, coordinate.y] }
            set { self[coordinate.x, coordinate.y] = newValue }
        }
        
        //50-1000 Complex logic to place ships on board (F) - not duplicated here
        mutating func add(ship: Ship) {
            let mask = Array(repeating: Square.water, count: ship.type.length)
            let offsets = 0..<mask.count

            //Find all available contiguous matrix indices containing .water for ship of ship.type.length, horizontal, vertical, and both diagonals
            var availableIndexSets = [[(Int, Int)]]()
            for (rowIndex, row) in grid.rows.enumerated() {
                for columnIndex in row.indices {
                    //Horizontal
                    if columnIndex + offsets.upperBound <= row.count {
                        let row = offsets.map { grid[rowIndex, columnIndex + $0] }
                        if row == mask {
                            availableIndexSets.append(offsets.map { (rowIndex, columnIndex + $0) })
                        }
                    }
                    
                    //Vertical
                    if rowIndex + offsets.upperBound <= row.count {
                        let column = offsets.map { grid[rowIndex + $0, columnIndex] }
                        if column == mask {
                            availableIndexSets.append(offsets.map { (rowIndex + $0, columnIndex) })
                        }
                    }
                    
                    //Diagonals
                    if rowIndex + offsets.upperBound <= row.count && columnIndex + offsets.upperBound <= row.count {
                        let diagonal = offsets.map { grid[rowIndex + $0, columnIndex + $0] }
                        if diagonal == mask {
                            let indexSet = offsets.map {(rowIndex + $0, columnIndex + $0) }
                            
                            //Exclude if it crosses opposite diagonal ship
                            let isCrossed = (indexSet[..<(indexSet.count - 1)].map { (rIndex, cIndex) in
                                if rIndex + 1 < row.count, cIndex + 1 < row.count {
                                    return grid[rIndex + 1, cIndex] == grid[rIndex, cIndex + 1] && grid[rIndex + 1, cIndex] != .water
                                }
                                return false
                            }).reduce(false) { $0 || $1 }
                            
                            if !isCrossed { availableIndexSets.append(indexSet) }
                        }
                    }
                    
                    if rowIndex - offsets.upperBound + 1 >= 0 && columnIndex + offsets.upperBound <= row.count {
                        let diagonal = offsets.map { grid[rowIndex - $0, columnIndex + $0] }
                        if diagonal == mask {
                            let indexSet = offsets.map { (rowIndex - $0, columnIndex + $0) }
                            
                            //Exclude if it crosses opposite diagonal ship
                            let isCrossed = (indexSet[..<(indexSet.count - 1)].map { (rIndex, cIndex) in
                                if rIndex - 1 >= 0, cIndex + 1 < row.count {
                                    return grid[rIndex - 1, cIndex] == grid[rIndex, cIndex + 1] && grid[rIndex - 1, cIndex] != .water
                                }
                                return false
                            }).reduce(false) { $0 || $1 }
                            
                            if !isCrossed { availableIndexSets.append(indexSet) }
                        }
                    }
                }
            }
            
            guard let indexSet = availableIndexSets.randomElement() else {
                fatalError(#function + " no available positions for ship \(ship.number)")
            }
            
            for indexPair in indexSet {
                grid[indexPair.0, indexPair.1] = .ship(ship.number)
            }
        }
        
        mutating func shoot(at coordinate: Coordinate) -> ShotResult {
            switch self[coordinate] {
            case .water:
                return .splash
            case .ship(let number):
                guard let index = ships.firstIndex(where: { $0.number == number }) else { fatalError(#function + " invalid ship number \(number)") }
                ships[index].hits += 1
                self[coordinate] = .hit(ships[index].number)
                return .hit(ships[index])
            case .hit(let number):
                guard let ship = ships.first(where: { $0.number == number }) else { fatalError(#function + " invalid ship number \(number)") }
                if ship.isSunk {
                    return .hitSunkShip(ship)
                } else {
                    return .reHit(ship)
                }
            }
        }
        
        func numberSunk(of type: ShipType) -> Int {
            return (ships.filter { $0.type == type && $0.isSunk }).count
        }
    }
    
    func run() {
        printHeader(title: "Battle")
        
        //10 REM -- BATTLE WRITTEN BY RAY WESTERGARD  10/70
        //20 REM COPYRIGHT 1971 BY THE REGENTS OF THE UNIV. OF CALIF.
        //30 REM PRODUCED AT THE LAWRENCE HALL OF SCIENCE, BERKELEY

        repeat {
            play()
        } while true
    }
    
    private func play() {
        var board = Board()
        var splashes = 0.0
        var hits = 0.0
        
        println()
        println("The following code of the bad guys' fleet disposition")
        println("has been captured but not decoded:")
        println()
        for codedRowString in board.codedRowStrings {
            println(codedRowString)
        }
        println()
        println("De-code it and use it if you can")
        println("but keep the de-coding method a secret.")
        println()
        println("Start game")  //1170
        
        repeat {
            let coordinate = getShot()
            let result = board.shoot(at: coordinate)
            switch result {
            case .splash:
                println("Splash!  Try again.")
                splashes += 1
            case .hit(let ship):
                println("A direct hit on ship number  \(ship.number)")
                hits += 1
                if ship.isSunk {
                    println("and you sunk it.  Hurrah for the good guys.")
                    println("So far, the bad guys have lost")
                    println(" \(board.numberSunk(of: .destroyer)) Destroyer(s),    \(board.numberSunk(of: .cruiser)) Cruiser(s), and   \(board.numberSunk(of: .carrier)) Aircraft Carrier(s).")
                    println("Your current splash/hit ratio is " + (splashes / hits).formatted(.basic))
                } else {
                    println("Try again.")
                }
            case .reHit(let ship):
                println("You already put a hole in ship number \(ship.number)")
                println("at that point.")
                println("Splash!  Try again.")
                splashes += 1
            case .hitSunkShip:
                println("There used to be a ship at that point, but you sunk it.")
                println("Splash!  Try again.")
                splashes += 1
            }
        } while !board.isGameOver
        
        println()
        println("You have totally wiped out the bad guys' fleet")
        println("with a final spash to hit ratio of " + (splashes / hits).formatted(.basic))
        if splashes / hits == 0 {
            println("Congratulations -- a direct hit every time.")
        }
        println()
        println(String(repeating: "*", count: 28))
        println()
        unlockEasterEgg(.battle)
    }
    
    private func getShot() -> Coordinate {
        guard let coordinate = Coordinate(input()), coordinate.x > 0, coordinate.x < 7, coordinate.y > 0, coordinate.y < 7 else {
            println("Invalid input.  Try again.")
            return getShot()
        }
        return coordinate
    }
    
    func test() {
        let board = Board()
        for rowString in board.rowStrings {
            Swift.print(rowString)
        }
        
        Swift.print()
        Swift.print("Coded board")
        //Print coded board
        for rowString in board.codedRowStrings {
            Swift.print(rowString)
        }
        Swift.print()
    }
}
