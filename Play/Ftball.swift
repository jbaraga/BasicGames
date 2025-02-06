//
//  Ftball.swift
//  Ftball
//
//  Created by Joseph Baraga on 2/22/22.
//

import Foundation


class Ftball: BasicGame {
    
    private enum Play: Int, CustomStringConvertible {
        case simpleRun = 1
        case trickyRun = 2
        case shortPass = 3
        case longPass = 4
        case punt = 5
        case quickKick = 6
        case placeKick = 7
        
        var description: String {
            switch self {
            case .simpleRun: return "simple run"
            case .trickyRun: return "tricky run"
            case .shortPass: return "short pass"
            case .longPass: return "long pass"
            case .punt: return "punt"
            case .quickKick: return "quick kick"
            case .placeKick: return "place kick"
            }
        }
    }
    
    //Lines 340-385 Strings
    private struct L$ {
        static let kick = "KICK"
        static let receive = "RECEIVE"  //Misspelled in original
        static let yard = "yard "
        static let runback = "run back for "
        static let ballOn = "ball on "
        static let yardLine = "yard line"
        static let loss = " loss "
        static let noGain = " no gain"
        static let gain = "gain "
        static let touchdown = " touchdown"
        static let touchback = " touchback"
        static let safety = "safety***"
        static let junk = "junk"
    }

    private var teams = ["Dartmouth"]  //O$
    private var score = [0, 0]  //S
    private var p = 0  //Current team; 0 = human, 1 = computer
    private var x = 0  //Ball position: 0-100 yards; <0 is team 0 endzone, >100 is team 1 endzone
    private var y = 0  //Yardage for play
    private var d = 1  //Current down
    private var t = 0  //Play count (serves as timer?)
    private var f = 0  //Turnover flag: -1 = turnover, 0 = no turnover
    private var x1 = 0  //Original line of scrimmage at first down
    private var x3 = 0  //Line of scrimmage

    func run() {
        printHeader(title: "Ftball")
        println("This is Dartmouth championship football.")
        println("You will quarterback Dartmouth. Call plays as follows:")
        println(([Play.simpleRun, .trickyRun, .shortPass].map { "\($0.rawValue)" + "= \($0)" }).joined(separator: "; ") + ";")
        println(([Play.longPass, .punt, .quickKick, .placeKick].map { "\($0.rawValue)" + "= \($0)" }).joined(separator: "; ") + ".")
        println()
        teams.append(input("Choose your opponent"))
        
        p = Int(rnd(1) * 2)  //Line 390 coin toss
        println(teams[p] + " won the toss")
        if p == 0 {
            //Lines 470-540
            var a$ = input("Do you elect to kick or receive").uppercased()
            while !(a$ == L$.kick || a$ == L$.receive) {
                a$ = input("Incorrect answer.  Please type 'kick' or 'receive").uppercased()
            }
            if a$ == L$.kick {
                p = 1
            }
        } else {
            //Lines 440-460
            println(teams[1] + " elects to receive")
            println()
        }
        
        x = 40 + (1 - p) * 20 //Line 580

        kickoff()
    }
    
    //Line 410 - returns 1 for team human (p=0), -1 for team computer (p=1)
    private func fnf() -> Int {
        return 1 - 2 * p
    }

    //Line 420 - calculate yardage in correct direction, returns x - x1 for team 0, x1 - x for team 1
    private func fng() -> Int {
        return p * (x1 - x) + (1 - p) * (x - x1)
    }
    
    //Lines 590-710
    private func kickoff() {
        y = Int(200 * pow(rnd(1) - 0.5, 3) + 55) 
        println("\(y)  " + L$.yard + " kickoff")
        x -= fnf() * y
        if abs(x - 50) < 50 {
            returnKick()
        } else {
            //Line 700
            println("Touchback for " + teams[p])
            x = 20 + p * 60
            printPosition()
            firstDown()
        }
    }
    
