//
//  Amazing.swift
//  Amazing
//
//  Created by Joseph Baraga on 12/18/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation

/*
class Amazing: GameProtocol {
    private let MaximumWidth = 30
    private let MaximumLength = 72
    var width = 2
    var height = 2
    
    // Define the directions to move in the maze
    let directions = [
        (dx: 0, dy: -1), // Up
        (dx: 0, dy: 1), // Down
        (dx: -1, dy: 0), // Left
        (dx: 1, dy: 0) // Right
    ]

    func run() {
        (width, height) = getDimensions()
        
        // Choose a random starting cell and carve out the maze
        let startX = Int.random(in: 1..<width-1)
        let startY = Int.random(in: 1..<height-1)
        
        var maze = recursiveBacktracking(x: startX, y: startY)

        // Add an entrance and an exit to the maze
        maze[0][1] = " "
        maze[height-1][width-2] = " "

        // Print the maze
        for row in maze {
            print(String(row))
            println()
        }
    }
    
    // Define a function to check if a cell is within the maze boundaries
    private func isValidCell(x: Int, y: Int) -> Bool {
        return x >= 0 && x < width && y >= 0 && y < height
    }

    // Define a function to get the unvisited neighbors of a cell
    private func getUnvisitedNeighbors(x: Int, y: Int, maze: [[Character]]) -> [(Int, Int)] {
        var neighbors = [(Int, Int)]()
        for direction in directions {
            let neighborX = x + direction.dx
            let neighborY = y + direction.dy
            if isValidCell(x: neighborX, y: neighborY) && maze[neighborY][neighborX] == "#" {
                neighbors.append((neighborX, neighborY))
            }
        }
        return neighbors
    }

    // Define the recursive backtracking function
    private func recursiveBacktracking(x: Int, y: Int) -> [[Character]] {
        // Create a two-dimensional array to represent the maze
        var maze = [[Character]](repeating: [Character](repeating: "#", count: width), count: height)
        maze[y][x] = " "
        var stack = [(x, y)]
        while !stack.isEmpty {
            let currentCell = stack.last!
            let unvisitedNeighbors = getUnvisitedNeighbors(x: currentCell.0, y: currentCell.1, maze: maze)
            if unvisitedNeighbors.isEmpty {
                stack.removeLast()
                break
            }
            let randomNeighbor = unvisitedNeighbors.randomElement()!
            let direction = (
                dx: randomNeighbor.0 - currentCell.0,
                dy: randomNeighbor.1 - currentCell.1
            )
            maze[currentCell.1 + direction.dy / 2][currentCell.0 + direction.dx / 2] = " "
            maze[randomNeighbor.1][randomNeighbor.0] = " "
            stack.append(randomNeighbor)
        }
        return maze
    }
    
    private func getDimensions() -> (width: Int, height: Int) {
        wait(.short)
        let response = input("What are your width and length")
        let components = response.components(separatedBy: CharacterSet.decimalDigits.inverted)
        guard components.count > 1, let first = components.first, let last = components.last, let width = Int(first), let height = Int(last), width > 0, height > 0 else {
            println("Meaningless dimensions.  Try Again.")
            return getDimensions()
        }
        guard width <= MaximumWidth, height <= MaximumLength else {
            println("Maximum dimensions \(MaximumWidth) x \(MaximumLength).  Try Again.")
            return getDimensions()
        }
        return (width, height)
    }
}
*/


class Amazing: GameProtocol {
    private let MaximumWidth = 30
    private let MaximumLength = 72
    
    private struct Square {
        var hasRightWall = true
        var hasBottomWall = true
        var hasBeenVisited = false
        
        var hasNotBeenVisited: Bool {
            return !hasBeenVisited
        }
        
        mutating func eraseRightWall() {
            self.hasRightWall = false
        }
        
        mutating func eraseBottomWall() {
            self.hasBottomWall = false
        }
        
        mutating func markVisited() {
            self.hasBeenVisited = true
        }
    }
    
    private enum Direction {
        case left
        case right
        case up
        case down
    }

        
    func run() {
        printHeader(title: "Amazing Program")
        
        var response = Response.yes
        repeat {
            println(3)
            playGame()
            response = Response(input("Run again"))
        } while response.isYes
        
        if response == .easterEgg { showEasterEgg(.amazing) }
        end()
    }
    
