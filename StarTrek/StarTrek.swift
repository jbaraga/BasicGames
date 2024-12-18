//
//  StarTrek.swift
//  StarTrek
//
//  Created by Joseph Baraga on 2/5/22.
//

import Foundation


class StarTrek: GameProtocol {
    
    private typealias Coordinate = (x: Int, y: Int)  //Note that x = row, y = column, i.e. x and y are swapped
    
    private func coordinate(from string: String) -> Coordinate {
        let digits = string.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        return (Int(digits.first ?? "") ?? 0, Int(digits.last ?? "") ?? 0)
    }
    
    private enum Command: String, CaseIterable {
        case NAV
        case SRS
        case LRS
        case PHA
        case TOR
        case SHE
        case DAM
        case COM
        case XXX

        var description: String {
            switch self {
            case .NAV:
                return "to set course"
            case .SRS:
                return "for short range sensor scan"
            case .LRS:
                return "for log range sensor scan"
            case .PHA:
                return "to fire phasers"
            case .TOR:
                return "to fire photon torpedoes"
            case .SHE:
                return "to raise or lower shields"
            case .DAM:
                return "for damage control reports"
            case .COM:
                return "to call on library-computer"
            case .XXX:
                return "to resign you command"
            }
        }
    }
    
    private enum ComputerCommand: Int, CaseIterable {
        case galacticRecord
        case statusReport
        case photonTorpedoData
        case starbaseNavData
        case directionDistanceCalculator
        case galaxyMap
        
        var description: String {
            switch self {
            case .galacticRecord:
                return "Cumulative Galactic Record"
            case .statusReport:
                return "Status Report"
            case .photonTorpedoData:
                return "Photon Torpedo Data"
            case .starbaseNavData:
                return "Starbase Nav Data"
            case .directionDistanceCalculator:
                return "Direction/Distance Calculator"
            case .galaxyMap:
                return "Galaxy 'Region Name' Map"
            }
        }
    }
    
    private enum CoordinateContent: String {
        case emptySpace = "   "
        case enterprise = "<*>"
        case klingon = "+K+"
        case starbase = ">!<"
        case star = " * "
        
        var stringValue: String {
            return rawValue
        }
    }
    
    //BASIC arrays, one indexed
    private var g = dim(9, 9)  //Galaxy quadrants - values are 3 digit Int: hundreds digit is number of Klingons, tens digit is number of starbases, ones digit number of stars in quadrant
    private var z = dim(9, 9)  //Known galaxy quadrants - either by entry in quadrant or LRS
    private var k = dim(4, 4)  //Klingon ships in quadrant; for each ship i: k(i,1) = x coordinate, k(i,2) = y coordinate, k(i,3) = shield strength; maximum of 3 Klingons in quadrant
    private var d = [Double]()  //Damage array by index, value < 0 == nonoperational. Indexes: 1 - warp engines, 2 - short range sensory, 3 - long range sensors, 4 - phasers, 5 - photon tubes, 7 - shields, 8 - computer targeting
    
    //Movement matrix, one indexed
    private let c: [[Int]] = {
        var c = dim(10, 3)
        c[(3,1)] = -1
        c[(2,1)] = -1
        c[(4,1)] = -1
        c[(4,2)] = -1
        c[(5,2)] = -1
        c[(6,2)] = -1
        c[(1,2)] = 1
        c[(2,2)] = 1
        c[(6,1)] = 1
        c[(7,1)] = 1
        c[(8,1)] = 1
        c[(8,2)] = 1
        c[(9,2)] = 1
        return c
    }()
    
//    private let c: [[Int]] = [
//        [0,0,0],  //row 0
//        [0,0,1],  //row 1
//        [0,-1,1],  //row 2
//        [0,-1,0],  //row 3
//        [0,-1,-1],  //row 4
//        [0,0,-1],  //row 5
//        [0,1,-1],  //row 6
//        [0,1,0],  //row 7
//        [0,1,1],  //row 9
//        [0,0,1]  //row 9
//    ]
    
    private var k3 = 0  //# Klingons in current quadrant
    private var k7 = 0  //# Klingons in galaxy at start of run
    private var k9 = 0  //# Klingons in galaxy
    private var b3 = 0  //# Starbases in current quadrant - 0 or 1
    private var starbaseCoordinate = Coordinate(0, 0)  //Starbase location in quadrant
    private var b9 = 2  //# Starbases in galaxy
    private var s3 = 0  //# Stars in current quadrant
    
    private let p0 = 10  //Photon torpedoes full complement
    private var p = 10  //Photon torpedoes left
    
    private var e = 3000.0  //Energy units left
    private let e0 = 3000.0  //Full energy complement
    private var n = 0.0 // Energy needed?
    private var s = 0.0  //Shield energy units
    
    //Quadrant coordinates
    private var q1 = 0
    private var q2 = 0
    //Sector coordinates
    private var s1 = 0
    private var s2 = 0
    
    private let s9 = 200  //Klingon baseline shield strength
    
    private var t = 0.0   //current Stardate
    private var t0 = 0.0  //starting Stardate
    private var t9 = 0.0  //Number of days to complete mission
    
    private var stardate: String {
        return String(format: "%.1f", t)
    }
    
    private var isDockedAtStarbase = false  //d0 = 0 false, d0 = 1 true
    private var d4 = 0.0  //Random time added to repair time - reset every time new quadrant entered
    
    private var q$ = ""  //Quadrant string
    
    //Line 475 - returns random number between 1 and 8 * r + 1
    private func fnr(_ r: Int) -> Int {
        return Int(Double.random(in: 0...Double(r)) * 7.98 + 1.01)
    }
    
    //Line 470 - computes distance to Klingon ship in sector
    private func fnd(_ i: Int) -> Double {
        return sqrt(pow(Double(k[(i,1)]) - Double(s1), 2) + pow(Double(k[(i,2)]) - Double(s2), 2))
    }
    