    //Lines 630-660
    private func returnKick() {
        y = Int(50 * pow(rnd(1), 2)) + (1 - p) * Int(50 * pow(rnd(1), 4))
        x += fnf() * y  //Advance ball for return
        if abs(x - 50) < 50 {
            //Line 651
            println("\(y)  " + L$.yard + " runback")
            printPosition()
            firstDown()
        } else {
            //Line 655 - touchdown
            print(L$.runback)
            touchdown()
        }
    }
    
    //720 REM FIRST DOWN
    private func firstDown() {
        d = 1  //Down
        x1 = x  //Set line of scrimmage for first down
        println("First down " + teams[p] + "***")
        println(2)
        runPlay()
    }
    
    //860 REM NEW PLAY
    private func runPlay() {
        if p == 1 {
            wait(.long)
        }
        
        t += 1
        
        if t >= 50 && rnd(1) < 0.8 {
            //Line 910
            println("End of game***")
            println("Final score:  " + teams[0] + " \(score[0])" + "  " + teams[1] + " \(score[1])")
            if score[0] > score[1] { unlockEasterEgg(.ftball) }
            end()
        }
        
        if t == 30 && rnd(1) < 1 / 3 {
            //1060 REM  JEAN'S SPECIAL
            println("Game delayed.  Dog on field.")
            println()
            wait(.long)
        }
        
        let play = p == 1 ? getOpponentsPlay() : getUserPlay()
        
        f = 0  //Line 1010 - reset fumble
        print("\(play).  ")
        let r = rnd(1) * (0.98 + Double(fnf()) * 0.02)
        switch play {
        case .simpleRun:
            simpleRun(r: r)
        case .trickyRun:
            trickyRun(r: r)
        case .shortPass:
            shortPass(r: r)
        case .longPass:
            longPass(r: r)
        case .punt:
            puntOrKick(r: r)
        case .quickKick:
            puntOrKick(r: r)
        case .placeKick:
            placeKick(r: r)
        }
    }
    
    //800 REM PRINT POSITION
    private func printPosition() {
        if x > 50 {
            //Line 840
            println(L$.ballOn + teams[1] + " \(100 - x) " + L$.yardLine)
        } else {
            //Line 820
            println(L$.ballOn + teams[0] + " \(x) " + L$.yardLine)
        }
    }
    
    //Lines 960-1000
    private func getUserPlay() -> Play {
        guard let play = Play(rawValue: Int(input()) ?? 0) else {
            print("Illegal play number, retype")
            return getUserPlay()
        }
        return play
    }
    
    //1110 REM SIMPLE RUN
    private func simpleRun(r: Double) {
        y = Int(24 * pow(r - 0.5, 3) + 3)
        if rnd(1) < 0.05 {
            fumble()
        } else {
            computeResultOfPlay()
        }
    }
    
    //1150 REM TRICKY RUN
    private func trickyRun(r: Double) {
        y = Int(20 * r - 5)
        if rnd(1) < 0.1 {
            fumble()
        } else {
            computeResultOfPlay()
        }
    }
    
    //Lines 1180-1250 Fumble
    private func fumble() {
        f = -1
        x3 = x
        x = x + fnf() * y
        if abs(x - 50) >= 50 {
            //Line 1240
            println("***Fumble.")
            ballInEndZone()
        } else {
            //Line 1220
            print("***Fumble after ")
            processYardage()
        }
    }
    
    //1260 REM SHORT PASS
    private func shortPass(r: Double) {
        let r1 = rnd(1)
        y = Int(60 * pow(r1 - 0.5, 3) + 10)
        
        if r < 0.05 {
            if d == 4 {
                incompletePass()
            } else {
                interception()
            }
            return
        }
        
        if r < 0.15 {
            //Line 1390
            print ("Passer tackled.  ")
            y = -Int(10 * r1)
            computeResultOfPlay()
            return
        }
        
        if r < 0.55 {
            incompletePass()
            return
        }
        
        print("Complete.  ")
        computeResultOfPlay()
    }
    
