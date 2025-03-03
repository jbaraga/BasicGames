//
//  Amazing.swift
//  Amazing
//
//  Created by Joseph Baraga on 12/18/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation

class Amazing: BasicGame {
    private let maximumSize = Size(width: 30, height: 72)
    
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
        printHeader(title: "Amazing Program", newlines: 0)
        
        repeat {
            println(3)
            play()
        } while Response(input("Run again")).isYes
        
        end()
    }
    
    private func play() {
        let size = getDimensions()
        println(3)
        
        consoleIO.startHardcopy()
        generateMaze(size: size)
        consoleIO.endHardcopy()
        println(3)
        wait(.long)
        
        let hardcopy = input("Would you like a hardcopy")
        if hardcopy.isYes {
            consoleIO.printHardcopy()
            wait(.long)
        }
        
        if size.width > 4 { unlockEasterEgg(.amazing) }
    }

    
    private func getDimensions() -> Size {
        guard let size: Size = input("What are your width and length") else {
            println("Meaningless dimensions.  Try Again.")
            return getDimensions()
        }
        
        guard size.width <= maximumSize.width, size.height <= maximumSize.height else {
            println("Maximum dimensions \(maximumSize).  Try Again.")
            return getDimensions()
        }
        return size
    }
        
    //MARK: Generate and print maze
    private func generateMaze(size: Size) {
        let numberOfSquares = size.width * size.height
        var squares = dim(size.height, size.width, value: Square())
        var isThereAnExit = false
        var row = 0
        var column = 0
        var squaresVisited = 0
        
        //Enter maze at random column
        let entryColumn = Int(rnd(Double(size.width)))
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
            if column == size.width {
                column = 0
                row += 1
                if row == size.height { row = 0 }
            }
        }

        while squaresVisited < numberOfSquares || !isThereAnExit {
            //MAKE LIST OF UNBLOCKED DIRECTIONS
            var allowedDirections = [Direction]()
            
            //Left
            if column > 0 && squares[row][column - 1].hasNotBeenVisited { allowedDirections.append(.left) }
            //Right
            if column < size.width - 1 && squares[row][column + 1].hasNotBeenVisited { allowedDirections.append(.right) }
            //Up
            if row > 0 && squares[row - 1][column].hasNotBeenVisited { allowedDirections.append(.up) }
            //Down
            if row < size.height - 1 {
                if squares[row + 1][column].hasNotBeenVisited { allowedDirections.append(.down) }
            } else {
                //At bottom row - allow for exit through bottom
                if !isThereAnExit { allowedDirections.append(.down) }
            }
            
            if allowedDirections.count > 0 {
                //Pick random direction from allowed directions
                let x = Int(rnd(Double(allowedDirections.count)))
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
                
                if row < size.height {
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
        for i in 0..<size.width {
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
    
    /* Recursive method
    private func generateMazeRecursive(size: Size) {
        var mazeGenerator = MazeGenerator(size: size)
        let maze = mazeGenerator.generateMaze()
        println(maze)
    }
    */
 }
    

/*//Recursive method, based on original code flow
private struct MazeGenerator {
    private var width = 0  //h
    private var length = 0  //v
    private var numberOfSquares = 0
    private var w = [[Int]]()  // > 0 if square has been visited
    private var v = [[Int]]()  //Keeps track of right and bottom walls for each cell
    private var x = 1  //Entry point
    private var c = 1  //Square counter
    private var r = 1  //Horizontal position
    private var s = 1  //Vertical position
    private var q = false  //Int in original Basic, 0 or 1 - used to determine if exit present
    private var z = false  //Int in original Basic, 0 or 1 - used to determine if exit present
    
    init(size: Size) {
        //Line 195
        numberOfSquares = size.width * size.height
        width = size.width
        length = size.height
        w = Array(repeating: Array(repeating: 0, count: length + 1), count: width + 1)
        v = Array(repeating: Array(repeating: 0, count: length + 1), count: width + 1)
        q = false
        z = false
        x = Int.random(in: 1...size.width)  //Entry point
        c = 1
        w[x][1] = c
        c += 1
        r = x
        s = 1
    }
    
    mutating func generateMaze() -> String {
        goToNextSquare()
        
        var string = ""
        //First row, extry at column x
        for i in 1...width {
            if i == x {
                string.append(".  ")
            } else {
                string.append(".--")
            }
        }
        string.append(".\n")
        
        for j in 1...length {
            //Print spaces and vertical dividers
            string.append("I")
            for i in 1...width {
                if v[i][j] < 2 {
                    string.append("  I")
                } else {
                    string.append("   ")
                }
            }
            string.append("\n")
            
            //Print horizontal dividers
            for i in 1...width {
                if v[i][j] == 0 || v[i][j] == 2 {
                    string.append(":--")
                } else {
                    string.append(":  ")
                }
            }
            string.append(".\n")
        }

        return string
    }
    
    private func rnd(_ x: Int) -> Int {
        return Int.random(in: 0...x)
    }
    
    //Line 210
    mutating private func scanRowForOpening() {
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
    mutating private func goToNextSquare() {
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
                let x = Int.random(in: 0...2)
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
    mutating private func goLeftOrUpOrDown() {
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
    mutating private func goLeftOrRightOrDown() {
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
    mutating private func goLeftOrDown() {
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
    mutating private func goRightOrUpOrDown() {
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
    
    mutating private func goDownOrScanRow() {
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
    mutating private func goLeft() {
        w[r-1][s] = c
        v[r-1][s] = 2
        r -= 1
        c += 1
        q = false
    }
    
    //Line 820
    mutating private func goUp() {
        w[r][s-1] = c
        v[r][s-1] = 1
        s -= 1
        c += 1
        q = false
    }
    
    //Line 830 - goUp() skipping line 820, without setting w
    mutating private func goBackUp() {
        v[r][s-1] = 1
        s -= 1
        c += 1
        q = false
    }
    
    //Line 860
    mutating private func goRight() {
        w[r+1][s] = c
        v[r][s] = v[r][s] == 0 ? 2 : 3
        r += 1
        c += 1
        if c <= numberOfSquares {
            goRightOrUpOrDown()
        }
    }
    
    //Line 910
    mutating private func goDown() {
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
}
*/