    //10 REM SUPER STARTREK - MAY 16,1978 - REQUIRES 24K MEMORY
    //30 REM
    //40 REM ****        **** STAR TREK ****        ****
    //50 REM **** SIMULATION OF A MISSION OF THE STARSHIP ENTERPRISE,
    //60 REM **** AS SEEN ON THE STAR TREK TV SHOW.
    //70 REM **** ORIGINAL PROGRAM BY MIKE MAYFIELD, MODIFIED VERSION
    //80 REM **** PUBLISHED IN DEC'S "101 BASIC GAMES", BY DAVE AHL.
    //90 REM **** MODIFICATIONS TO THE LATTER (PLUS DEBUGGING) BY BOB
    //100 REM *** LEEDOM - APRIL & DECEMBER 1974,
    //110 REM *** WITH A LITTLE HELP FROM HIS FRIENDS . . .
    //120 REM *** COMMENTS, EPITHETS, AND SUGGESTIONS SOLICITED --
    //130 REM *** SEND TO:  R. C. LEEDOM
    //140 REM ***           WESTINGHOUSE DEFENSE & ELECTRONICS SYSTEMS CNTR.
    //150 REM ***           BOX 746, M.S. 338
    //160 REM ***           BALTIMORE, MD  21203
    //170 REM ***
    //180 REM *** CONVERTED TO MICROSOFT 8 K BASIC 3/16/78 BY JOHN BORDERS
    //190 REM *** LINE NUMBERS FROM VERSION STREK7 OF 1/12/75 PRESERVED AS
    //200 REM *** MUCH AS POSSIBLE WHILE USING MULTIPLE STATEMENTS PER LINE
    //205 REM *** SOME LINES ARE LONGER THAN 72 CHARACTERS; THIS WAS DONE
    //210 REM *** BY USING "?" INSTEAD OF "PRINT" WHEN ENTERING LINES
    //215 REM ***
    
    //MARK: Main program
    func run() {
        println(3)
        println(tab(34), ",------*------,")
        println(tab(19), ",------------   '---  ------'")
        println(tab(20), "'-------- --'      / /")
        println(tab(24), ",---' '-------/ /--,")
        println(tab(25), "'----------------'")
        println()
        println(tab(19), "The USS Enterprise --- NCC-1701")
        println(3)
        
        //From original Mike Mayfield version
        if input("Do you want instructions (they're long!)").isYes {
            println()
            printInstructions()
            consoleIO.wait(.long)
        }
        
        t = (rnd(20.0) + 20) * 100
        t0 = t
        t9 = 25 + rnd(10.0)
        isDockedAtStarbase = false
        e = e0
        p = p0
        s = 0
        b9 = 2
        k9 = 0
                
        //Line 480 Initialize Enterprise position
        q1 = fnr(1)
        q2 = fnr(1)
        s1 = fnr(1)
        s2 = fnr(1)
        
        d = Array(repeating: 0, count: 9)
        
        //Line 810 Setup what exists in galaxy
        for i in 1...8 {
            for j in 1...8 {
                k3 = 0
                z[(i,j)] = 0
                let r1 = rnd(1.0)  //Distinct from class var r1 (Int)
                switch r1 {
                case 0.98...1.0:
                    k3 = 3
                    k9 += 3
                case 0.95..<0.98:
                    k3 = 2
                    k9 += 2
                case 0.80..<0.95:
                    k3 = 1
                    k9 += 1
                default:
                    break
                }
                
                b3 = 0
                if rnd(1.0) > 0.96 {
                    b3 = 1
                    b9 += 1
                }
                
                g[(i,j)] = k3 * 100 + b3 * 10 + fnr(1)  //Random number of stars in range 1-8
            }
        }
        
        k7 = k9

        if Double(k9) > t9 {    //Ensure enough days to face each Klingon
            t9 = Double(k9) + 1
        }
        
        //Ensure at least one starbase by adding to current quadrant, which also adds Klingon to quadrant if less than 2, then resets enterprise quadrant
        if b9 == 0 {
            if g[(q1,q2)] < 200 {
                g[(q1,q2)] += 100
                k9 += 1
            }
            b9 = 1
            g[(q1,q2)] += 10
            q1 = fnr(1)
            q2 = fnr(1)
        }
        
        println(2)
        let x$ = b9 == 1 ? "" : "s"
        let x0$ = b9 == 1 ? "is" : "are"
        println("Your orders are as follows:")
        println("     Destroy the \(k9) Klingon warships wich have invaded")
        println("   the galaxy before they can attack Federation headquarters")
        println("   on stardate " + String(format: "%.1f", t0 + t9) + "   This gives you \(Int(t9)) days.  There " + x0$)
        println("   \(b9) starbase" + x$ + " in the galaxy for resupplying your ship")
        println()
        let _ = input("Hit return when ready to accept command", terminator: "")
        println()
        enterQuadrant()
        
         //Lines 1990-2260 Main Loop
        while k9 > 0 && t < t0 + t9 {
            if s + e < 10  && (e < 10 && d[7] != 0) {  //Combined shield and energy less than 10, or energy less 10 and shield control damaged
                //Lines 2020-2050
                println()
                println("** FATAL ERROR **   You've just stranded your ship in space")
                println("You have insufficient maneuvering energy, and shield control")
                println("is presently incapable of cross-circuiting to engine room!!")
                missionFailed()
                return
            }
            
            if let command = Command(rawValue: input("Command").uppercased()) {
                switch command {
                case .NAV:
                    navigate()
                case .SRS:
                    shortRangeSensorScan()
                case .LRS:
                    longRangeSensorScan()
                case .PHA:
                    phaserControl()
                case .TOR:
                    photonTorpedos()
                case .SHE:
                    shieldControl()
                case .DAM:
                    damageControl()
                case .COM:
                    libraryComputer()
                case .XXX:
                    missionFailed()
                    return
                }
            } else {
                println("Enter one of the following:")
                Command.allCases.forEach {
                    println("  " + $0.rawValue + "  (" + $0.description + ")")
                }
            }
        }
        
        //Fallthrough - should not occur; the
        //If k9 == 0 missionCompleted
        //If t > t0 + t9 missionFailed
    }
    
