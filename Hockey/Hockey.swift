//
//  Hockey.swift
//  Hockey
//
//  Created by Joseph Baraga on 1/20/23.
//

import Foundation

class Hockey: GameProtocol {
    
    private enum TeamID {
        case a  //A$
        case b  //B4
    }
    
    private class Team {
        let id: TeamID
        let name: String  //A$(7) or B$(7)
        private let _players: [String]  //players[0-5] = A$((1-6) or B$(1-6)
        
        var shots = 0  //S2 for team A, S3 for team B
        var goals = 0  //H(9) for team A, H(8) for team B
        
        private var goalsByPlayer = [Int: Int]() //T
        private var assistsByPlayer = [Int: Int]()  //T1

        init(id: TeamID, name: String, players: [String]) {
            self.id = id
            self.name = name
            self._players = players
        }
        
        var players: [String] { _players }
        
        //Positions, as defined in instructions
        var leftWing: String { player(1) }
        var center: String { player(2) }
        var rightWing: String { player(3) }
        var leftDefense: String { player(4) }
        var rightDefense: String { player(5) }
        var goalie: String { player(6) }
        
        //Converts from zero indexed array players to one indexed arrays A$/B$
        func player(_ index: Int) -> String {
            return _players[index - 1]
        }
        
        //Lines 1040-1150
        //Player indices g, g1, g2 are for 1-indexed arrays A$, B$
        func goalScored(byPlayer g: Int, assistedBy g1: Int, assistedBy g2: Int) -> String {
            goals += 1
            goalsByPlayer[g] = (goalsByPlayer[g] ?? 0) + 1
            var string = "Goal scored by: \(player(g))"
            if g1 > 0 {
                assistsByPlayer[g1] = (assistsByPlayer[g1] ?? 0) + 1
                string += " assisted by: \(player(g1))"
            }
            if g2 > 0 {
                assistsByPlayer[g2] = (assistsByPlayer[g2] ?? 0) + 1
                string += " and \(player(g2))"
            }
            if g1 == 0 && g2 == 0 {
                string += " unassisted"
            }
            
            return string
        }
        
        func goals(byPlayer index: Int) -> Int {
            return goalsByPlayer[index] ?? 0
        }
        
        func assists(byPlayer index: Int) -> Int {
            return assistsByPlayer[index] ?? 0
        }
    }
    
    func run() {
        printHeader(title: "Hockey")
        println(3)
        //10 REM ROBERT PUOPOLO ALG. 1 140 MCCOWAN 6/7/73 HOCKEY
        println(3)
        promptForInstructions()
        playGame()
    }
    