    private func playGame() {
        let (width, length) = getDimensions()
        println(3)
        
        consoleIO.startHardcopy()
        generateMaze(width: width, height: length)
        consoleIO.endHardcopy()
        println(3)
        wait(.long)
        
        let hardcopy = input("Would you like a hardcopy")
        if hardcopy.isYes {
            consoleIO.printHardcopy()
            wait(.long)
        }
    }
    
    private func getDimensions() -> (width: Int, height: Int) {
        wait(.short)
        let response = input("What are your width and length")
        let components = response.components(separatedBy: CharacterSet.decimalDigits.inverted)
        guard components.count > 1, let first = components.first, let last = components.last, let width = Int(first), let height = Int(last), width > 0, height > 0 else {
            println("Meaningless dimensions.  Try Again.")
            return getDimensions()
        }
        guard width <= MaximumWidth, height <= MaximumLength else {
            println("Maximum dimensions \(MaximumWidth) x \(MaximumLength).  Try Again.")
            return getDimensions()
        }
        return (width, height)
    }
        
    //MARK: Generate and print maze
    private func generateMaze(width: Int, height: Int) {
        let numberOfSquares = width * height
        var squares = dim(height, width, value: Square())
        var isThereAnExit = false
        var row = 0
        var column = 0
        var squaresVisited = 0
        
        //Enter maze at random column
        let entryColumn = Int(rnd(width))
        column = entryColumn
        squares[row][column].markVisited()
        squaresVisited += 1
        
        /*A CORRIDOR IS CONSTRUCTED BY MOVING IN A RANDOM DIRECTION FROM THE CURRENT SQUARE TO SOME SQUARE THAT
         HAS NOT BEEN VISITED YET AND ERASING THE WALL BETWEEN THE TWO SQUARES. IF NO SUCH MOVE IS POSSIBLE,
         A SIDE CORRIDOR IS STARTED IN SOME SQUARE ALREADY VISITED WHICH IS ADJACENT TO AN UNVISITED SQUARE.
         ONLY ONE EXIT TO THE BOTTOM OF THE MAZE IS ALLOWED.*/
        //Moves left to right, up to down from current square in raster fashion
        func moveToNextSquare() {
            column += 1
            if column == width {
                column = 0
                row += 1
                if row == height { row = 0 }
            }
        }

        while squaresVisited < numberOfSquares || !isThereAnExit {
            //MAKE LIST OF UNBLOCKED DIRECTIONS
            var allowedDirections = [Direction]()
            
            //Left
            if column > 0 && squares[row][column - 1].hasNotBeenVisited { allowedDirections.append(.left) }
            //Right
            if column < width - 1 && squares[row][column + 1].hasNotBeenVisited { allowedDirections.append(.right) }
            //Up
            if row > 0 && squares[row - 1][column].hasNotBeenVisited { allowedDirections.append(.up) }
            //Down
            if row < height - 1 {
                if squares[row + 1][column].hasNotBeenVisited { allowedDirections.append(.down) }
            } else {
                //At bottom row - allow for exit through bottom
                if !isThereAnExit { allowedDirections.append(.down) }
            }
            
            if allowedDirections.count > 0 {
                //Pick random direction from allowed directions
                let x = Int(rnd(allowedDirections.count))
                let direction = allowedDirections[x]
                
                switch direction {
                case .left:
                    column -= 1
                    squares[row][column].eraseRightWall()
                case .right:
                    squares[row][column].eraseRightWall()
                    column += 1
                case .up:
                    row -= 1
                    squares[row][column].eraseBottomWall()
                case .down:
                    squares[row][column].eraseBottomWall()
                    row += 1
                }
                
                if row < height {
                    //Still in maze. Mark square as used and increment counter
                    squares[row][column].markVisited()
                    squaresVisited += 1
                } else {
                    //Exited bottom
                    isThereAnExit = true
                    //Go visit other squares, starting at origin (0,0)
                    column = 0
                    row = 0
                    //Raster scan to the first used square
                    while squares[row][column].hasNotBeenVisited {
                        moveToNextSquare()
                    }
                }
            } else {
                //All directions blocked. Restart in next used square to right and below,
                //in raster scan fashion, from square to right of current position (column, row)
                moveToNextSquare()
                while squares[row][column].hasNotBeenVisited {
                    moveToNextSquare()
                }
            }
        }
        
        //Print out maze
        //Top line with opening at entryColumn
        for i in 0..<width {
            i == entryColumn ? print(".  ") : print(".--")
        }
        println(".")
        
        //Remainder of maze
        for row in squares {
            //Vertical dividers
            print("I")
            for square in row {
                square.hasRightWall ? print("  I") : print("   ")
            }
            println()
            
            //Horizontal dividers
            for square in row {
                square.hasBottomWall ? print(":--") : print(":  ")
            }
            println(".")
        }
    }
 }
    
    /*Recursive version, based on Ahl
    private var width = 0  //h
    private var length = 0  //v
    private var numberOfSquares = 0
    private var w = [[Int]]()  // > 0 if square has been visited
    private var v = [[Int]]()  //Keeps track of right and bottom walls for each cell
    private var c = 1  //Square counter
    private var r = 1  //Horizontal position
    private var s = 1  //Vertical position
    private var q = false  //Int in original Basic, 0 or 1 - used to determine if exit present
    private var z = false  //Int in original Basic, 0 or 1 - used to determine if exit present
    
    //Line 195
    private func generateMaze(width: Int, height: Int) {
        //Initialize maze.  Arrays are indexed starting at 1
        numberOfSquares = width * length
        w = Array(repeating: Array(repeating: 0, count: length + 1), count: width + 1)
        v = Array(repeating: Array(repeating: 0, count: length + 1), count: width + 1)
        q = false
        z = false
        let x = rnd(width - 1) + 1  //Entry point
        c = 1
        w[x][1] = c
        c += 1
        r = x
        s = 1
        goToNextSquare()
        printMaze(withEntryAt: x)
    }
    
    //Line 210
    private func scanRowForOpening() {
        repeat {
            if r < width {
                r += 1
            } else {
                r = 1
                if s < length {
                    s += 1
                } else {
                    s = 1
                }
            }
        } while w[r][s] == 0
        
        goToNextSquare()
    }
    
    
    //Line 260
    private func goToNextSquare() {
        while c <= numberOfSquares {
            switch (r, s) {
            case _ where  r == 1 || w[r-1][s] > 0:
                goRightOrUpOrDown()
                
            case _ where s == 1 || w[r][s-1] > 0:
                if r == width || w[r + 1][s] > 0 {
                    goLeftOrDown()
                } else {
                    goLeftOrRightOrDown()
                }
                
            case _ where r == width || w[r+1][s] > 0:
                goLeftOrUpOrDown()
                
            default:
                //Go left or up or right, randomly select direction
                let x = rnd(2)
                switch x {
                case 0:
                    goLeft()
                case 1:
                    goUp()
                case 2:
                    goRight()
                default:
                    break
                }
            }
        }
    }
    
    //Line 330
    private func goLeftOrUpOrDown() {
        let x: Int
        if s < length {
            if w[r][s + 1] > 0 {
                x = rnd(1)  //Left or up
            } else {
                x = rnd(2)  //Left or up or down
            }
        } else {
            if z {
                x = rnd(1)  //Left or up
            } else {
                q = true
                x = rnd(2)  //Left or up or down
            }
        }
        
        switch x {
        case 0:
            goLeft()
        case 1:
            goUp()
        case 2:
            goDown()
        default:
            break
        }
    }
    
    //Line 390
    private func goLeftOrRightOrDown() {
        //Left or right or down
        let x: Int
        if s < length {
            if w[r][s + 1] > 0 {
                x = rnd(1)  //Left or right
            } else {
                x = rnd(2)  //Left or right or down
            }
        } else {
            if z {
                x = rnd(1)  //Left or right
            } else {
                q = true
                x = rnd(2)  //Left or right or down
            }
        }
        
        switch x {
        case 0:
            goLeft()
        case 1:
            goRight()
        case 2:
            goDown()
        default:
            break
        }
    }
    
    //Line 470
    private func goLeftOrDown() {
        let x: Int
        if s < length {
            if w[r][s + 1] > 0 {
                x = 0  //Left
            } else {
                x = rnd(1)  //Left or down
            }
        } else {
            if z {
                x = 0  //Left
            } else {
                q = true
                x = rnd(1)  //Left or down
            }
        }
        
        switch x {
        case 0:
            goLeft()
        case 1:
            goDown()
        default:
            break
        }
    }
    
    //Line 530
    private func goRightOrUpOrDown() {
        switch (r, s) {
        case _ where s == 1 || w[r][s - 1] > 0:
            //Line 670. Go right or down
            if r == width || w[r + 1][s] > 0 {
                goDownOrScanRow()
            } else {
                let x: Int
                if s < length {
                    if w[r][s + 1] > 0 {
                        x = 0
                    } else {
                        x = rnd(1)
                    }
                } else {
                    if z {
                        x = 0
                    } else {
                        q = true
                        x = 2
                    }
                }
                
                switch x {
                case 0:
                    goRight()
                case 1:
                    goDown()
                case 2:
                    goBackUp()
                default:
                    break
                }
            }

        case _ where r == width || w[r + 1][s] > 0:
            //Up or down
            let x: Int
            if s < length {
                if w[r][s + 1] > 0 {
                    x = 0
                } else {
                    x = rnd(1)
                }
            } else {
                if z {
                    x = 0
                } else {
                    q = true
                    x = rnd(1)
                }
            }
            
            switch x {
            case 0:
                goUp()
            case 1:
                goDown()
            default:
                break
            }

        default:
            //Go right or up or down
            let x: Int
            if s < length {
                if w[r][s + 1] > 0 {
                    x = rnd(1)  //Up or right
                } else {
                    x = rnd(2)  //Up or right or down
                }
            } else {
                if z {
                    x = rnd(1)  //Up or right
                } else {
                    q = true
                    x = rnd(2)  //Up or right or down
                }
            }
            
            switch x {
            case 0:
                goUp()
            case 1:
                goRight()
            case 2:
                goDown()
            default:
                break
            }
        }
    }
        
    private func goDownOrScanRow() {
        if s < length {
            if w[r][s + 1] > 0 {
                //Blocked
                scanRowForOpening()
            } else {
                goDown()
            }
        } else {
            if z {
                scanRowForOpening()
            } else {
                q = true
                goDown()
            }
        }
    }
    
    //Line 790
    private func goLeft() {
        w[r-1][s] = c
        v[r-1][s] = 2
        r -= 1
        c += 1
        q = false
    }
    
    //Line 820
    private func goUp() {
        w[r][s-1] = c
        v[r][s-1] = 1
        s -= 1
        c += 1
        q = false
    }
    
    //Line 830 - goUp() skipping line 820, without setting w
    private func goBackUp() {
        v[r][s-1] = 1
        s -= 1
        c += 1
        q = false
    }
    
    //Line 860
    private func goRight() {
        w[r+1][s] = c
        v[r][s] = v[r][s] == 0 ? 2 : 3
        r += 1
        c += 1
        if c <= numberOfSquares {
            goRightOrUpOrDown()
        }
    }
    
    //Line 910
    private func goDown() {
        if q {
            z = true
            q = false
            if v[r][s] == 0 {
                v[r][s] = 1
                r = 1
                s = 1
                //Goto 250
                if w[r][s] == 0 {
                    scanRowForOpening()
                } else {
                    goToNextSquare()
                }
            } else {
                v[r][s] = 3
                scanRowForOpening()
            }
        } else {
            w[r][s+1] = c
            v[r][s] = v[r][s] == 0 ? 1 : 3
            s += 1
            c += 1
            goToNextSquare()
        }
    }
    
    private func printMaze(withEntryAt x: Int) {
        //First row, extry at column x
        for i in 1...width {
            if i == x {
                print(".  ")
            } else {
                print(".--")
            }
        }
        println(".")

        for j in 1...length {
            //Print spaces and vertical dividers
            print("I")
            for i in 1...width {
                if v[i][j] < 2 {
                    print("  I")
                } else {
                    print("   ")
                }
            }
            println()
            
            //Print horizontal dividers
            for i in 1...width {
                if v[i][j] == 0 || v[i][j] == 2 {
                    print(":--")
                } else {
                    print(":  ")
                }
            }
            println(".")
        }
    }
 */
