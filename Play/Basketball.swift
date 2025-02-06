//
//  Basketball.swift
//  play
//
//  Created by Joseph Baraga on 2/4/25.
//

import Foundation

class Basketball: BasicGame {
    
    private enum Shot: Int {
        case changeDefense, longJumper, shortJumper, layUp, setShot
        
        //For computer shot, from line 3020
        //Computer shots are jump shot (.longJumper), layUp and setShot; layUp and setShot give same result except for name
        init(z1: Double) {
            if z1 > 3 {
                self = .setShot
            } else if z1 > 2 {
                self = .layUp
            } else {
                self = .longJumper
            }
        }
    }
    
    private enum Defense: Double {
        case press = 6, man = 6.5, zone = 7, none = 7.5
    }
    
    private enum GameState {
        case firstHalf, secondHalf, overtime, end
    }
    
    private struct Team: CustomStringConvertible {
        var name = "Dartmouth"
        var score = 0
        var defense = Defense.none  //D  only set for user
        
        var description: String { name }
    }
    
    private enum TeamOnOffense {
        case user, computer
    }
    
    private let regulationTime = 100
    private var halfTime: Int { regulationTime / 2 }
    private var twoMinutesLeftTime: Int { Int(0.92 * Double(regulationTime)) }
    
    private var time = 0
    private var gameState: GameState = .firstHalf
    
    func run() {
        printHeader(title: "Basketball")
        println("This is Darmouth College Basketball.  You will be Dartmouth")
        println("  captain and playmaker.  Call shots as follows:  1. Long")
        println("  (30 ft.) jump shot; 2. Short (15 ft.) jump shot; 3. Lay")
        println("  up; 4. Set shot.")
        println("Both teams will use the same defense.  Call defense as")
        println("follows:  6. Press; 6.5 Man-to man; 7. Zone; 7.5 None")
        println("  To change defense, just type  0  as your next shot.")
        play()
        end()
    }
    
    private func play() {
        var user = Team()
        user.defense = getDefense(prompt: "Your starting defense will be")  //D - program flow changed for invalid response, o/w lines 79-420 skipped
        println()
        let name = input("Choose your opponent")  //O$
        var computer = Team(name: name)
        var teamOnOffense = tipOff(computer: computer)  //p
        
        //370
        repeat {
            switch teamOnOffense {
            case .user:
                println()  //425  //TODO: conditionally print - move to end? so it does not print after rebound
                let shot = getShot()
                if rnd() > 0.5 && time >= regulationTime {
                    //490-500
                    println()
                    if user.score == computer.score {
                        println("   ***** End of second half *****")
                        println("Score at end of regulation time:")
                        println("        Dartmouth \(user.score) \(computer) \(computer.score)")
                        println("Begin two minute overtime period")
                        time = twoMinutesLeftTime + 1
                        gameState = .overtime
                        teamOnOffense = tipOff(computer: computer)
                    } else {
                        gameState = .end
                    }
                } else {
                    (user, computer, teamOnOffense) = userShot(shot: shot, user: user, computer: computer)
                    if time == regulationTime / 2 {
                        gameState = .secondHalf
                    }
                }

            case .computer:
                time += 1  //3000
                if time == halfTime {
                    teamOnOffense = endOfFirstHalf(user: user, computer: computer)
                    gameState = .secondHalf
                } else {
                    if time == twoMinutesLeftTime { twoMinuteWarning() }  //3015 GOSUB 600 - never executed. Bug fix added
                    println()  //3018
                    let z1 = 2.5 * rnd() + 1
                    let shot = Shot(z1: z1)
                    (user, computer, teamOnOffense) = computerShot(shot: shot, user: user, computer: computer)
                }
            }
            
        } while gameState != .end
        
        println("   ***** End of Game *****")
        println("Final score: Dartmouth \(user.score) \(computer) \(computer.score)")
        if user.score > computer.score { unlockEasterEgg(.basketball) }
    }
    
    private func getDefense(prompt: String = "Your new defensive alignment is") -> Defense {
        guard let rawValue = Double(input(prompt)), let defense = Defense(rawValue: rawValue) else {
            return getDefense()
        }
        return defense
    }
    