    //MARK: 1310 REM HERE ANY TIME NEW QUADRANT ENTERED
    //1320-1600
    private func enterQuadrant() {
        k3 = 0
        b3 = 0
        s3 = 0
        d4 = 0.5 * rnd(1)
        z[(q1,q2)] = g[(q1,q2)]  //Add to known galaxy map
        
        if q1 > 0 && q1 < 9 && q2 > 0 && q2 < 9  {
            let quadrantName = quadrantName(for: (q1, q2), regionOnly: false)
            if t0 == t {
                println("Your mission begins with your starship located")
                println("in the galactic quadrant, '" + quadrantName + "'.")
            } else {
                println("Now entering " + quadrantName + " quadrant . . .")
            }
            println()
            
            k3 = Int(Double(g[(q1,q2)]) * 0.01)
            b3 = Int(Double(g[(q1,q2)]) * 0.1) - 10 * k3
            s3 = g[(q1,q2)] - 100 * k3 - 10 * b3
            
            if k3 > 0 {
                println("Combat area      Condition red")
                if s <= 200 {
                    println("   Shields dangerously low")
                }
            }
            
            //Klingon positions are reset on every entry
            k = dim(4, 4)
            
            let z$ = String(repeating: " ", count: 26)  //Each quadrant row is encoded with 8 objects 3 characters long, with space at beginning and end
            q$ = [z$, z$, z$, z$, z$, z$, z$, z$.left(17)].joined(separator: "")  //String length is 225
        }
        initializeQuadrant()
        shortRangeSensorScan()
    }
    
    //MARK: 1660 REM POSITION ENTERPRISE IN QUADRANT, THEN PLACE "K3" KLINGONS, &
    //1670 REM "B3" STARBASES, & "S3" STARS ELSEWHERE
    //1680-1980
    private func initializeQuadrant() {
        //1680 Enterprise
        insertObject(.enterprise, at: (s1, s2))
        
        //1720-1780 Klingons
        if k3 > 0 {
            for i in 1...k3 {
                let coordinate = emptyLocation()
                insertObject(.klingon, at: coordinate)
                k[(i,1)] = coordinate.x
                k[(i,2)] = coordinate.y
                k[(i,3)] = Int(Double(s9) * (0.5 + rnd(1)))
            }
        }
        
        //1880-1910 Starbase
        if b3 > 0 {
            starbaseCoordinate = emptyLocation()
            insertObject(.starbase, at: starbaseCoordinate)
        }
        
        //1910 Stars
        for _ in 1...s3 {
            insertObject(.star, at: emptyLocation())
        }
    }
    
    //MARK: 2290 REM COURSE CONTROL BEGINS HERE
    //2300-3900
    private func navigate() {
        var c1 = Int(round(Double(input("Course (1-9)")) ?? -1))
        if c1 == 9 { c1 = 1 }
        
        if c1 < 1 || c1 > 9 {
            println("   Lt. Sulu reports, 'Incorrect course data, sir!'")
            return
        }
        
        let warpFactor = d[1] < 0 ? "0.2" : "8"
        let w1 = Double(input("Warp factor (0-" + warpFactor + ")")) ?? 0
        
        if w1 == 0 { return }
        if d[1] < 0 && w1 > 0.2 {
            println("Warp engines are damaged.  Maximum speed = warp 0.2")
            return
        }
        if w1 > 8 {
            println("   Chief engineer Scott reports 'The engines won't take warp \(w1)!")
            return
        }
        
        let n = round(w1 * 8)
        if e - n < 0 {
            println("Engineering reports   'Insufficient energy available")
            println("                       for maneuvering at warp \(w1)")
            if s < n - e || d[7] < 0 { return }
            println("Deflector control room acknowleges \(s) units of energy")
            println("                         presently deployed to shields.")
            return
        }
        
        //2580 REM KLINGONS MOVE/FIRE ON MOVING STARSHIP . . .
        //Klingons move
        for i in 1...3 {
            if k[(i,3)] > 0 {
                insertObject(.emptySpace, at: (k[(i,1)], k[(i,2)]))
                let coordinate = emptyLocation()
                k[(i,1)] = coordinate.x
                k[(i,2)] = coordinate.y
                insertObject(.klingon, at: coordinate)
                k[(i,1)] = coordinate.x
                k[(i,2)] = coordinate.y
            }
        }
        
        klingonAttack()
        var isDamageControlMessagePrinted = false
        let d6 = w1 > 1 ? 1 : w1
        for i in 1...8 {
            if d[i] < 0 {
                d[i] += d6
                if d[i] > -0.1 && d[i] < 0 {
                    d[i] = -0.1
                } else {
                    if d[i] >=  0 {
                        if !isDamageControlMessagePrinted {
                            isDamageControlMessagePrinted = true
                            print("Damage control report:   ")
                        }
                        println(deviceName(for: i) + " repair completed.")
                    }
                }
            }
        }
        
        if rnd(1) < 0.2 {
            let index = fnr(1)
            print("Damage control report:   ")
            if rnd(1) > 0.6 {
                //3000
                d[index] = d[index] + rnd(1) * 3 + 1
                println(deviceName(for: index) + " state of repair improved")
            } else {
                //2930
                d[index] = d[index] - (rnd(1) * 5 + 1)
                println(deviceName(for: index) + " damaged")
            }
        }
        
        //3060 REM BEGIN MOVING STARSHIP
        insertObject(.emptySpace, at: (s1, s2))
        let x1 = c[(c1,1)] + (c[(c1+1,1)] - c[(c1,1)])*(c1 - Int(c1))
        let x2 = c[(c1,2)] + (c[(c1+1,2)] - c[(c1,2)])*(c1 - Int(c1))
        var x = Double(s1)
        var y = Double(s2)
        let q4 = q1
        let q5 = q2
        
        var i = 1.0
        while i <= n {
            s1 += x1
            s2 += x2
            if s1 < 1 || s1 > 8 || s2 < 1 || s2 > 8 {
                //3490 REM EXCEEDED QUADRANT LIMITS
                //Lines 3500-3870
                x = 8 * Double(q1) + x + n * Double(x1)
                y = 8 * Double(q2) + y + n * Double(x2)
                q1 = Int(x / 8)
                q2 = Int(y / 8)
                s1 = Int(x - Double(q1) * 8)
                s2 = Int(y - Double(q2) * 8)
                if s1 == 0 {
                    q1 -= 1
                    s1 = 8
                }
                if s2 == 0 {
                    q2 -= 1
                    s2 = 8
                }
                
                var isOutsideGalaxy = false  //x5
                if q1 < 1 {
                    isOutsideGalaxy = true
                    q1 = 1
                    s1 = 1
                }
                if q1 > 8 {
                    isOutsideGalaxy = true
                    q1 = 8
                    s1 = 8
                }
                if q2 < 1 {
                    isOutsideGalaxy = true
                    q2 = 1
                    s2 = 1
                }
                if q2 > 8 {
                    isOutsideGalaxy = true
                    q2 = 8
                    s2 = 8
                }
                
                if isOutsideGalaxy {
                    println("Lt. Uhura reports message from Starfleet Command:")
                    println("  'Permission to attempt crossing of the galactic perimeter")
                    println("  is hereby *DENIED*.  Shut down your engines.'")
                    println("Chief Engineer Scott reports  'Warp engines shut down")
                    println("  at sector \(s1) , \(s2) of quadrant \(q1) , \(q2).")
                    if t > t0 + t9 {
                        missionFailed()
                        return
                    }
                }
                
                if 8 * q1 + q2 == 8 * q4 + q5 {
                    break
                } else {
                    t += 1
                    manueverEnergy()
                    enterQuadrant()
                    return
                }
            } else {
                //Lines 3240-3350
                let s8 = s1 * 24 + s2 * 3 - 26
                if q$.mid(s8, length: 2) != "  " {
                    s1 -= x1
                    s2 -= x2
                    println("Warp engines shut down at sector \(s1) , \(s2) due to bad navigation")
                    break
                }
            }
            i += 1
        }
        
        //Lines 3370-3450
        insertObject(.enterprise, at: (s1, s2))
        manueverEnergy()
        let t8 = w1 < 1 ? 0.1 * Double(Int(10 * w1)) : 1
        t += t8
        if t > t0 + t9 {
            missionFailed()
            return
        }
        
        //3470 REM SEE IF DOCKED, THEN GET COMMAND
        shortRangeSensorScan()
    }
    
