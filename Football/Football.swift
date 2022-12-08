//
//  Football.swift
//  Football
//
//  Created by Joseph Baraga on 2/22/22.
//

import Foundation


class Football: GameProtocol {
    
    private enum Play: Int, CaseIterable {
        case pitchout = 1
        case tripleReverse = 2
        case draw = 3
        case qbSneak = 4
        case endAround = 5
        case doubleReverse = 6
        case leftSweep = 7
        case rightSweep = 8
        case offTackle = 9
        case wishboneOption = 10
        case flarePass = 11
        case screenPass = 12
        case rollOutOption = 13
        case rightCurl = 14
        case leftCurl = 15
        case wishboneOption2 = 16
        case sidelinePass = 17
        case halfbackOption = 18
        case razzleDazzle = 19
        case bomb = 20
        
        var stringValue: String {
            switch self {
            case .pitchout: return "Pitchout"
            case .tripleReverse: return "Triple Reverse"
            case .draw: return "Draw"
            case .qbSneak: return "QB Sneak"
            case .endAround: return "End Around"
            case .doubleReverse: return "Double Reverse"
            case .leftSweep: return "Left Sweep"
            case .rightSweep: return "Right Sweep"
            case .offTackle: return "Off Tackle"
            case .wishboneOption: return "Wishbone Option"
            case .flarePass: return "Flare Pass"
            case .screenPass: return "Screen Pass"
            case .rollOutOption: return "Roll Out Option"
            case .rightCurl: return "Right Curl"
            case .leftCurl: return "Left Curl"
            case .wishboneOption2: return "Wishbone Option"
            case .sidelinePass: return "Sideline Pass"
            case .halfbackOption: return "Half-back Option"
            case .razzleDazzle: return "Razzle-Dazzle"
            case .bomb: return "Bomb!!!!"
            }
        }
        
        static func -(lhs: Play, rhs: Play) -> Int {
            return lhs.rawValue - rhs.rawValue
        }
    }
    
    enum Team: Int {
        case one = 1
        case two = 2
        
        var stringValue: String {
            switch self {
            case .one: return "Team 1"
            case .two: return "Team 2"
            }
        }
        
        //Lines 690-720
        var d: Int {  //For printing of ball location
            switch self {
            case .one: return 0
            case .two: return 3
            }
        }
        
        var t: Int {
            switch self {
            case .one: return 2
            case .two: return 1
            }
        }

        var w: Int {  //For yardage calculations
            switch self {
            case .one: return -1
            case .two: return 1
            }
        }
        
        var x: Int {  //Goal line for scoring
            switch self {
            case .one: return 100
            case .two: return 0
            }
        }

        var y: Int {
            switch self {
            case .one: return 1
            case .two: return -1
            }
        }

        var z: Int {  //Goal line for team - used to determine if ball in own endzone
            switch self {
            case .one: return 0
            case .two: return 100
            }
        }

        var m$: String {
            switch self {
            case .one: return "--->"
            case .two: return "<---"
            }
        }
        
        var otherTeam: Team {
            switch self {
            case .one: return .two
            case .two: return .one
            }
        }
        
        mutating func swap() {
            self = otherTeam
        }
    }
    
    private var team = Team.one  //Current team with ball or receiving ball
    private var p = 0  //Yard line of ball
    private var d = 1  //Down
    private var maximumPoints = 0  //E
    private var pointsByTeam = [Team.one: 0, Team.two: 0]  //H(1), H(2)
    
    //Lines 330,350 are embedded in Play enum using rawValue
    
    //Lines 370, 1770-1780 - replace with randomized array
    private let plays1 = Play.allCases.shuffled()  //Team 1
    private let plays2 = Play.allCases.shuffled()  //Team 2
    
    func run() {
        printHeader(title: "Football")
        println(3)
        println("Presenting N.F.U. Football (No Fortran Used)")
        println(2)
        let response = input("Do you want instructions")
        if response.isEasterEgg {
            showEasterEgg("Football")
        }
        if response.isYes {
            showInstructions()
        }
        
        println()
        maximumPoints = Int(input("Please input score limit on game")) ?? 30
        
        printPlaycard()
        
        println()
        printField()
        println("Team 1 defends 0 yd goal -- Team 2 defends 100 yd goal.")
        println()
        
        //Line 740
        team = Int(2 * rnd(1) + 1) == 1 ? .one : .two  //Receives kickoff
        println("The coin is flipped")
        kickOff()
    }
    
