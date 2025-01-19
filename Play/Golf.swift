//
//  Golf.swift
//  play
//
//  Created by Joseph Baraga on 1/4/25.
//

import Foundation

class Golf: GameProtocol {
    //TODO: Play complete round
    private var score = 0  //G2
    private var cumulativePar = 0 //G3
    private var handicap = 0  //H
    private var weakness = Weakness.unknown
    
    private enum Weakness: Int {
        case hook = 0, slice, distance, unknown, trapShots, putting
    }
    
    //400-590
    private enum Area: Int, CustomStringConvertible {
        case teeOff = 0, fairway, rough, trees, adjacentFairway, trap, water, outOfBounds, green, hole
        
        var description: String {
            switch self {
            case .teeOff: return "tee off"
            case .fairway: return "fairway"
            case .rough: return "Rough"
            case .trees: return "Trees"
            case .adjacentFairway: return "adjacent fairway"
            case .trap: return "trap"
            case .water: return "into water"
            case .outOfBounds: return "out of bounds"
            case .green: return "green"
            case .hole: return "hole"
            }
        }
    }
    
    private typealias BallLocation = Area
    
    private struct Hole: CustomStringConvertible {
        let number: Int  //F - 1
        let distance: Int
        let par: Int
        let rightHazard: Area  //L(1)
        let leftHazard: Area  //L(2)
        
        var description: String { "Hole \(number) Distance \(distance) yards, Par \(par)" }
        
        static var course: [Hole] {
            //1700-1708
            let holeData = [
                361,4,4,2,389,4,3,3,206,3,4,2,500,5,7,2,
                408,4,2,4,359,4,6,4,424,4,4,2,388,4,4,4,
                196,3,7,2,400,4,7,2,560,5,7,2,132,3,2,2,
                357,4,4,4,294,4,2,4,475,5,2,3,375,4,4,2,
                180,3,6,2,550,5,6,6
            ]

            return (0...17).compactMap {
                let offset = $0 * 4
                guard let rightHazard = Area(rawValue: holeData[offset + 2]), let leftHazard = Area(rawValue: holeData[offset + 3]) else { return nil }
                return Hole(number: $0+1, distance: holeData[offset], par: holeData[offset + 1], rightHazard: rightHazard, leftHazard: leftHazard)
            }
        }
    }
    
    private struct HoleProgress {
        var shotNumber = 0  //S1
        var distanceToHole: Double  //D
        var ballLocation = Area.teeOff  //L(0)
        
        var trapProbability = 0.8  //N - /probability of not getting out of trap if weakness == trapShot - 80%, decreases by 20% with each dub
        var treeEncounters = 0  //Q
        var penaltyAssessed = false  //J
        
        var locationAndDistance: (location: BallLocation, distance: Double) {
            get { (ballLocation, distanceToHole) }
            set { (ballLocation, distanceToHole) = newValue }
        }
        
        mutating func nextShot() { shotNumber += 1 }
        
        mutating func incrementTreeEncounters() { treeEncounters += 1}
        
        //Distance in yards, if not specified randomized by handicap per line 1300 (d2), converted to yards
        mutating func onGreen(distance: Double? = nil, handicap: Int) {
            let h = Double(handicap)
            let d = distance ?? (1 + (3 * floor(80 / (40 - h) * Double.random(in: 0..<1)))) / 3
            ballLocation = .green
            distanceToHole = d
        }
    }
    
    
    func run() {
        printHeader(title: "Golf")
        println("Welcome to the Creative Computing Country Club,")
        println("an eighteen hole championship layout, located a short")
        println("distance from scenic downtown Morristown.  The")
        println("commentator will explain the game as you play.")
        println("Enjoy your game; see you at the 19th hole...")
        println(2)
        wait(.short)
        
        play()
        unlockEasterEgg(.golf)
        end()
    }
    