    //MARK: REM MANUEVER ENERGY S/R
    //Line 3910
    private func manueverEnergy() {
        e = e - n - 10
        guard e < 0 else { return }
        println("Shield control supplies energy to complete the manuever.")
        s = s + e
        e = 0
        if s < 0 { s = 0 }
    }
    
    //MARK: 3990 REM LONG RANGE SENSOR SCAN CODE
    //Lines 4000-4230
    private func longRangeSensorScan() {
        if d[3] < 0 {
            println("Long range sensors are inoperable")
            return
        }
        
        println("Long range scan for quadrant \(q1), \(q2)")
        let separator = "-------------------"
        println(separator)
        for i in (q1 - 1)...(q1 + 1) {
            var n = [0]  //one indexed array
            for j in (q2 - 1)...(q2 + 1) {
                if i > 0 && i < 9 && j > 0 && j < 9 {
                    n.append(g[(i,j)])
                    z[(i,j)] = g[(i,j)]
                } else {
                    n.append(-1)
                }
            }
            for l in 1...3 {
                print(": ")
                if n[l] < 0 {
                    print("*** ")
                } else {
                    print("\(n[l] + 1000)".right(3) + " ")
                }
            }
            println(":")
            println(separator)
        }
    }
    
    //MARK: 4250 REM PHASER CONTROL CODE BEGINS HERE
    //Lines 4260-4670
    private func phaserControl() {
        if d[4] < 0 {
            println("Phasers inoperative")
            return
        }
        
        if k3 <= 0 {
            println("Science officer Spock reports  'Sensors show no enemy ships")
            println("                                in this quadrant'")
            return
        }
        
        if d[8] < 0 {
            println("Computer failure hampers accuracy")
        }
        
        println("Phasers locked on target;  energy available \(e) units")
        
        var x = e + 1
        repeat {
            if let value = Double(input("Number of units to fire")) {
                x = value
            }
        } while x > e
        if x <= 0 {
            return
        }
        
        e = e - x
        if d[8] < 0 {  //Bug in original, d[7]
            x = x * rnd(1.0)
        }
        
        let h1 = Int(Double(x) / Double (k3))  //Energy divided among Klingon ships
        for i in 1...3 {
            if k[(i,3)] > 0 {
                let h = (Double(h1) / fnd(0)) * (rnd(1.0) + 2)
                if h <= 0.15 * Double(k[(i,3)]) {
                    println("Sensors show no damage to enemy at \(k[(i,1)]) , \(k[(i,2)])")
                } else {
                    k[(i,3)] -= Int(h)
                    println("\(Int(h)) unit hit on Klingon at sector \(k[(i,1)]) , \(k[(i,2)])")
                    if k[(i,3)] <= 0 {
                        println("*** Klingon destroyed ***")
                        k3 -= 1
                        k9 -= 1
                        let coordinate = (k[(i,1)], k[(i,2)])
                        insertObject(.emptySpace, at: coordinate)
                        k[(i,3)] = 0
                        g[(q1,q2)] -= 100
                        z[(q1,q2)] = g[(q1,q2)]
                        guard k9 > 0 else {
                            missionCompleted()
                            return
                        }
                    } else {
                        println("   (Sensors show \(k[(i,3)]) units remaining)")
                    }
                }
            }
        }
        
        klingonAttack()
    }
    