    //Lines 410-660
    private func printPlaycard() {
        consoleIO.startHardcopy()
        println("Team 1 play chart")
        println("No." + tab(6) + "Play")
        for (index, play) in plays1.enumerated() {
            printTab(" \(index + 1)", tab: 6)
            println(play.stringValue)
        }
        println(13)
        println("Tear off here" + String(repeating: "-", count: 46))
        println("\u{2029}")  //Page feed (doesn't work)
        println("Team 2 play chart")
        println("No." + tab(6) + "Play")
        for (index, play) in plays2.enumerated(){
            printTab(" \(index + 1)", tab: 6)
            println(play.stringValue)
        }
        println(11)
        println("Tear off here" + String(repeating: "-", count: 46))
        println()
        consoleIO.endHardcopy()
        if input("Do you want a hardcopy").isYes {
            consoleIO.printHardcopy()
        }

    }
    
    //Lines 765-780
    private func kickOff() {
        p = team.x - team.y * 40
        printDivider()
        println()
        println(team.stringValue + " receives kick-off")
        let k = Int(26 * rnd(1) + 40)
        receiveBall(k: k)
    }
    
    //Lines 790-810  Receive ball after kickoff/punt of k yards
    private func receiveBall(k: Int) {
        //Line 790
        p = p - team.y * k
        
        //Line 794 - the line may be jumped to after unsuccessful field goal, if team.y * p >= team.x + 10
        if team.w * p < team.z + 10 {
            //Line 810
            println("Ball went \(k) yards.  Now on \(p)")
            printBallLocationOnField()
            fieldBall()
        } else {
            println()
            println("Ball went out of endzone --automatic touchback--")
            p = team.z - team.w * 20
            firstDown()
        }
    }
    
    //Lines 830-870
    private func fieldBall() {
        let response = input(team.stringValue + " do you want to runback")
        if response.isYes {
            returnBall()
        } else {
            if !(team.w * p < team.z) {
                p = team.z - team.w * 20
            }
            firstDown()
        }
    }
    
    //Lines 880-1170 New series of downs
    private func firstDown() {
        d = 1
        let s = p  //Line of scrimmage on first down
        var c = 0
        
        while d < 5 {
            wait(.short)
            println(String(repeating: "=", count: 68))
            println(team.stringValue + " Down \(d) on \(p)")
            
            if d == 1 {
                c = team.y * (p + team.y * 10) < team.x ? 4 : 8
            }
            
            if c == 8 {
                println(tab(27) + "\(team.x - team.y * p) yards")
            } else {
                println(tab(27) + "\(10 - team.y * (p - s)) yards to 1st down")
            }
            
            printBallLocationOnField()  //Line 910

            
            if d == 4 {
                if puntOrFieldGoal() {
                    return
                }
            }
            
            if let plays = getPlay() {
                //p1 = team1 play, p2 = team 2 play; must sync with offense/defense
                let p1 = team == .one ? plays.offense : plays.defense
                let p2 = team == .one ? plays.defense : plays.offense
                let y = Int(abs(Double(p1.rawValue - p2.rawValue)) / 19 * (Double(team.x - team.y * p + 25) * rnd(1) - 15))
                println()
        
                //Lines 1010 - determine if run or pass, based on team on offense
                let isRunPlay = team == .one ? p1.rawValue < 11 : p2.rawValue < 11
                if isRunPlay {
                    //Line 1048
                    println("The ball was run")
                    advanceBall(yards: y, s: s)
                } else {
                    let u = Int(4 * rnd(1) - 1) //Line 930 - changed 3 to 4 to increase odds of completion
                    //Line 1020
                    if u == 0 {
                        println("Pass incomplete " + team.stringValue)
                        advanceBall(yards: 0, s: s)
                    } else {
                        if rnd(1) > 0.5 || y <= 2 {  //Original code has rnd(1) > 0.025 - means QB scrambled most plays. Changed to 0.5 o/w almost no pass completions
                            println("Quarterback scrambled")
                        } else {
                            println("Pass completed")
                        }
                        advanceBall(yards: y, s: s)
                    }
                }

                //Line 1140
                d += 1 //Line 1160 Fallthrough - next down
            }
        }
        
        //Lines 1160-1170 4th down fallthrough
        println()
        println("Conversion unsuccessful " + team.stringValue)
        team.swap()
        println()
        printDivider()
        firstDown()
    }
    
