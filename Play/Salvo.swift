//
//  Salvo.swift
//  play
//
//  Created by Joseph Baraga on 2/15/25.
//

import Foundation

class Salvo: BasicGame {
    
    //Similar game to Battle
    //Some data structures and methods, in particular random ship placement for computer, used in that game are duplicated here
    typealias Coordinate = Point
    
    private enum Player: CaseIterable {
        case user, computer
        
        var other: Player { self == .user ? .computer : .user }
    }
    
    private enum Ship: CaseIterable, CustomStringConvertible {
        case battleship, cruiser, destroyerA, destroyerB
        
        var description: String {
            switch self {
            case .battleship: return "Battleship"
            case .cruiser: return "Cruiser"
            case .destroyerA: return "Destroyer<A>"
            case .destroyerB: return "Destroyer<B>"
            }
        }
        
        var symbol: String {
            switch self {
            case .battleship: return "BS"
            case .cruiser: return "CS"
            case .destroyerA: return "DA"
            case .destroyerB: return "DB"
            }
        }
        
        var length: Int {
            switch self {
            case .battleship: return 5
            case .cruiser: return 3
            case .destroyerA, .destroyerB: return 2
            }
        }
        
        var shots: Int {
            switch self {
            case .battleship: return 3
            case .cruiser: return 2
            case .destroyerA, .destroyerB: return 1
            }
        }
        
        var integerValue: Int { shots }
        
        var testCoordinates: [Coordinate] {
            switch self {
            case .battleship: return (6...10).map { Coordinate($0,$0) }
            case .cruiser: return [(3,5), (2,6), (1,7)].map { Coordinate($0) }
            case .destroyerA: return [(1,10), (2,10)].map { Coordinate($0) }
            case .destroyerB: return [(6,7), (6,8)].map { Coordinate($0) }
            }
        }
    }
    
    private enum Square: Equatable, CustomStringConvertible {
        case water
        case shot(Int)
        case ship(Ship)
        
        var description: String {
            switch self {
            case .water: return "--"
            case .shot(let number): return number.formatted(.number.precision(.integerLength(2...2)))
            case .ship(let ship): return ship.symbol
            }
        }
    }
    
    private struct Hit: Equatable {
        let round: Int  //C
        let ship: Ship
    }
    
    private struct Board {
        private var grid = Matrix(rows: 10, columns: 10, value: Square.water)
        var hits = [Hit]()  //Store unsunk ships hit by round on opponents board, for computer shot logic
        
        var rows: [[Square]] { grid.rows }
        
        //A,B = number of shots left for remaining ships
        var remainingFirepower: Int {
            Ship.allCases.reduce(0) { $0 + (remainingSquares(for: $1).count > 0 ? $1.shots : 0) }
        }
        
        //P3 = number of water and ship element
        var remainingTargets: Int {
            return (grid.elements.filter {
                switch $0 {
                case .water, .ship(_): return true
                case .shot(_): return false
                }
            }).count
        }
            
        //Row and column, one indexed
        subscript(_ x: Int, _ y: Int) -> Square {
            get { grid[x - 1, y - 1] }
            set { grid[x - 1, y - 1] = newValue }
        }
        
        //One indexed
        subscript(_ coordinate: Coordinate) -> Square {
            get { self[coordinate.x, coordinate.y] }
            set { self[coordinate.x, coordinate.y] = newValue }
        }
        
        init() {}
        
        init(player: Player) {
            switch player {
            case .user:
                self.init()
                
            case .computer:
                self.init()
                //1100-1490, 2910-2950 - random ship placement, replaces original logic
                for ship in Ship.allCases { add(ship: ship) }
            }
        }
        
        func isValid(coordinate: Coordinate) -> Bool {
            return (1...grid.rows.count).contains(coordinate.x) && (1...grid.columns.count).contains(coordinate.y)
        }
        
        func isShotAllowed(at coordinate: Coordinate) -> Bool {
            guard isValid(coordinate: coordinate) else { return false }
            switch self[coordinate] {
            case .shot(_): return false
            case .ship(_), .water: return true
            }
        }
        
        func remainingSquares(for ship: Ship) -> [Square] {
            return grid.elements.filter { $0 == .ship(ship) }
        }
        
        func coordinates(for ship: Ship) -> [Coordinate] {
            return (grid.indexes.filter { grid[$0] == .ship(ship) }).map { Coordinate($0.row + 1, $0.column + 1) }
        }
        
        func previousShot(at coordinate: Coordinate) -> Int? {
            switch self[coordinate] {
            case .shot(let round):
                return round
            default:
                return nil
            }
        }
        