    //MARK: REM PHOTON TORPEDO CODE BEGINS HERE
    //Lines 4700-5490
    private func photonTorpedos() {
        if p <= 0 {
            println("All photon torpedoes expended")
            return
        }
        
        if d[5] < 0 {
            println("Photon tubes are not operational")
            return
        }
        
        //4760
        guard var c1 = Double(input("Photon torpedo course (1-9)")), c1 >= 1 && c1 <= 9 else {
            println("Ensign Chekov reports,  'Incorrect course data, sir!'")
            return
        }
        if c1 == 9 { c1 = 1 }
        
        let x1 = Double(c[(Int(c1),1)]) + Double(c[(Int(c1) + 1,1)] - c[(Int(c1),1)]) * (c1 - Double(Int(c1)))
        let x2 = Double(c[(Int(c1),2)]) + Double(c[(Int(c1) + 1,2)] - c[(Int(c1),2)]) * (c1 - Double(Int(c1)))
        e -= 2
        p -= 1
        var x = Double(s1)
        var y = Double(s2)
        var x3 = Int(round(x))
        var y3 = Int(round(y))
        
        println("Torpedo track:")
        //Line 4920-5050
        repeat {
            x += x1
            y += x2
            x3 = Int(round(x))
            y3 = Int(round(y))
            if x3 < 1 || x3 > 8 || y3 < 1 || y3 > 8 {
                //Line 5490
                println()
                println("Torpedo missed")
                klingonAttack()
                return
            }
            println(tab(16), "\(x3) , \(y3)")
        } while isObject(.emptySpace, at: (x3, y3))  //Line 5050
        
        //Line 5060
        let coordinate = (x3, y3)
        let object = object(at: coordinate)
        switch object {
        case .emptySpace:
            fatalError("Torpedo missed case already handled")
        case .enterprise:
            fatalError("Torpedo cannot hit Enterprise")
        case .klingon:
            //Line 5110
            println("*** Klingon destroyed ***")
            k3 -= 1
            k9 -= 1
            
            guard k9 > 0 else {
                missionCompleted()
                return
            }
            
            for i in 1...3 {
                if x3 == k[(i,1)] && y3 == k[(i,2)] {
                    k[(i,3)] = 0
                }
            }
            insertObject(.emptySpace, at: (x3, y3))
            g[(q1,q2)] = k3 * 1000 + b3 * 10 * s3
            z[(q1,q2)] = g[(q1,q2)]
            
        case .starbase:
            //Line 5330
            println("*** Starbase destroyed ***")
            b3 -= 1
            b9 -= 1
            if b9 > 0 || k9 > Int(t - t0 - t9) {
                println("Starfleet command reviewing your record to consider")
                println("court martial!")
                isDockedAtStarbase = false
                insertObject(.emptySpace, at: coordinate)
                g[(q1,q2)] = k3 * 1000 + b3 * 10 * s3
                z[(q1,q2)] = g[(q1,q2)]
            } else {
                println("That does it captain!!  You are hereby relieved of command")
                println("and sentenced to 99 stardates at hard labor on Cygnus 12!!")
                missionFailed()
                return
            }
        case .star:
            //Line 5260
            println("Star at \(x3) , \(y3) absorbed torpedo energy.")
        }
        
        klingonAttack()
    }
    
    //MARK: 5520 REM SHIELD CONTROL
    //Lines 5530-5660
    private func shieldControl() {
        if d[7] < 0 {
            println("Shield control inoperable")
            return
        }
        
        print("Energy available = \(Int(round(e + s))) ")
        if let x = Double(input("Number of units to shields")) {
            if x < 0 || s == x {
                println("<Shields unchanged>")
                return
            }
            
            if x > e + s {
                println("Shield control reports  'This is not the Federation Treasury'")
                println("<Shields unchanged>")
                return
            }
            
            e = e + s - x
            s = x
            println("Deflector control room report:")
            println("  'Shields now at \(Int(round(s))) units per your command.'")
            return
        } else {
            println("<Shields unchanged>")
            return
        }
    }
    
    //MARK: 5680 REM DAMAGE CONTROL
    //Lines 5690-5980
    private func damageControl() {
        if d[6] < 0 {
            println("Damage control report not available")
        } else {
            printDeviceStatus()
        }
        
        guard isDockedAtStarbase else { return }
        var d3 = 0.0
        for i in 1...8 {
            if d[i] < 0 { d3 += 0.1 }
        }
        if d3 == 0 { return }
        d3 += d4
        if d3 >= 1 { d3 = 0.9 }
        println()
        println("Technicians standing by to effect repairs to our ship")
        println(String(format: "Estimated time to repair: %.2f stardates", d3))
        
        guard input("Will you authorize the repair order (y/n)").isYes else {
            return
        }
        
        for i in 1...8 {
            if d[i] < 0 { d[i] = 0 }
        }
        t += d3 + 0.1
        
        printDeviceStatus()
    }
    
    //Lines 5910-5950
    private func printDeviceStatus() {
        println()
        println("Device             State of repair")
        for r1 in 1...8 {
            let device = deviceName(for: r1)
            let format = d[r1] == 0 ? " %0.f" : " %.2f"
            print(device)
            println(tab(25), String(format: format, d[r1]))
        }
        println()
    }
    
    //MARK: 5990 REM KLINGONS SHOOTING
    //Lines 6000-6200
    private func klingonAttack() {
        guard k3 > 0 else { return }
        if isDockedAtStarbase {
            println("Starbase shields protect the enterprise")
            return
        }
        
        for i in 1...3 {
            if k[(i,3)] > 0 {
                let h = (Double(k[(i,3)]) / fnd(1)) * (2 + rnd(1))
                s -= h
                k[(i,3)] = k[(i,3)] / Int(round(3 + rnd(1)))  //Original code RND(0) - assumed to return random number between 0 and 1
                println("\(Int(h)) unit hit on enterprise from sector \(k[(i,1)]) , \(k[(i,2)])")
                
                guard s > 0 else {
                    println("The Enterprise has been destroyed.  The Federation")
                    println("will be conquered")
                    missionFailed()
                    return
                }
                
                println("      <Shields down to \(Int(s)) units>")
                if h >= 20 {
                    if rnd(1) < 0.6 && h / 2 > 0.02 {
                        let index = fnr(1)
                        d[index] = d[index] - (h / s) - 0.5 * rnd(1)
                        println("Damage control reports " + deviceName(for: index) + " damaged by the hit")
                    }
                }
            }
        }
    }
    
    //MARK: 6210 REM END OF GAME
    //Lines 6220-6360
    private func missionFailed() {
        println("It is stardate " + stardate)
        println("There were \(k9) Klingon battle cruisers left")
        println("at the end of your mission.")
        k9 = 0  //Ends run loop
        println(2)
        if b9 > 0 {
            tryAgain()
        } else {
            end()
        }
    }
        
    //Lines 6310-6360
    private func tryAgain() {
        println("The Federation is in need of a new starship commander")
        println("for a similar mission -- if there is a volunteer,")
        let response = input("let him or her step forward and enter 'aye'").lowercased()
        if response.isEasterEgg, k9 == 0 {
            showEasterEgg(.starTrek)
        }
        
        if response == "aye" {
            run()
        } else {
            end()
        }
    }
    
    //Lines 6370-6400
    private func missionCompleted() {
        println("Congratulation, Captain!  The last Klingon battle cruiser")
        println("menacing the Federation has been destroyed.")
        println()
        println(String(format: "Your efficiency rating is %.3f", 1000 * (Double(k9) * (t - t0))))
        tryAgain()
    }
    