    //Lines 1050-1070
    private func advanceBall(yards y: Int, s: Int) {
        p = p - team.w * y
        println()
        println("Net yards gained on down \(d) are \(y)")
        if rnd(1) < 0.025 {
            fumble()
            return
        }
        
        if team.y * p >= team.x {
            touchdown()
            return
        }
        
        if team.w * p >= team.z {
            safety()
            return
        }
        
        if team.y * p - team.y * s >= 10 {
            firstDown()
        }
        
        //Fallthrough to next down
    }
    
    //Lines 920-995
    private func getPlay() -> (offense: Play, defense: Play)? {
        let oplays = team == .one ? plays1 : plays2
        let dplays = team == .one ? plays2 : plays1
        let response = input("Input offensive play, defensive play")
        let values = response.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard values.count == 2, let index1 = values.first, let index2 = values.last else {
            println("Illegal play number, check and")
            return getPlay()
        }
        
        switch (index1, index2) {
        case _ where index1 > 0 && index1 <= oplays.count && index2 > 0 && index2 <= dplays.count:
            return (oplays[index1 - 1], dplays[index2 - 1])
        case (77, 77):
            return puntOrFieldGoal() ? nil : getPlay()
        case (99, 99):
            printScore()
            return getPlay()
        default:
            println("Illegal play number, check and")
            return getPlay()
        }
    }
    
    //Lines 1080-1100
    private func fumble() {
        println()
        println("** Loss of possession from " + team.stringValue + " to " + team.otherTeam.stringValue)
        printDivider()
        team.swap()
        fieldBall()
    }
    
    //Lines 1180-1195
    private func puntOrFieldGoal() -> Bool {
        let response = input("Does " + team.stringValue + " want to punt")
        switch response {
        case _ where response.isYes:
            punt()
            return true
        case _ where response.isNo:
            return fieldGoal()
        default:
            return puntOrFieldGoal()
        }
    }
    
    //Lines 1190-1195
    private func punt() {
        println()
        println(team.stringValue + " will punt")
        if rnd(1) < 0.025 {
            fumble()
            return
        }
        
        //Line 1195 Punt
        println()
        printDivider()
        let k = Int(25 * rnd(1) + 35)
        team.swap()
        receiveBall(k: k)
    }
    
    //Lines 1200-1271, 1640-1750
    private func fieldGoal() -> Bool {
        let response = input("Does " + team.stringValue + " want to attempt a field goal")
        switch response {
        case _ where response.isYes:
            //Line 1640
            println()
            println(team.stringValue + " will attempt a field goal")
            if rnd(1) < 0.025 {
                fumble()
                return true
            }
            
            //Line 1650 Field goal
            let f = Int(35 * rnd(1) + 20)  //Length of kick
            println()
            println("Kick is \(f) yards long")
            p = p - team.w * f
            let g = rnd(1)
            if g < 0.35 || team.y * p < team.x {
                //Line 1735 - unsuccessful
                if g < 0.35 {
                    println("Ball went wide")
                }
                println("Field goal unsuccessful " + team.stringValue + String(repeating: "-", count: 17) + "Too bad")
                println()
                printDivider()
                
                //Original code lines 1742-1750 allows return of missed field goal if kicked to p > 110 by team 1 or p < 10 by team 2 - does not make sense.
                if team.y * p < team.x + 10 {
                    println()
                    println("Ball now on \(p)")
                    team.swap()
                    printBallLocationOnField()
                    fieldBall()
                } else {
                    team.swap()
                    receiveBall(k: Int(26 * rnd(1) + 40)) //k is not set here, so makes no sense to receiveBall?
                }
            } else {
                //Line 1710 - successful
                println("Field goal good for " + team.stringValue + String(repeating: "*", count: 21) + "Yea")
                recordScore(3)
            }
            return true
        case _ where response.isNo:
            return false
        default:
            return fieldGoal()
        }
    }
    