    private func play() {
        var holes = Hole.course
        handicap = getHandicap()  //H
        weakness = getWeakness()  //T
        println()
        
        while let hole = holes.first {
            //1590-1690
            holes.removeFirst()
            println()
            println("You are at tee off " + hole.description)
            cumulativePar += hole.par
            println("On your right is " + hole.rightHazard.description)
            println("On your left is " + hole.leftHazard.description)
            
            //170-260
            var progress = HoleProgress(distanceToHole: Double(hole.distance))
            
            //620-700 - only print this once
            if score == 0 {
                println("Selection of clubs")
                println("Yardage Desired", tab(38), "Suggested Clubs")
                println("200 to 280 yards", tab(43), "1 to 4")
                println("100 to 200 yards", tab(42), "19 to 13")
                println("  0 to 100 yards", tab(42), "29 to 23")
            }
            
            repeat {
                var (club, w) = selectClubAndSwing(for: progress.ballLocation)  //C - club value, W - fraction of full swing
                progress.nextShot()
                
                if club > 13 {  //742
                    if progress.ballLocation == .trap {
                        if weakness == .trapShots, rnd() < progress.trapProbability {  //1280, 1320
                            progress.trapProbability *= 0.2
                            println("Shot dubbed, still in trap.")
                        } else {
                            progress.onGreen(handicap: handicap) //1300
                        }
                    } else {
                        if club > 14 { club -= 10 }  //990-1000
                        if progress.shotNumber > 7, progress.distanceToHole < 200 {  //760, 867
                            progress.onGreen(handicap: handicap)
                        } else {
                            let d1 = shotDistance(for: club, effort: w)  //770
                            progress = shotResult(hole: hole, shotDistance: d1, currentState: progress)
                        }
                    }
                } else {
                    let s2 = Double(hole.number)  //S2 = hole number? also F-1?
                    let q = Double(progress.treeEncounters)
                    let h = Double(handicap)
                    if hole.number % 3 == 0, s2 + q + 10 * s2 / 18 < s2 * (72 + (h + 1) / 0.85) / 18 {  //746, 952
                        progress.incrementTreeEncounters()  //956
                        if progress.shotNumber % 2 > 0 && progress.distanceToHole >= 95 {
                            progress.locationAndDistance = (.rough, progress.distanceToHole - 75)  //set to .rough - omitted from original code
                            println("Ball hit tree - bounced into rough \(Int(progress.distanceToHole)) yards from hole.")  //1012
                        } else {
                            println("You dubbed it.")  //862
                            progress = shotResult(hole: hole, shotDistance: 35, currentState: progress)
                        }
                    } else {
                        if club < 4 && progress.ballLocation == .rough {  //752, 756
                            println("You dubbed it.")
                            progress = shotResult(hole: hole, shotDistance: 35, currentState: progress)
                        } else {
                            if progress.shotNumber > 7, progress.distanceToHole < 200 {  //760, 867
                                progress.onGreen(handicap: handicap)
                            } else {
                                let d1 = shotDistance(for: club, effort: w)  //770
                                progress = shotResult(hole: hole, shotDistance: d1, currentState: progress)
                            }
                        }
                    }
                }
                
                if progress.ballLocation == .teeOff { progress.ballLocation = .fairway }  //330, 1150
                
                switch progress.ballLocation {
                case .green:
                    progress.shotNumber += putt(from: progress.distanceToHole, shotNumber: progress.shotNumber, par: hole.par)
                    progress.ballLocation = .hole
                default:
                    break
                }
            } while progress.ballLocation != .hole
            
            let shots = progress.shotNumber
            println("Your score on hole \(hole.number) was \(shots)")  //290
            
            //1750-1765
            score += shots
            println("Total par for \(hole.number) holes is \(cumulativePar)   Your total is \(score)")
            
            //292-310
            if hole.number < 18 {
                if shots > hole.par + 2 {
                    println("Keep your head down.")
                } else if shots == hole.par {
                    println("A par.  Nice going.")
                } else if shots == hole.par - 1 {
                    print("A birdie.")
                } else if shots == hole.par - 2 {
                    if hole.par == 3 {
                        println("A hole in one.")
                    } else {
                        println("A great big eagle.")
                    }
                }
                println()
            }
        }
    }
    
    private func getHandicap() -> Int {
        guard let h = Int(input("What is your handicap")), h > -1 && h < 31 else {
            println("PGA rules handicap = 0 to 30")  //470
            return getHandicap()
        }
        return h
    }
    
    private func getWeakness() -> Weakness {
        println("Difficulties at golf include:")
        println("0=hook, 1=slice, 2=poor distance, 4=trap shots, 5=putting")
        guard let t = Weakness(rawValue: Int(input("Which one (only one) is your worst")) ?? -1) else {
            return getWeakness()
        }
        return t
    }
    
    //629-730
    private func selectClubAndSwing(for ballLocation: BallLocation) -> (Int, Double) {
        let allowedClubs = [1...4, 12...29].reduce(into: [Int]()) { $0 += $1 }  //By line 710-730,650 club 12 if allowed if L(0) <= 5
        if var c = Int(input("What club do you choose")), allowedClubs.contains(c) {
            println()
            //640-665, 710-730
            if c >= 12 { c -= 6 }  //Line 720: club 12-19 -> 6-13; 23-29 -> 17-23
            
            //Line 650 condition: ball is playable, not in water or out of bounds **this condition should always be true, as ballLocation is always reset to fairway after in water or out of bounds per line 1240; lines 660,665 c conditions don't make sense and should never be executed
            let w = c > 13 ? getSwingEffort() : 1
            if w <= 1  { return (c, w) }
        }
        
        println()
        println("That club is not in the bag.")
        println()
        return selectClubAndSwing(for: ballLocation)

    }
    