        mutating func add(ship: Ship) {
            let mask = Array(repeating: Square.water, count: ship.length)
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
                fatalError(#function + " no available positions for ship \(ship)")
            }
            
            for indexPair in indexSet {
                grid[indexPair.0, indexPair.1] = .ship(ship)
            }
        }
        
        mutating func shoot(at coordinate: Coordinate, round: Int) -> Square {
            let element = self[coordinate]
            self[coordinate] = .shot(round)
            return element
        }
        
        //3570-3730
        //Adds hits by round, clears hits on ship if sunk
        mutating func add(hit: Hit) {
            hits.append(hit)
            let ship = hit.ship
            if (hits.filter { $0.ship == ship }).count == ship.length {
                hits.removeAll(where: { $0.ship == ship })
            }
        }
        
        //Testing
        mutating func addTestShips() {
            for ship in Ship.allCases {
                for coordinate in ship.testCoordinates { self[coordinate] = .ship(ship) }
            }
        }
        
        
        func testPrint() {
            for row in rows {
                Swift.print(row.map { $0.description }.joined(separator: "  "))
            }
            Swift.print()
        }
    }
    
    func run() {
        printHeader(title: "Salvo")
        play()
        end()
    }
    
    private func play() {
        var userBoard = getUserBoard()
        var computerBoard = Board(player: .computer)
        var player = getStarter(computerBoard: computerBoard)  //J$
        let showComputerShots = Response(input("Do you want to see my shots")) == .yes  //K$
        var round = 1
                
        //1940 REM********************START
        repeat {
            println()
            println("Turn \(round)")
            
            for _ in 1...2 {
                switch player {
                case .user:
                    let coordinates = getUserShots(userBoard: userBoard, computerBoard: computerBoard)
                    for coordinate in coordinates {
                        let result = computerBoard.shoot(at: coordinate, round: round)
                        switch result {
                        case .ship(let ship):
                            println("You hit my \(ship).")
                        default:
                            break
                        }
                    }

                case.computer:
                    let coordinates = getComputerShots(userBoard: userBoard, computerBoard: computerBoard)
                    if showComputerShots { coordinates.forEach { println(" \($0.x)  \($0.y)") }}
                    
                    for coordinate in coordinates {
                        let result = userBoard.shoot(at: coordinate, round: round)
                        switch result {
                        case .ship(let ship):
                            println("I hit your \(ship).")
                            computerBoard.add(hit: .init(round: round, ship: ship))
                        default:
                            break
                        }
                    }
                }
                
                player = player.other
            }

            round += 1
        } while true
    }
    
    //1500-1700 - No validation is done in original code, added check for illegal coordinates
    private func getUserBoard() -> Board {
        var board = Board(player: .user)
        println("Enter coordinates for...")
        for ship in Ship.allCases {
            println(ship.description)
            for _ in 1...ship.length {
                board[getCoordinate()] = .ship(ship)
            }
            board.testPrint()
        }
        
        return board
    }
    
    //1710-1880
    private func getStarter(computerBoard: Board) -> Player {
        let response = Response(input("Do you want to start"))
        switch response {
        case .other(let string):
            if string.uppercased().hasPrefix("WHERE ARE YOUR SHIPS") {
                for ship in Ship.allCases {
                    println(ship.description)
                    for coordinate in computerBoard.coordinates(for: ship) {
                        println(" \(coordinate.x)  \(coordinate.y)")
                    }
                }
            }
            return getStarter(computerBoard: computerBoard)
            
        default:
            return response == .yes ? .user : .computer
        }
    }
    
    //2300-2380
    private func getCoordinate() -> Coordinate {
        guard let coordinate = Coordinate(input()), (1...10).contains(coordinate.x), (1...10).contains(coordinate.y) else {
            println("Illegal, enter again.")
            return getCoordinate()
        }
        return coordinate
    }
    
    //2190-2450
    private func getUserShots(userBoard: Board, computerBoard: Board) -> [Coordinate] {
        var coordinates = [Coordinate]()
        let shots = userBoard.remainingFirepower
        var shotNumber = 0
        println("You have \(shots) shots.")
        
        guard shots < computerBoard.remainingTargets else {
            println("You have more shots than there are blank squares.")
            println("You have won.")
            unlockEasterEgg(.salvo)  //Gives access to instructions
            end()
        }
        
        guard shots > 0 else {
            println("I have won.")
            end()
        }
        
        repeat {
            let coordinate = getCoordinate()
            if let round = computerBoard.previousShot(at: coordinate) {
                println("You shot there before on turn \(round)")
            } else {
                coordinates.append(coordinate)
                shotNumber += 1
            }
        } while shotNumber < shots
        
        return coordinates
    }
    