    //MARK: 6420 REM SHORT RANGE SENSOR SCAN AND STARTUP SUBROUTINE
    //Lines 6430-7260
    private func shortRangeSensorScan() {
        isDockedAtStarbase = false
        var c$ = ""  //Condition string
        //Checks to see if enterprise is adjacent to starbase == docked
    loop:
        for i in (s1 - 1)...(s1 + 1) {
            for j in (s2 - 1)...(s2 + 1) {
                if i > 0 && i < 9 && j > 0 && j < 9 {
                    if isObject(.starbase, at: (i,j)) {
                        isDockedAtStarbase = true
                        c$ = "DOCKED"
                        e = e0
                        p = p0
                        println("Shields dropped for docking purposes")
                        s = 0
                        break loop
                    }
                }
            }
        }
        
        if !isDockedAtStarbase {
            c$ = k3 > 0 ? "*RED*" : (e < e0 * 0.1 ? "YELLOW" : "GREEN")
        }
        
        if d[2] < 0 {
            println()
            println("*** Short range sensors are out ***")
            println()
            return
        }
        
        let o1$ = Array(repeating: "-", count: 33).joined(separator: "")
        println(o1$)
        
        let tab1 = 41
        let tab2 = tab1 + "KLINGONS REMAINING".count + 1
        for i in 1...8 {
            for j in stride(from: ((i - 1) * 24 + 1), through: ((i - 1) * 24 + 22), by: 3) {
                print(" " + q$.mid(j, length: 3))
            }
            switch i {
            case 1:
                print(tab(tab1), "STARDATE")
                println(tab(tab2), stardate)
            case 2:
                print(tab(tab1), "CONDITION")
                println(tab(tab2), c$)
            case 3:
                print(tab(tab1), "QUADRANT")
                println(tab(tab2), "\(q1) , \(q2)")
            case 4:
                print(tab(tab1), "SECTOR")
                println(tab(tab2), "\(s1) , \(s2)")
            case 5:
                print(tab(tab1), "PHOTON TORPEDOES")
                println(tab(tab2), "\(p)")
            case 6:
                print(tab(tab1), "TOTAL ENERGY")
                println(tab(tab2), "\(Int(round(e + s)))")
            case 7:
                print(tab(tab1), "SHIELDS")
                println(tab(tab2), "\(Int(round(s)))")
            case 8:
                print(tab(tab1), "KLINGONS REMAINING")
                println(tab(tab2), "\(k9)")
            default:
                fatalError()
            }
        }
        
        println(o1$)
    }
    
    //MARK: 7280 REM LIBRARY COMPUTER CODE
    //Lines 7290-8520
    private func libraryComputer() {
        if d[8] < 0 {
            println("Computer disabled")
            return
        }
        
        var command: ComputerCommand?
        while command == nil {
            let a = Int(input("Computer active and awaiting command")) ?? -1
            if a < 0 { return }
            command = ComputerCommand(rawValue: a)
            if let command = command {
                switch command {
                case .galacticRecord:
                    galacticRecord()
                case .statusReport:
                    statusReport()
                case .photonTorpedoData:
                    photonTorpedoData()
                case .starbaseNavData:
                    starbaseNavData()
                case .directionDistanceCalculator:
                    ddCalculator()
                case .galaxyMap:
                    galacticMap()
                }
            } else {
                println("Functions available from the library-computer:")
                ComputerCommand.allCases.forEach {
                    println(tab(3), " \($0.rawValue) = " + $0.description)
                }
                println()
            }
        }
    }
        
    //MARK: 7390 SETUP TO CHANGE CUM GAL RECORD TO GALAXY MAP
    //Line 7400
    private func galacticMap() {
        println(tab(24), "The Galaxy")
        printGalaxy(isMap: true)
    }
    
    //MARK: 7530 CUM GALACTIC RECORD
    //Lines 7540-7546
    private func galacticRecord() {
        let a$ = input("Do you want a hardcopy? Is the TTY on (y/n)")
        if a$.isYes {
            consoleIO.startHardcopy()
        }
        
        println()
        println("Computer record of galaxy for quadrant \(q1) , \(q2)")
        println()
        printGalaxy()
        
        if a$.isYes {
            consoleIO.printHardcopy()
            consoleIO.endHardcopy()
        }
    }
    
    //Lines 7550-7850
    private func printGalaxy(isMap: Bool = false) {
        println(tab(7), (1...8).map{ String($0) }.joined(separator: "     "))
        let o1$ = "     " + Array(repeating: "-----", count: 8).joined(separator: " ")
        println(o1$)
        for i in 1...8 {
            print(" \(i) ")
            if isMap {
                //Lines 7740-7800
                var name = quadrantName(for: (i, 1), regionOnly: true)
                var j0 = 15 - Int(round(0.5 * Double(name.count)))
                print(tab(j0), name)
                name = quadrantName(for: (i, 5), regionOnly: true)
                j0 = 39 - Int(round(0.5 * Double(name.count)))
                println(tab(j0), name)
                println(o1$)
            } else {
                //Lines 7630-7720
                for j in 1...8 {
                    print("   ")
                    if z[(i,j)] == 0 {
                        print("***")
                    } else {
                        print("\(z[(i,j)] + 1000)".right(3))
                    }
                }
                println()
                println(o1$)
            }
        }
        println()
    }
    
    //MARK: 7890 REM STATUS REPORT
    //Lines 7900-8020
    private func statusReport() {
        println("   Status Report:")
        println("Klingon" + (k9 > 1 ? "s" : "") + ": \(k9)")
        println(String(format: "Mission must be completed in %.1f stardates", t0 + t9 - t))
        if b9 > 0 {
            println("The Federation is maintaining \(b9) starbase" + (b9 > 1 ? "s" : "") + " in the galaxy")
        } else {
            println("Your stupidity has left you on your own in")
            println("  the galaxy -- You have no starbases left!")
        }
        damageControl()
    }
    