    private func playGame() {
        let (teamA, teamB, duration) = getTeamsAndDuration()
        let referee = input("Input the referee for this game")  //R$
        println()
        
        [teamA, teamB].forEach { team in
            println(tab(10), "\(team.name) Starting Lineup")
            team.players.forEach { println($0) }
            println()
        }
        
        //Line 220
        println("We're ready for tonights opening face-off")
        println("\(referee) will drop the puck between \(teamA.center) and \(teamB.center)")
        wait(.short)
        var time = 1  //L
        repeat {
            let c = Int(2 * rnd(1)) + 1
            let oTeam = c == 1 ? teamA : teamB
            let dTeam = c == 1 ? teamB: teamA
            println("\(oTeam.name) has control" + (c == 1 ? " of the puck" : ""))
            
            let (numberOfPasses, h) = getPassPlay()  //H - array of players involved in p
            let shooterIndex: Int  //G
            let firstAssistIndex: Int  //G1
            let secondAssistIndex: Int  //G2
            let z: Int  //Z - lower z = higher chance of score
            if numberOfPasses > 0 {
                let playResult = runPassPlay(oTeam: oTeam, dTeam: dTeam, numberOfPasses: numberOfPasses, players: h)
                shooterIndex = playResult.g
                firstAssistIndex = playResult.g1
                secondAssistIndex = playResult.g2
                z = takeShot(playerIndex: shooterIndex, team: oTeam, z1: playResult.z1)
            } else {
                shooterIndex = h[h.count-1]
                firstAssistIndex = 0
                secondAssistIndex = 0
                z = takeShot(playerIndex: shooterIndex, team: oTeam)
            }
            
            let area = getArea()
            let a1 = Int(rnd(1) * 4) + 1
            oTeam.shots += 1  //Lines 910-920
            let isGoalScored = area == a1 ? shotOnGoal(oTeam: oTeam, dTeam: dTeam, z: z) : false
            var isPlayStopped = false
            
            if isGoalScored {
                //Line 960-1020 - score
                consoleIO.ringBell()
                wait(.short)
                println((oTeam.id == .a ? "Goal " : "Score ") + oTeam.name)
                let scoringReport = oTeam.goalScored(byPlayer: shooterIndex, assistedBy: firstAssistIndex, assistedBy: secondAssistIndex)
                println()
                if teamA.goals < teamB.goals {
                    println("Score: \(teamB.name): \(teamB.goals)", " \(teamA.name): \(teamA.goals)")
                } else {
                    println("Score: \(teamA.name): \(teamA.goals)", " \(teamB.name): \(teamB.goals)")
                }
                println(scoringReport)
                isPlayStopped = true
            } else {
                isPlayStopped = save(oTeam: oTeam, dTeam: dTeam, shooterIndex: shooterIndex)
            }
            
            //Faceoff if stop in play
            if isPlayStopped {
                time += 1
                wait(.short)
                if time <= duration {
                    println("And we're ready for the face-off")
                }
            }
        } while time <= duration
        
        //Line 1540
        consoleIO.ringBell(2)
        wait(.short)
        println("That's the siren")
        println()
        println(tab(15), "Final Score:")
        if teamA.goals < teamB.goals {
            println("\(teamB.name): \(teamB.goals)", "\(teamA.name): \(teamA.goals)")
        } else {
            println("\(teamA.name): \(teamA.goals)", "\(teamB.name): \(teamB.goals)")
        }
        println()
        println(tab(10), "Scoring Summary")
        println()
        
        [teamA, teamB].forEach { team in
            println(tab(25), team.name)
            print(tab(5), "Name")
            print(tab(20), "Goals")
            println(tab(35), "Assists")
            print(tab(5), "----")
            print(tab(20), "-----")
            println(tab(35), "------")
            for index in 1...5 {
                print(tab(5), team.player(index))
                print(tab(21), "\(team.goals(byPlayer: index))")
                println(tab(36), "\(team.assists(byPlayer: index))")
            }
            println()
        }
        
        println("Shots On Net")
        println("\(teamA.name): \(teamA.shots)")
        println("\(teamB.name): \(teamB.shots)")

        wait(.long)
        showEasterEgg(.hockey)
        end()
    }
    
    //Lines 100-160
    private func getTeamsAndDuration() -> (Team, Team, Int) {
        let (nameA, nameB) = getTeamNames()  //A$(7), B$(7)
        println()
        let duration = getGameDuration()  //T6
        
        println("Would the \(nameA) coach enter his team")
        println()
        var playersA = [String]()  //A$, zero indexed
        while playersA.count < 6 {
            playersA.append(input("Player \(playersA.count + 1)"))
        }
        println()
        println("Would the \(nameB) coach do the same")
        println()
        var playersB = [String]()  //B$, zero indexed
        while playersB.count < 6 {
            playersB.append(input("Player \(playersB.count + 1)"))
        }
        println()
        
        return (Team(id: .a, name: nameA, players: playersA), Team(id: .b, name: nameB, players: playersB), duration)
    }
    
    //Line 100 - added correction for invalid entry
    private func getTeamNames() -> (String, String) {
        let string = input("Enter the two teams")
        let components = ((string.components(separatedBy: ",")).map { $0.trimmingCharacters(in: .whitespaces)}).filter { !$0.isEmpty }
        switch components.count {
        case 0: return ("DEC", "IBM")
        case 1: return (components[0], "IBM")
        default: return (components[0], components[1])
        }
    }
    
    //Lines 110-120
    private func getGameDuration() -> Int {
        guard let t6 = Int(input("Enter the number of minutes in a game")), t6 > 1 else {
            println()
            return getGameDuration()
        }
        println()
        return t6
    }
    