    //2620-3410
    private func getComputerShots(userBoard: Board, computerBoard: Board) -> [Coordinate] {
        let shots = computerBoard.remainingFirepower
        println("I have \(shots) shots.")
        
        guard shots < userBoard.remainingTargets else {
            println("I have more shots than blank squares.")
            println("I have won.")
            end()
        }
        
        guard shots > 0 else {
            println("You have won.")
            unlockEasterEgg(.salvo)  //Gives access to instructions
            end()
        }
        
        //2960-2980
        if computerBoard.hits.count > 0 {
            return getTargetedShots(number: shots, userBoard: userBoard, computerBoard: computerBoard)
        }

        return getRandomShots(number: shots, userBoard: userBoard)
    }
    
    //3000-3370
    //Creates a cluster of shots around a random location
    private func getRandomShots(number: Int, userBoard: Board) -> [Coordinate] {
        //2990 REM*******************RANDOM
        var coordinates = [Coordinate]()
        
        while coordinates.count < number {
            var r3 = 0
            var coordinate = Coordinate(x: Int.random(in: 1...10), y: Int.random(in: 1...10))
            while r3 <= 100 {
                var offsets = [(1,1), (-1,1), (1,-3), (1,1), (0,2), (-1,1)].map { Coordinate($0) }  //3030-3040
                r3 += 1
                if coordinate.x > 10 { coordinate.x = 10 - Int(rnd() * 2.5) }
                if coordinate.x < 0 { coordinate.x = 1 + Int(rnd() * 2.5) }
                if coordinate.y > 10 { coordinate.y = 10 - Int(rnd() * 2.5) }
                if coordinate.y < 0 { coordinate.y = 1 + Int(rnd() * 2.5) }
                while offsets.count > 0 {
                    if userBoard.isShotAllowed(at: coordinate), !coordinates.contains(coordinate) {
                        coordinates.append(coordinate)
                    }
                    if coordinates.count == number { return coordinates }
                    let offset = offsets.removeFirst()
                    coordinate.x += offset.x
                    coordinate.y += offset.y
                }
            }
        }
        
        return coordinates
    }
    
    //3800-4230 Shots clustered around previous shots most recently hit but unsunk ships
    private func getTargetedShots(number: Int, userBoard: Board, computerBoard: Board) -> [Coordinate] {
        //3800 REM*******************USINGEARRAY
        var kMatrix = Matrix(rows: 10, columns: 10, value: 0)  //shot rank for each coordinate, zero indexed
        kMatrix.indexes.forEach { (row, column) in
            let coordinate = Coordinate(row + 1, column + 1)
            switch userBoard[coordinate] {
            case .shot:
                kMatrix[row, column] = -10000000
            default:
                for m in offsets(for: coordinate.x) {
                    for n in offsets(for: coordinate.y) {
                        if n + m + n * m != 0 {
                            let adjacentCoordinate = Coordinate(coordinate.x + m, coordinate.y + n)
                            if case .shot(let round) = userBoard[adjacentCoordinate] {
                                let hits = computerBoard.hits.filter { $0.round == round }
                                hits.forEach { hit in
                                    kMatrix[coordinate.x - 1, coordinate.y - 1] += (10 + round) - 2 * hit.ship.integerValue  //3790 - has bug, should be 2*, not S*
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let sortedIndices = kMatrix.indexes.sorted(by: { kMatrix[$0] > kMatrix[$1] })
        return sortedIndices[0..<number].map { Coordinate($0.row + 1, $0.column + 1) }
    }
        
    //3930-3940 - clever method for calculating allowed coordinates at and adjacent to coordinate returns 0...1 for index 1, -1...0 for index 10, -1...1 for index 1...9
    private func offsets(for index: Int) -> ClosedRange<Int> {
        return sgn(1 - index)...sgn(10 - index)
    }
    
    //k 4...1 -> 1,6,9,11
    private func fna(_ k: Int) -> Int {
        return (5 - k) * 3 - 2 * (k / 4) + sgn(k - 1) - 1
    }
    
    //k 4...1 -> 4,2,1,1 = ship length - 1
    private func fnb(_ k: Int) -> Int {
        return k + k / 4 - sgn(k - 1)
    }
    
    //k 4...1 -> 3,2,1,0.5 (battleship, cruiser, destroyerA, destroyerB
    private func shipValue(k: Int) -> Double{
        return 0.5 + Double(sgn(k - 1)) * (Double(k) - 1.5)
    }
    
    func test() {
        for _ in 1...5 {
            let board = Board(player: .computer)
            board.testPrint()
        }
    }
}