    private func getShot() -> Shot {
        guard let rawValue = Int(input("Your shot")), let shot = Shot(rawValue: rawValue) else {
            println("Incorrect answer.  Retype it.")
            return getShot()
        }
        return shot
    }
    
    private func tipOff(computer: Team) -> TeamOnOffense {
        println("Center jump")
        if rnd() > 0.6 {
            println("Dartmouth controls the tap.")
            return .user
            //425
        } else {
            println("\(computer) controls the tap.")
            return .computer
            //3000
        }
    }
    
    //1000-1250
    //Called recursively after missed jump shot if user controls rebound and does not pass
    private func userShot(shot: Shot, user: Team, computer: Team) -> (user: Team, computer: Team, teamOnOffense: TeamOnOffense) {
        time += 1
        if time == halfTime {
            return (user, computer, endOfFirstHalf(user: user, computer: computer))
        }
        
        if time == twoMinutesLeftTime { twoMinuteWarning() }
        
        let defense = user.defense
        var user = user
        var computer = computer
        switch shot {
        case .longJumper, .shortJumper:
            println("Jump shot")  //1050
            if rnd() > 0.341 * defense.rawValue / 8 {
                if rnd() > 0.628 * defense.rawValue / 8 {
                    if rnd() > 0.782 * defense.rawValue / 8 {  //1200
                        if rnd() > 0.843 * defense.rawValue / 8 {
                            println("Charging foul.  Dartmouth loses ball.")  //1270
                            return (user, computer, .computer)
                        } else {
                            println("Shooter is fouled.  Two shots.")  //1255
                            user.score += shootFreeThrows()
                            printScore(user: user, computer: computer)
                            return (user, computer, .computer)
                        }
                    } else {
                        //1210
                        let team: TeamOnOffense = rnd() > 0.5 ? .computer : .user
                        print("Shot is blocked.  Ball controlled by " + (team == .computer ? computer.description : "Dartmouth"))
                        if team == .computer { println() }
                        return(user, computer, team)
                    }
                } else {
                    println("Shot is off target.")  //1100
                    //Rebound
                    if defense.rawValue / 6 * rnd() > 0.45 {
                        println("Rebound to \(computer)")
                        return (user, computer, .computer)
                    } else {
                        println("Dartmouth controls the rebound.")  //1100
                        if rnd() > 0.4 {
                            if defense == .press, rnd() > 0.6 {
                                println("Pass stolen by \(computer) easy layup.")  //5120
                                computer.score += 2
                                printScore(user: user, computer: computer)
                                return (user, computer, .user)
                            }
                            
                            print("Ball passed back to you. ")
                            return (user, computer, .user)  //go back to 430
                        } else {
                            //1300 second shot lay up
                            return userShot(shot: .layUp, user: user, computer: computer)
                        }
                    }
                }
            } else {
                println("Shot is good.")
                user.score += 2
                printScore(user: user, computer: computer)
                return (user, computer, .computer)
            }
        case .setShot, .layUp:
            //1310-2040
            println(shot == .layUp ? "Lay up." : "Set shot.")
            if 7 / defense.rawValue * rnd() > 0.4 {
                if 7 / defense.rawValue * rnd() > 0.7 {
                    //1500
                    if 7 / defense.rawValue * rnd() > 0.875 {
                        //1600
                        if 7 / defense.rawValue * rnd() > 0.925 {
                            println("Charging foul.  Dartmouth loses the ball.")
                        } else {
                            println("Shot blocked. \(computer)'s ball.")  //1610
                        }
                        return (user, computer, .computer)
                    } else {
                        println("Shooter fouled.  Two shots.")  //1510
                        user.score += shootFreeThrows()
                        printScore(user: user, computer: computer)
                        return (user, computer, .computer)
                    }
                } else {
                    println("Shot is off the rim.")
                    if rnd() > 2 / 3 {
                        println("Dartmouth controls the rebound.")  //1415
                        if rnd() > 0.4 {
                            print("Ball passed back to you. ")  //1440
                            return (user, computer, .user)
                        } else {
                            return userShot(shot: shot, user: user, computer: computer)  //1430 GOTO 1300
                        }
                    } else {
                        println("\(computer) controls the rebound.")  //1390
                        return (user, computer, .computer)
                    }
                }
            } else {
                println("Shot is good.  Two points.")  //1340
                user.score += 2
                printScore(user: user, computer: computer)
                return (user, computer, .computer)
            }
            
        case .changeDefense:
            user.defense = getDefense()
            return (user, computer, .user)
        }
    }
    