    //Lines 290-305 - return array (h) of player indices involved in passes.
    private func getPassPlay() -> (p: Int, h: [Int]) {
        guard let p = Int(input("Pass")), p >= 0, p < 4 else {
            return getPassPlay()
        }

        //Bug in original logic - if no passes, H is array of 2 uniqued, randomized player indices. If more than 0 passes, H is array of length passes + 2 of randomized player indices, with last 3 elements uniqued
        //If p = 3, 4 players are involved in play: 4th player H(J-4) can be a duplicate and can result in pass between same player
        //Bug fix - return randomized array of 5 players
        let h = (Array(1...5).shuffled())
        return (p, h)
    }
    
    //Lines 490-760
    private func runPassPlay(oTeam: Team, dTeam: Team, numberOfPasses p: Int, players h: [Int]) -> (g: Int, g1: Int, g2: Int, z1: Int) {
        let isTeamA = oTeam.id == .a
        let j = h.count
        switch p {
        case 1:
            let g = isTeamA ? h[j-1] : h[j-2]
            let g1 = isTeamA ? h[j-2] : h[j-1]
            let g2 = 0
            if isTeamA {
                //Lines 510-530
                println("\(oTeam.player(g1)) leads \(oTeam.player(g)) with a perfect pass")
                println("\(oTeam.player(g)) cutting in!!!")
            } else {
                //Lines 650-660
                println("\(oTeam.player(g1)) hits \(oTeam.player(g)) flying down the leftside")
            }
            return (g, g1, g2, 3)
        case 2:
            let g = h[j-3]
            let g1 = h[j-1]
            let g2 = h[j-2]
            if isTeamA {
                //Lines 540-560
                println("\(oTeam.player(g2)) gives to a streaking \(oTeam.player(g1))")
                println("\(oTeam.player(g)) comes down on \(dTeam.rightDefense) and \(dTeam.leftDefense)")
            } else {
                //Lines 670-710
                println("It's a ' 3 on 2 '")
                println("Only \(dTeam.leftDefense) and \(dTeam.rightDefense) are back")
                println("\(oTeam.player(g2)) gives off to \(oTeam.player(g1))")
                println("\(oTeam.player(g1)) drops to \(oTeam.player(g))")
            }
            return (g, g1, g2, 2)
        case 3:
            let g = isTeamA ? h[j-4] : h[j-3]
            let g1 = h[j-1]
            let g2 = h[j-2]
            if isTeamA {
                //Lines 570-630
                println("Oh my god!! A ' 4 on 2 ' situation")
                println("\(oTeam.player(h[j-3])) leads \(oTeam.player(g2))")
                println("\(oTeam.player(g2)) is wheeling through center")
                println("\(oTeam.player(g2)) gives and goes with \(oTeam.player(g1))")
                println("Pretty passing")
                println("\(oTeam.player(g1)) drops it to \(oTeam.player(g))")
            } else {
                //Lines 720-760
                println("A ' 3 on 2 ' with a ' trailer '")
                println("\(oTeam.player(h[j-4])) gives to \(oTeam.player(g2)) who shuffles it off to")
                println("\(oTeam.player(g1)) who fires a wing to wing pass to ")
                println("\(oTeam.player(g)) as he cuts in alone!!")
            }
            return (g, g1, g2, 1)
        default:
            fatalError("p (\(p)) out of range.")
        }
    }
    
    //Lines 360-480 - shot after no passes, returns z which influences probability of goal
    private func takeShot(playerIndex: Int, team: Team) -> Int {
        guard let s = Int(input("Shot")) else {
            return takeShot(playerIndex: playerIndex, team: team)
        }
        print(team.player(playerIndex))
        switch s {
        case 1:
            println(" let's a boomer go from the red line!!")
            return 10
        case 2:
            //Bug in original code, line 430 missing
            //Z assumed to equal case 4, consistent with relative Z values for shot after passes (line 830/870)
            println(" flips a wristshot down the ice")
            return 17
        case 3:
            println(" backhands one in on the goaltender")
            return 25
        case 4:
            println(" snaps a long flip shot")
            return 17
        default:
            return takeShot(playerIndex: playerIndex, team: team)
        }
    }
    
    //Lines 770-880
    private func takeShot(playerIndex: Int, team: Team, z1: Int) -> Int {
        guard let s = Int(input("Shot")) else {
            return takeShot(playerIndex: playerIndex, team: team)
        }
        print(team.player(playerIndex))
        switch s {
        case 1:
            println(" let's a big slap shot go!!")
            return 4 + z1
        case 2:
            println(" rips a wrist shot off")
            return 2 + z1
        case 3:
            println(" gets a backhand off")
            return 3 + z1
        case 4:
            println(" snaps off a snap shot")
            return 2 + z1
        default:
            return takeShot(playerIndex: playerIndex, team: team)
        }
    }
    