    //Lines 1330-1380
    private func interception() {
        println("Intercepted.")
        changeOfPossession()
    }
    
    //Lines 1350-1380
    private func changeOfPossession() {
        f = -1
        x += fnf() * y
        if abs(x - 50) >= 50 {
            ballInEndZone()
        } else {
            //Line 2300
            printPosition()
            p = 1 - p
            firstDown()
        }
    }
    
    //Lines 1420-1470
    private func incompletePass() {
        y = 0
        if rnd(1) < 0.3 {
            print("Batted down.  ")
        } else {
            print("Incomplete.  ")
        }
        computeResultOfPlay()
    }
    
    //1480 REM LONG PASS
    private func longPass(r: Double) {
        let r1 = rnd(1)
        y = Int(160 * pow(r1 - 0.5, 3) + 30)
        
        if r < 0.1 {
            interception()
            return
        }
        
        if r < 0.3 {
            //Line 1540
            print ("Passer tackled.  ")
            y = -Int(15 * r1 + 3)
            computeResultOfPlay()
            return
        }
        
        if r < 0.75 {
            incompletePass()
            return
        }
        
        print("Complete.  ")
        computeResultOfPlay()
    }
        
    //1570 REM PUNT OR KICK
    private func puntOrKick(r: Double) {
        y = Int((100 * pow(r - 0.5, 3) + 35) * (d == 4 ? 1 : 1.3))
        println("\(y) " + L$.yard + "punt")
        if abs(x + y * fnf() - 50) < 50 || d == 4 {
            //Runback punt
            let r1 = rnd(1)
            let y1 = Int(r1 * r1 * 20)
            println("\(y1) " + L$.yard + " run back")
            y -= y1
        }
        changeOfPossession()
    }
    
    //1680 REM PLACE KICK
    private func placeKick(r: Double) {
        y = Int(100 * pow(r - 0.5, 3) + 35)
        let r1 = rnd(1)
        
        if r1 < 0.15 {
            println("Kick is blocked***")
            x = x - 5 * fnf()
            p = 1 - p
            firstDown()
            return
        }
        
        x = x + fnf() * y
        if abs(x - 50) < 60 {
            println("Kick is short.")
            if abs(x - 50) < 50 {
                p = 1 - p
                returnKick()
            } else {
                touchback()
            }
            return
        }
        
        if r1 < 0.5 {
            println("Kick is off to the side.")
            touchback()
        } else {
            println("Field Goal***")
            score[p] += 3
            showScoreAndKickoff()
        }
    }
    
    //1870 REM OPPONENT'S PLAY
    private func getOpponentsPlay() -> Play {
        let z: Int
        switch d {
        case 1:
            z = rnd(1) > 1/3 ? 1 : 3
        case 2, 3:
            //TODO: verify correct
            if 10 + x - x1 < 5 || x < 5 {
                z = rnd(1) > 1/3 ? 1 : 3
            } else {
                if x <= 10 {
                    z = 2 + Int(2 * rnd(1))
                } else {
                    if x > x1 {
                        if d < 3 || x < 45 {
                            z = 2 + Int(2 * rnd(1)) * 2
                        } else {
                            z = rnd(1) > 1/4 ? 4 : 6
                        }
                    } else {
                        z = 2 + Int(2 * rnd(1)) * 2
                    }
                }
            }
        case 4:
            if x > 30 {
                z = 5
            } else {
                if 10 + x - x1 < 3 || x < 3 {
                    z = rnd(1) > 1/3 ? 1 : 3
                } else {
                    z = 7
                }
            }
        default:
            fatalError("Invalid down")
        }
        
        guard let play = Play(rawValue: z) else {
            fatalError("Invalid play number")
        }
        return play
    }
    
    //2190 REM GAIN OR LOSS
    private func computeResultOfPlay() {
        x3 = x
        x += fnf() * y
        if abs(x - 50) >= 50 {
            ballInEndZone()
        } else {
            processYardage()
        }
    }
    