    //MARK: 8060 REM TORPEDO, BASE NAV, D/D CALCULATOR
    //Lines 8070-8120
    private func photonTorpedoData() {
        if k3 < 0 {
            println("Science officer Spock reports  'Sensors show no enemy ships")
            println("                                in this quadrant'")
            return
        }
        println("From Enterprise to Klingon battle cruiser" + (k3 > 1 ? "s" : ""))
        for i in 1...3 {
            if k[(i,3)] > 0 {
                let (direction, distance) = directionAndDistance(from: (s1, s2), to: (k[(i,1)], k[(i,2)]))
                println(String(format: "Direction = %.1f", direction))
                println(String(format: "Distance = %.5f", distance))
            }
        }
    }
    
    //Lines 8150-8200
    private func ddCalculator() {
        println("Direction/Distance Calculator")
        println("You are at quadrant \(q1) , \(q2) sector \(s1) , \(s2)")
        println("Please enter")
        let coordinate1 = coordinate(from: input("  Initial coordinates (x,y)"))
        let coordinate2 = coordinate(from: input("  Final coordinates (x,y)"))
        let (direction, distance) = directionAndDistance(from: coordinate1, to: coordinate2)
        println(String(format: "Direction = %.1f", direction))
        println(String(format: "Distance = %.5f", distance))
    }
    
    
    //Lines 8220-8460
    private func directionAndDistance(from coordinate1: Coordinate, to coordinate2: Coordinate) -> (direction: Double, distance: Double) {
        let x1 = Double(coordinate1.x)
        let y1 = Double(coordinate1.y)
        let x2 = Double(coordinate2.x)
        let y2 = Double(coordinate2.y)
        let dy = y2 - y1  //x in original code
        let dx = x1 - x2  //a in original code
        
        let distance = sqrt(dy * dy + dx * dx)
        guard distance > 0 else {
            return (0, 0)
        }
        
        let directionalAngle = dx > 0 ? acos(dy / distance) : 2 * .pi - acos(dy / distance)
        var direction = 1 + 8 * directionalAngle / (2 * .pi)
        if direction == 9 { direction = 1 }
        return (direction, distance)
        
        /*
         //Original method
        var c1 = Double(x1)
         
        //Lines 8290-8330
        var direction8290: Double {
            if abs(dx) <= abs(dy) {
                return c1 + (abs(dx) / abs(dy))
            } else {
                return c1 + (((abs(dx) - abs(dy)) + abs(dx)) / abs(dx))
            }
        }
        
        //Lines 8420-8450
        var direction8420: Double {
            if abs(dx) >= abs(dy) {
                return c1 + (abs(dx) / abs(dy))
            } else {
                return c1 + (((abs(dy) - abs(dx)) + abs(dy))/abs(dy))
            }

        }
        
        let direction: Double
        if dy < 0 {
            if dx > 0 {
                c1 = 3
                direction = direction8420
            } else {
                if dy == 0 {
                    c1 = 7
                    direction = direction8420
                } else {
                    c1 = 5
                    direction = direction8290
                }
            }
        } else {
            if dx < 0 {
                c1 = 7
                direction = direction8420
            } else {
                if dy > 0 {
                    c1 = 1
                    direction = direction8290
                } else {
                    if dx == 0 {
                        c1 = 5
                        direction = direction8290
                    } else {
                        c1 = 1
                        direction = direction8290
                    }
                }
            }
        }
        return (direction, distance)
         */
    }
    
    //Lines 8500-8520
    private func starbaseNavData() {
        if b3 == 0 {
            println("Mr. Spock reports,  'Sensors show no starbases in this quadrant.'")
        } else {
            println("From Enterprise to Starbase:")
            let (direction, distance) = directionAndDistance(from: (s1, s2), to: starbaseCoordinate)
            println(String(format: "Direction = %.1f", direction))
            println(String(format: "Distance = %.5f", distance))
        }
    }
    
    //MARK: 8580 REM FIND EMPTY PLACE IN QUADRANT (FOR THINGS)
    //Lines 8590-8600
    private func emptyLocation() -> Coordinate {
        var x = fnr(1)
        var y = fnr(1)
        while !isObject(.emptySpace, at: (x, y)) {
            x = fnr(1)
            y = fnr(1)
        }
        return (x, y)
    }
    
    //MARK: 8660 REM INSERT IN STRING ARRAY FOR QUADRANT
    //Lines 8670-8700
    private func insertObject(_ object: CoordinateContent, at coordinate: Coordinate) {
        let index = (coordinate.y - 1) * 3 + (coordinate.x - 1) * 24 + 1
        switch index {
        case 1:
            q$ = " " + object.stringValue + q$.right(189)
        case 190:
            q$ = q$.left(189) + object.stringValue
        default:
            q$ = q$.left(index - 1) + object.stringValue + q$.right(190 - index)
        }
    }
    
    //MARK: 8780 REM PRINTS DEVICE NAME
    //Lines 8790-8806
    private func deviceName(for index: Int) -> String {
        switch index {
        case 1: return "Warp Engines"
        case 2: return "Short Range Sensors"
        case 3: return "Long Range Sensors"
        case 4: return "Phaser Control"
        case 5: return "Photon Tubes"
        case 6: return "Damage Control"
        case 7: return "Shield Control"
        case 8: return "Library-Computer"
        default:
            fatalError("Invalid device index")
        }
    }
    
    //MARK: 8820 REM STRING COMPARISON IN QUADRANT ARRAY
    //Lines 8830-8900
    private func isObject(_ object: CoordinateContent, at coordinate: Coordinate) -> Bool {
        let index = (coordinate.y - 1) * 3 + (coordinate.x - 1) * 24 + 1
        return q$.mid(index, length: 3) == object.stringValue
    }
    
    private func object(at coordinate: Coordinate) -> CoordinateContent {
        let index = (coordinate.y - 1) * 3 + (coordinate.x - 1) * 24 + 1
        let string = q$.mid(index, length: 3)
        guard let object = CoordinateContent(rawValue: string) else {
            fatalError("Illegal object string: " + string)
        }
        return object
    }
    