    //3030-3090
    //Called recursively after missed shot if computer controls rebound and does not pass
    private func computerShot(shot: Shot, user: Team, computer: Team) -> (user: Team, computer: Team, teamOnOffense: TeamOnOffense) {
        let defense = user.defense
        var computer = computer
        
        let isShotGood: Bool
        switch shot {
        case .longJumper:
            println("Jump shot.")
            isShotGood = 8 / defense.rawValue * rnd() <= 0.35  //3050
        default:
            println(shot == .layUp ? "Lay up." : "Set shot.")
            isShotGood = 7 / defense.rawValue * rnd() <= 0.413  //3520
        }
        
        if isShotGood {
            println("Shot is good.")
            computer.score += 2
            printScore(user: user, computer: computer)
            return (user, computer, .user)
        } else {
            if shot == .longJumper, 8 / defense.rawValue * rnd() > 0.75 {
                //3200 foul
                if 8 / defense.rawValue * rnd() > 0.9 {
                    println("Offensive foul.  Dartmouth's ball.")
                } else {
                    println("Player fouled.  Two shots.")
                    computer.score += shootFreeThrows()
                    printScore(user: user, computer: computer)
                }
                return (user, computer, .user)
            } else {
                println(shot == .longJumper ? "Shot is off the rim." : "Shot is missed.")
                return rebound(shot: shot, defense: defense, user: user, computer: computer)
            }
        }
    }
    
    //3110-3175
    private func rebound(shot: Shot, defense: Defense, user: Team, computer: Team) -> (user: Team, computer: Team, teamOnOffense: TeamOnOffense) {
        if defense.rawValue / 6 * rnd() > 0.5 {
            println("Dartmouth controls the rebound.")
            return (user, computer, .user)
        }
        
        println("\(computer) controls the rebound.")
        
        if defense == .press, rnd() > 0.75 {  //3160, 5000
            println("Ball stolen.  Easy lay up for Dartmouth.")  //5010
            var user = user
            user.score += 2
            printScore(user: user, computer: computer)
            return (user, computer, .computer)
        }
        
        if rnd() > 0.5 {
            //3175 -> 3500 - recursively goes back to shot with current shot, but only lay up or set shot, jump shot not repeated after rebound
            let secondShot: Shot = shot == .longJumper ? .setShot : shot
            return computerShot(shot: secondShot, user: user, computer: computer)
        } else {
            println("Pass back to \(computer) guard.")  //3168
            return (user, computer, .computer)
        }
    }
    
    //4000-4110
    private func shootFreeThrows() -> Int {
        //4000 REM FOUL SHOOTING
        if rnd() > 0.49 {
            if rnd() > 0.75 {
                println("Both shots missed.")
                return 0
            } else {
                println("Shooter makes one shot and misses one.")
                return 1
            }
        } else {
            println("Shooter makes both shots.")
            return 2
        }
    }
    
    //600-630
    private func twoMinuteWarning() {
        println()
        println("   *** Two Minutes Left in the Game ***")
        println()
    }
    
    //6010-6020
    private func printScore(user: Team, computer: Team) {
        println("Score:  \(user.score) to \(computer.score)")
    }
    
    //8000-8020
    private func endOfFirstHalf(user: Team, computer: Team) -> TeamOnOffense {
        println("   ***** End of First Half *****")
        println("Score: Dartmouth \(user.score) \(computer) \(computer.score)")
        println(2)
        return tipOff(computer: computer)
    }
}