    //Lines 2230-2440
    private func processYardage() {
        if y != 0 {
            print("\(abs(y)) " + L$.yard)
        }
        switch sgn(y) {
        case -1: println(L$.loss)
        case 0: println(L$.noGain)
        case 1: println(L$.gain)
        default:
            fatalError("sgn out of bounds")
        }
        
        if abs(x3 - 50) <= 40 && rnd(1) < 0.1 {
            penalty()
        }
        
        printPosition()
        
        if f < 0 {  //Turnover
            //Line 2340
            p = 1 - p
            firstDown()
            return
        }
        
        if fng() >= 10 {  //Gained first down
            firstDown()
            return
        }
        
        if d == 4 {
            //Turnover on downs
            p = 1 - p
            firstDown()
            return
        }
        
        d += 1
        print("Down \(d)     ")
        if (x1 - 50) * fnf() < 40 {
            println("yards to go: \(10 - fng())")
        } else {
            println("goal to go")
        }
        println(2)
        runPlay()
    }
    
    //2450 REM BALL IN END-ZONE
    private func ballInEndZone() {
        let e = x < 100 ? 0 : 1
        switch 1 + e - f * 2 + p * 4 {  //ON _ GOTO starts at 1
        case 1, 6:
            //2510 REM SAFETY
            score[1-p] += 2
            println(L$.safety)
            printScore()
            println(teams[p] + " kicks off from its 20 yard line.")
            x = 20 + p * 60
            p = 1 - p
            kickoff()
        case 2, 5:
            //2590 REM OFFENSIVE TD
            touchdown()
        case 3, 8:
            //2760 REM DEFENSIVE TD
            println(L$.touchdown + " for " + teams[1-p] + "***")
            p = 1 - p
            touchdown()
        case 4, 7:
            //2710 REM TOUCHBACK
            println(L$.touchback)
            p = 1 - p
            x = 20 + p * 60
            firstDown()
        default:
            fatalError("Invalid integer for ball in end zone")
        }
    }
    
    //Lines 2600-2700
    private func touchdown() {
        println(L$.touchdown + "***")
        if rnd(1) > 0.8 {
            //Line 2680
            println("Kick is off to the side")
            score[p] += 6
        } else {
            //Line 2620
            println("Kick is good")
            score[p] += 7
        }
        showScoreAndKickoff()
    }
    
    //Lines 2640-2670
    private func showScoreAndKickoff() {
        printScore()
        println(teams[p] + " kicks off")
        p = 1 - p
        x = 40 + (1 - p) * 20  //Line 580
        kickoff()
    }
    
    //2710 REM TOUCHBACK
    private func touchback() {
        println(L$.touchback)
        p = 1 - p
        x = 20 + p * 60
        firstDown()
    }
    
    //2800 REM SCORE
    private func printScore() {
        println()
        println("Score:   \(score[0]) to \(score[1])")
        println(2)
    }
    
    //2860 REM PENALTY
    private func penalty() {
        let p3 = Int(2 * rnd(1))
        println(teams[p3] + " offsides -- penalty of 5 yards.")
        println(2)
        
        if p3 == 0 {
            //2980 REM OPPONENT'S STRATEGY ON PENALTY
            if p == 1 {
                //Line 3040
            } else {
                if y <= 0 || f < 0 || fng() < 3 * d - 2 {
                    println("Penalty refused.")
                    return
                }
                println("Penalty accepted.")
            }
        } else {
            //Line 2920
            var a$ = input("Do you accept the penalty")
            while !(a$.isYes || a$.isNo) {
                a$ = input("Type 'yes' or 'no'")
            }
            if a$.isNo { return }
        }
        
        //Penalty accepted
        f = 0
        d -= 1
        if p == p3 {  //Logic to determine where to move the ball to assess the penalty
            x = x3 - fnf() * 5
        } else {
            x = x3 + fnf() * 5
        }
    }
}