    //960-970
    private func getSwingEffort() -> Double {
        println("You may now gauge your distance by percent (1 to 100)")
        guard let w = Double(input("Percent full swing")), w >= 0, w <= 100 else {
            println()
            return 2
        }
        println()
        return w / 100
    }
    
    //830-
    private func shotResult(hole: Hole, shotDistance d1: Double, currentState: HoleProgress) -> HoleProgress {
        let d = currentState.distanceToHole
        let o = offlineDistance(for: d1)
        let d2 = distanceToHole(shotDistance: d1, offlineDistance: o, startingDistance: d)  //New distance after shot
        var newState = currentState
        
        if d - d1 < 0, d2 >= 20 {
            println("Too much club.  You're past the hole.")
        }
        
        if d2 > 27 {
            //1020-1094
            if o < 30 || currentState.penaltyAssessed {
                //1150
                newState.ballLocation = .fairway
            } else {
                if (hole.number + 1) % 15 == 0, weakness == .slice {
                    print("You hooked- ")
                    newState.ballLocation = hole.leftHazard
                } else {
                    print("You sliced- ")
                    newState.ballLocation = hole.rightHazard
                }
                if o > 45 { println("badly.") }
            }
            newState.distanceToHole = d2
        } else if d2 > 20 {
            //1100
            newState.locationAndDistance = (.trap, d2)
        } else if d2 > 0.5 {
            newState.locationAndDistance = (.green, d2)
            return newState
        } else {
            println("You holed it.")
            newState.locationAndDistance = (.hole, 0)
            return newState
        }
        
        //1190-1270
        switch newState.ballLocation {
        case .outOfBounds, .water:
            println("Your shot went \(newState.ballLocation)")
            println("Penalty stroke assessed.  Hit from previous location.")
            newState.penaltyAssessed = true
            newState.ballLocation = .fairway
        default:
            println("Shot went \(Int(d1)) yards.  It's \(Int(d2)) yards from the cup.")
            println("Ball is \(Int(o)) yards off line... in \(newState.ballLocation)")
        }
        
        return newState
    }
    
    //770-800, 1170-1180
    private func shotDistance(for club: Int, effort: Double) -> Double {
        let c = Double(club)
        let h = Double(handicap)
        var d1 = floor(((30-h)*2.5+187-((30-h)*0.25+15)*c/2)+25*rnd())
        d1 = floor(d1 * effort * (weakness == .distance ? 0.85 : 1))  //online shot distance
        return d1
    }
    
    private func offlineDistance(for d1: Double) -> Double {
        let h = Double(handicap)
        let o = rnd()/0.8*(2*h+16)*abs(tan(d1*0.0035))
        return o
    }
    
    private func distanceToHole(shotDistance d1: Double, offlineDistance o: Double, startingDistance d: Double) -> Double {
        return floor(sqrt(o * o + pow(d - d1, 2)))
    }
    
    //1380-1580 - returns total number of puts; distance is in yards
    private func putt(from distance: Double, shotNumber: Int, par: Int) -> Int {
        let h = Double(handicap)
        let p = Double(par)
        var d2 = distance * 3  //convert to feet
        
        var putts = 0  //K - limits to 4 putt
        
        repeat {
            println("On green \(Int(d2)) feet from the pin.")
            println("Choose your putt distance potency number 1 to 13.")
            let i = Double(input("Putt potency number")) ?? 1
            putts += 1
            let s1 = Double(shotNumber + putts)
            
            if s1 - p > h * 0.072 + 2 || putts > 3 {
                d2 = 0
            } else {
                if weakness == .putting {  //1430 bug? weakness trap t == 4 ; putting t == 5
                    d2 = d2 - i * (4 + rnd()) + 1  //1530
                } else {
                    d2 = d2 - i * (4 + 2 * rnd()) + 1.5  //1440
                }
                
                if d2 < -2 {
                    println("Passed by the cup.")
                    d2 = -d2
                } else if d2 > 2 {
                    println("Putt short.")
                }
                d2 = Double(Int(d2))
            }
            
        } while abs(d2) >= 2
        
        println("You holed it.")
        println()
        return putts
    }
}