    //Lines 890-895
    private func getArea() -> Int {
        guard let a = Int(input("Area")), a > 0, a < 5 else {
            return getArea()
        }
        return a
    }
    
    //Lines 940-1190 - returns true if goal scored
    private func shotOnGoal(oTeam: Team, dTeam: Team, z: Int) -> Bool {
        //Line 940
        let h20 = Int(100 * rnd(1)) + 1
        if h20 % z == 0 {
            //Line 1160 - Goalie save and rebound
            let a2 = Int(100 * rnd(1)) + 1
            if a2 % 4 == 0 {
                println("Save \(dTeam.goalie) " + (oTeam.id == .a ? " Rebound" : " Follow up"))
                return shotOnGoal(oTeam: oTeam, dTeam: dTeam, z: z)
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    //Lines 1200-1540 - no score, returns true if play stops
    private func save(oTeam: Team, dTeam: Team, shooterIndex g: Int) -> Bool {
        let isTeamA = oTeam.id == .a
        let s1 = Int(6 * rnd(1)) + 1
        switch s1 {
        case 1:
            if isTeamA {
                println("Kick save and beauty by \(dTeam.goalie)")
                println("Cleared out by \(dTeam.rightWing)")
            } else {
                println("Stick save by \(dTeam.goalie)")
                println("and cleared out by \(dTeam.leftDefense)")
            }
            return false
        case 2:
            if isTeamA {
                println("What a spectacular glove save by \(dTeam.goalie)")
                println("and \(dTeam.goalie) golfs it into the crowd")
            } else {
                println("Oh my god!! \(oTeam.player(g)) rattles one off the post")
                println("to the right of \(dTeam.goalie) and \(dTeam.goalie) covers on the loose puck!")
            }
            return true
        case 3:
            if isTeamA {
                println("Skate save on a low steamer by \(dTeam.goalie)")
                return false
            } else {
                println("Skate save by \(dTeam.goalie)")
                println("\(dTeam.goalie) whacks the loose puck into the stands")
                return true
            }
        case 4:
            if isTeamA {
                println("Pad save by \(dTeam.goalie) off the stick")
                println("of \(oTeam.player(g)) and \(dTeam.goalie) covers up")
                return true
            } else {
                println("Stick save by \(dTeam.goalie) and he clears it out himself")
                return false
            }
        case 5:
            if isTeamA {
                println("Whistles one over the head of \(dTeam.goalie)")
            } else {
                println("Kicked out be \(dTeam.goalie)")
                println("and it rebounds all the way to center ice")
            }
            return false
        case 6:
            if isTeamA {
                println("\(dTeam.goalie) makes a face save!! And he is hurt")
                println("The defenseman \(dTeam.rightDefense) covers up for him")
            } else {
                println("Glove save by \(dTeam.goalie) and he hangs on")
            }
            return true
        default:
            fatalError("s1 (\(s1)) out of range")
        }
    }
    
    private func promptForInstructions() {
        let response = Response(input("Would you like the instructions"))
        switch response {
        case .yes:
            break
        case .no:
            return
        default:
            println("Answer yes or no!!")
            promptForInstructions()
            return
        }
        
        //Lines 1720-1940
        println()
        println("This is a simulated hockey game.")
        println("Question     Response")
        println("Pass         Type in the number of passes you would")
        println("             like to make, from 0 to 3.")
        println("Shot         Type the number corresponding to the shot")
        println("             you want to make.  Enter:")
        println("             1 for a slapshot")
        println("             2 for a wristshot")
        println("             3 for a backhand")
        println("             4 for a snap shot")
        println("Area         Type in the number corresponding to")
        println("             the area you are aiming at.  Enter:")
        println("             1 for upper left hand corner")
        println("             2 for upper right hand corner")
        println("             3 for lower left hand corner")
        println("             4 for lower right hand corner")
        println()
        println("At the start of the game, you will be asked for the names")
        println("of your players.  They are entered in the order: ")
        println("left wing, center, right wing, left defense,")
        println("right defense, goalkeeper.  Any other input required will")
        println("have explanatory instructions.")
    }
}
