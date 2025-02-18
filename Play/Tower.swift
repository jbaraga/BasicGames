//
//  Tower.swift
//  play
//
//  Created by Joseph Baraga on 1/27/25.
//

import Foundation

class Tower: BasicGame {
    
    private struct Disk: CustomStringConvertible {
        let size: Int
        
        var code: Int { size }
        var description: String { String(repeating: "*", count: size) }
        
        static let allowedSizes = [3, 5, 7, 9, 11, 13, 15]
        static var allowedSizesString: String {
            return Self.allowedSizes[0..<Self.allowedSizes.count - 1].map { "\($0)," }.joined() + " or \(Self.allowedSizes[Self.allowedSizes.count - 1])"
        }
    }
    
    private struct Tower {
        var disks: [Disk]  //Largest disk is last index, smallest disk is first index (0)
        
        static var maximumCount: Int { Disk.allowedSizes.count }
        
        init(number: Int = 0) {
            disks = []
            guard number > 0 else { return }
            let sizes = Disk.allowedSizes[(Disk.allowedSizes.count - number)...]
            for size in sizes {
                disks.append(Disk(size: size))
            }
        }
        
        func levelString(for index: Int) -> String {
            if index < Self.maximumCount - disks.count {
                let padding = String(repeating: " ", count: 7)
                return padding + "*" + padding
            }
            
            let diskIndex = index - (Self.maximumCount - disks.count)
            let disk = disks[diskIndex]
            let padding = String(repeating: " ", count: (15 - disk.size) / 2)
            return padding + disk.description + padding
        }
        
        func isDiskOnTower(code: Int) -> Bool {
            return disks.contains(where: { $0.size == code })
        }
        
        func isDiskOnTop(code: Int) -> Bool {
            guard let topDisk = disks.first else { return false }
            return code == topDisk.code
        }
        
        func isDiskAllowedOnTop(code: Int) -> Bool {
            guard let topDisk = disks.first else { return true }
            return code < topDisk.size
        }
        
        mutating func removeTopDisk() -> Disk {
            disks.removeFirst()
        }
        
        mutating func addDiskToTop(disk: Disk) {
            disks.insert(disk, at: 0)
        }
    }
    
    
    func run() {
        printHeader(title: "Tower")
        
        //90
        repeat {
            println()
            println("Towers of Hanoi Puzzle")
            println()
            println("You must transfer the disks from the left to the right")
            println("tower, one at a time, never putting a larger disk on a")
            println("smaller disk.")
            println()
            
            play()
            print("Try again (yes or no)")
        } while tryAgain() == .yes
                    
        println()
        println("Thanks for the game!")
        println()
        end()
    }
    
    private func play() {
        let number = getNumberOfDisks()
        println()
        println("In this program, we shall refer to disks by numerical code.")
        println("3 will represent the smallest disk, 5 the next size,")
        println("7 the next, and so on, up to 15.  If you do the puzzle with")
        println("2 disks, their code names would be 13 and 15.  With 3 disks")
        println("the code name would be 11, 13 and 15, etc.  The needles")
        println("are numbered from left to right, 1 to 3.  We will")
        println("start with the disks on needle 1, and attempt to move them")
        println("to needle 3.")
        println()
        println("Good luck!")
        println()
        
        //340 REM *** STORE DISKS FROM SMALLEST TO LARGEST
        var towers = [Tower(number: number), Tower(), Tower()]
        print(towers: towers)
        var moves = 0
        
        repeat {
            if moves > 128 {
                println("Sorry, but I have orders to stop if you make more than")
                println("128 moves.")
                end()
            }
            
            let (code, towerIndex) = getDiskToMove(towers: towers)
            if let destinationTowerNumber = getDestinationTower(code: code, towers: towers) {
                //875 REM *** MOVE RELOCATED DISK
                //925 REM *** LOCATE EMPTY SPACE ON NEEDLE N
                //965 REM *** MOVE DISK AND SET OLD LOCATION TO 0
                let disk = towers[towerIndex].removeTopDisk()
                    towers[destinationTowerNumber - 1].addDiskToTop(disk: disk)
                    
                //995 REM *** PRINT OUT CURRENT STATUS
                print(towers: towers)
                
                //1018 REM *** CHECK IF DONE
                moves += 1
            }
        } while (towers.last?.disks.count ?? 0) < number
        
        if moves < number * number - 1 {
            println("Congratulations!!")
            unlockEasterEgg(.tower)
        }
        println("You have performed the task in \(moves) moves.")
        println()
    }
    
    //215-320
    private func getNumberOfDisks(_ retries: Int = 0) -> Int {
        guard let number = Int(input("How many disks do you want to move (7 is max)")), (1...7).contains(number) else {
            if retries == 2 {
                println("All right, wise guy, if you can't play the game right, I'll")
                println("just take my puzzle and go home.  So long.")
                end()
            }
            println("Sorry, but I can't do that job for you.")
            return getNumberOfDisks(retries + 1)
        }
        return number
    }
    
    //480-690
    private func getDiskToMove(_ retries: Int = 0, towers: [Tower]) -> (code: Int, towerIndex: Int) {
        guard let code = Int(input("Which disk would you like to move")), Disk.allowedSizes.contains(code) else {
            if retries == 1 {
                println("All right, wise guy, if you can't play the game right, I'll")
                println("just take my puzzle and go home.  So long.")
                end()
            }
            println("Illegal entry... you may only type " + Disk.allowedSizesString + ".")
            return getDiskToMove(retries + 1, towers: towers)
        }
        
        //480 REM CHECK IF REQUESTED DISK IS BELOW ANOTHER
        guard let index = towers.firstIndex(where: { $0.isDiskOnTower(code: code) }), towers[index].isDiskOnTop(code: code) else {
            println("That disk is below another one.  Make another choice.")
            return getDiskToMove(retries, towers: towers)
        }
        
        return (code, index)
    }
    
    //705-860
    private func getDestinationTower(_ retries: Int = 0, code: Int, towers: [Tower]) -> Int? {
        guard let towerNumber = Int(input("Place disk on which needle")), (1...3).contains(towerNumber) else {
            if retries == 1 {
                println("I tried to warn you, but you wouldn't listen.")
                println("Bye, bye, big shot.")
                end()
            }
            println("I'll assume you hit the wrong key this time.  But watch it,")
            println("I only allow one mistake.")
            return getDestinationTower(retries + 1, code: code, towers: towers)
        }
        
        //835 REM *** CHECK IF DISK TO BE PLACED ON A LARGER ONE
        guard towers[towerNumber - 1].isDiskAllowedOnTop(code: code) else {
            println("You can't place a larger disk on top of a smaller one,")
            println("it might crush it!")
            print("Now then, ")
            return nil
        }
        return towerNumber
    }
    
    //1230 REM *** PRINT SUBROUTINE
    private func print(towers: [Tower]) {
        for rowIndex in 0...6 {
            for (index, tower) in towers.enumerated() { print(tab(5 + index * 21), tower.levelString(for: rowIndex)) }
            println()
        }
    }
    
    private func tryAgain() -> Response {
        let response = Response(input())
        if response.isOther {
            println()
            print("'Yes' or 'no' please")
            return tryAgain()
        }
        return response
    }
}