    //Lines 1230-1290
    private func safety() {
        println()
        println("Safety against " + team.stringValue + String(repeating: "*", count: 21) + "Oh-oh")
        pointsByTeam[team.otherTeam] = (pointsByTeam[team.otherTeam] ?? 0) + 2
        printScore()
        let response = input(team.stringValue + " do you want to punt instead of kickoff")
        p = team.z - team.w * 20
        if response.isYes {
            punt()
        } else {
            //Bug in original at line 1290 - falls through to touchdown
            team.swap()
            kickOff()
        }
    }
    
    //Lines 1320-1380
    private func touchdown() {
        println()
        println("Touchdown by " + team.stringValue + String(repeating: "*", count: 21) + "Yea team")
        let q = rnd(1) > 0.1 ? 7 : 6
        println(q == 7 ? "Extra point good" : "Extra point no good")
        recordScore(q)
    }
    
    //Lines 1390-1420  Tallies and prints score, then initiates kickOff
    private func recordScore(_ points: Int) {
        pointsByTeam[team] = (pointsByTeam[team] ?? 0) + points
        printScore()
        team.swap()
        kickOff()
    }
    
    //Lines 1430-1510
    private func returnBall() {
        let k = Int(9 * rnd() + 1)
        let r = Int((Double(team.x - team.y * p + 25) * rnd(1) - 15) / Double(k))
        p = p - team.w * r
        println()
        println("Runback " + team.stringValue + " \(r) yards")
        
        if rnd(1) < 0.025 {
            fumble()
            return
        }
        
        if team.y * p >= team.x {
            touchdown()
            return
        }
        
        if team.w * p >= team.z {
            safety()
            return
        }
        
        firstDown()
    }
    
    //Lines 1810-1835
    private func printScore() {
        guard let score1 = pointsByTeam[.one], let score2 = pointsByTeam[.two] else {
            fatalError("Missing score")
        }
        println()
        println(Team.one.stringValue + " score is \(score1)")
        println(Team.two.stringValue + " score is \(score2)")
        
        if let score = pointsByTeam[team], score >= maximumPoints {
            println(team.stringValue + " WINS" + String(repeating: "*", count: 20))
            wait(.long)
            end()
        }
    }
    
    //Lines 1860-1870
    private func printDivider() {
        println(String(repeating: "+", count: 68))
    }
    
    //Line 1900
    private func printBallLocationOnField() {
        println(tab(team.d + 5 + p / 2) + team.m$)  //
        printField()
    }
    
    //Lines 1910-1930
    private func printField() {
        println("Team 1 [" + (stride(from: 0, through: 100, by: 10).map { String($0 )}).joined(separator: "   ") + "] Team 2")
        println()
    }
    
    //Lines 170-280
    private func showInstructions() {
        println("This is a game for two teams in which players must")
        println("prepare a tape with a data statement (1770 for team 1,")
        println("1780 for team 2) in which each team scrambles nos. 1-20.")
        println("These numbers are then assigned to 20 given plays.")
        println("A list of nos. and their plays are provided with")
        println("both teams having the same plays.  The more similar the")
        println("plays the less yardage gained.  Scores are given")
        println("whenever scores are made.  Scores may also be obtained")
        println("by inputting 99,99 for play nos.  To punt or attempt a")
        println("field goal, input 77,77 for play nos. Questions will be")
        println("asked then.  On 4th down you will also be asked whether")
        println("you want to punt or attempt a field goal.  If the answer to")
        println("both questions is no it will be assumed you want to")
        println("try and gain yardage.  Answer all questions yes or no.")
        println("The game is played until players terminate (control-c).")
        println("please prepare a tape and run.")
        println()
        let response = input("Hit enter to run", terminator: "")
        if response.isEasterEgg {
            showEasterEgg("Football")
            end()
        }
    }
}