    //MARK: 9010 REM QUADRANT NAME IN G2$ FROM Z4,Z5 (=Q1,Q2)
    //9030-9260
    private func quadrantName(for coordinate: Coordinate, regionOnly: Bool) -> String {
        var name = ""
        if coordinate.y <= 4 {
            switch coordinate.x {
            case 1: name = "Antares"
            case 2: name = "Rigel"
            case 3: name = "Procyon"
            case 4: name = "Vega"
            case 5: name = "Canopus"
            case 6: name = "Altair"
            case 7: name = "Sagittarius"
            case 8: name = "Pollux"
            default:
                fatalError()
            }
        } else {
            switch coordinate.x {
            case 1: name = "Sirius"
            case 2: name = "Deneb"
            case 3: name = "Capella"
            case 4: name = "Betelgeuse"
            case 5: name = "Aldebaran"
            case 6: name = "Regulus"
            case 7: name = "Arcturus"
            case 8: name = "Spica"
            default:
                fatalError()
            }
        }
        
        if regionOnly {
            return name
        } else {
            switch coordinate.y {
            case 1,5: return name + " I"
            case 2,6: return name + " II"
            case 3,7: return name + " III"
            case 4,8: return name + " IV"
            default:
                fatalError()
            }
        }
    }
    
    //MARK: Instructions
    //10 REM INSTRUCTIONS FOR "SUPER STARTREK"  MAR 5, 1978
    func printInstructions() {
        println()
        println(tab(10), "*************************************")
        println(tab(10), "*                                   *")
        println(tab(10), "*                                   *")
        println(tab(10), "*      * * SUPER STAR TREK * *      *")
        println(tab(10), "*                                   *")
        println(tab(10), "*                                   *")
        println(tab(10), "*************************************")
        println(2)
        println("     Instructions for 'Super Star Trek'")
        println()
        println("1.  When you see \\Command ?\\ printed, enter one of the legal")
        println("      commands (NAV,SRS,LRS,PHA,TOR,SHE,DAM,COM, or XXX).")
        println("2.  If you should type in an illegal command, you'll get a short")
        println("      list of the legal commands printed out.")
        println("3.  Some commands require you to enter data (for example, the")
        println("      'NAV' command comes back with 'Course (1-9)?.)  If you")
        println("      type in illegal data (like negative numbers), that command")
        println("      will be aborted.")
        println()
        println("      The galaxy is divided into an 8 x 8 quadrant grid,")
        println("and each quadrant is further divided into an 8 x 8 sector grid.")
        println()
        println("      You will be assigned a starting point somewhere in the")
        println("galaxy to begin a tour of duty as commander of the Starship")
        println("\\Enterprise\\; your mission: to seek and destroy the fleet of")
        println("Klingon warships which are menacing the United Federation of Planets.")
        println()
        println("      You have the following commands available to you as Captain")
        println("of the Starship Enterprise:")
        println()
        println("\\NAV\\ Command = Warp Engine Control --")
        println("      Course is in a circular numerical         4  3  2")
        println("      vector arrangement as shown.               . . . ")
        println("      Integer and real values  may be             ...")
        println("      used.  (Thus course 1.5 is half-        5 ---*--- 1")
        println("      way between 1 and 2.)                       ... ")
        println("                                                 . . .")
        println("      Values may approach 9.0, which            6  7  8")
        println("      itself is equivalent to 1.0.")
        println("                                                Course")
        println("      One warp factor is the size of")
        println("      one quadrant.  Therefore, to get")
        println("      from quadrant 6,5 to 5,5, you would")
        println("      use course 3, warp factor 1.")
        println()
        println("\\SRS\\ Command = Short Range Sensor Scan")
        println("      shows you a scan of your present quadrant.")
        println()
        println("      Symbology on your sensor screen is as follows:")
        println("         <*> = Your starship's position")
        println("         +K+ = Klingon battle cruiser")
        println("         >!< = Federation Starbase (refuel/repair/re-arm here!)")
        println("          *  = Star")
        println()
        println("      A condensed 'status report' will also be presented.")
        println()
        println("\\LRS\\ Command = Long Range Sensor Scan")
        println("      Shows conditions in space for one qudrant on each side")
        println("      of the Enterprise (which is in the middle of the scan).")
        println("      The scan is coded in the form \\***\\ where the units digit")
        println("      is the number of stars, the tens digit is the number of")
        println("      starbases, and the hundreds digit is the number of")
        println("      Klingons.")
        println()
        println("      Example - 207 = 2 Klingons, no starbases, & 7 stars.")
        println()
        println("\\PHA\\ Command = Phaser Control")
        println("      Allows you to destroy the Klingon battle cruisers by")
        println("      zapping them with suitably large units of energy to")
        println("      deplete their shield power.  (Remember Klingons have")
        println("      phasers too!)")
        println()
        println("\\TOR\\ Command = Photon Torpedo Control")
        println("      Torpedo course is the same as used in warp engine control.")
        println("      If you hit the Klingon vessel, he is destroyed and")
        println("      cannot fire back at you.  If you miss, you are subject to")
        println("      his phaser fire.  In either case, you are also subject to")
        println("      the phaser fire of all other Klingons in the quadrant.")
        println()
        println("      The Library-Computer (\\COM\\ command) has an option to")
        println("      compute the torpedo trajectory for you (option 2)")
        println()
        println("\\SHE\\ Command = Shield Control")
        println("      Defines the number of energy units to be assigned to the")
        println("      shields.  Energy is taken from the total ship's energy. Note")
        println("      that the status display total energy includes shield energy.")
        println()
        println("\\DAM\\ Command = Damage Control Report")
        println("      Gives the state of repair of all devices.  Where a negative")
        println("      'state of repair' shows that the device is temporarily")
        println("      damaged.")
        println()
        println("\\COM\\ Command = Library-Computer")
        println("      The Library-Computer contains six options:")
        println("      Option 0 = Cumulative Galactic Record")
        println("         This option shows computer memory of the results of all")
        println("         previous short and long range sensor scans.")
        println("      Option 1 = Status Report")
        println("         This option shows the nubmer of Klingons, Stardates,")
        println("         and Starbases remaining in the game.")
        println("      Option 2 = Photon Torpedo Data")
        println("         Which gives directions and distance from the Enterprise")
        println("         to all Klingons in your quadrant.")
        println("      Option 3 = Starbase Nav Data")
        println("         This option gives direction and distance to any")
        println("         Starbase in your quadrant.")
        println("      Option 4 = Direction/Distance Calculator")
        println("         This option allows you to enter coordinates for")
        println("         direction/distance calculations.")
        println("      Option 5 = Galactic /Region Name/ Map")
        println("         This option prints the names of the sixteen major")
        println("         galactic regions referred to in the game.")
    }
}


