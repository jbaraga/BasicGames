//
//  Bowling.swift
//  Bowling
//
//  Created by Joseph Baraga on 1/8/24.
//

import Foundation

class Bowling: GameProtocol {
    
    func run() {
        printHeader(title: "Bowling")
        println()
        
        println("Welcome to the Alley")
        println("Bring your friends")
        println("Okay let's first get acquainted")
        println()
        
        if Response(input("The instructions (y/n)")).isYes {
            println("The game of bowling takes mind and skill.During the game")
            println("The computer will keep score.You may compete with")
            println("other players[up to four].You will be playing ten frames")
            println("On the pin diagram 'O' means the pin is down...'+' means the")
            println("the pin is standing.After the game the computer will show your")
            println("scores .")
            wait(.short)
        }
        
        guard let numberOfPlayers = Int(input("First of all...how many are playing")), numberOfPlayers > 0 && numberOfPlayers < 5 else {
            end()
        }
        println()
        println("Very good...")
        bowl(numberOfPlayers)

    }
    
    //2520 REMARK BALL GENERATOR USING MOD '15' SYSTEM
    //Lines 2070-7200
    private func bowl(_ numberOfPlayers: Int) {
        var frameNumber = 1
        var a = dim(50, 4, value: 0)  //old score A one indexed; row is frame # * player #, column: 1 = ball 1 pins down, 2 = ball 2 pins down (cumulative), 3 = frame result. Bug - multiple players scoring incorrect, additional player scores will overwrite other players as score is indexed by player * frame
        var score = Array(repeating: [Int: Frame](), count: numberOfPlayers)  //New accurate scoring = array of scores by frame, zero indexed
        
        while frameNumber < 11 {
            for player in 1...numberOfPlayers {
                var pinState = Array(repeating: 0, count: 16)  //C() - one indexed; 0 = pin standing, 1 = pin down
                var ball = 1  //B
                var previousPinsDown = 0  //M
                var frameResult = 0  //Q frame result - 0: not finished, 1: pins left standing (Error), 2: Spare, 3: Strike
                
                while frameResult == 0 {
                    var pinsDown = 0  //D

                    //2520 REMARK BALL GENERATOR USING MOD '15' SYSTEM
                    println("Type roll to get the ball going.")
                    let _ = input()
                    
                    (1...20).forEach { _ in
                        let x = Int(100 * rnd(1))
                        for j in 1...10 {
                            if x < 15 * j {
                                pinState[15 * j - x] = 1
                                break
                            }
                        }
                    }
                    
                    //3510 REM PIN DIAGRAM
                    var k = 0
                    println("Player: \(player) Frame: \(frameNumber) Ball: \(ball)")
                    for i in 0...3 {
                        println()
                        for _ in 1...(4 - i) {
                            k += 1
                            print(tab(i), pinState[k] == 1 ? "O " : "+ ")
                            //4680 REMARK ROLL ANALYSIS
                            pinsDown += pinState[k]
                        }
                    }
                    println()
                    
                    if pinsDown - previousPinsDown == 0 {
                        println("Gutter!!")
                    } 
                    
                    if ball == 1 && pinsDown == 10 {
                        println("Strike!!!!!")
                        frameResult = 3
                    } else if ball == 2 && pinsDown == 10 {
                        println("Spare!!!!")
                        frameResult = 2
                    } else if ball == 2 && pinsDown < 10 {
                        println("Error!!!")
                        frameResult = 1
                    } else {
                        println("Roll your 2nd ball")
                    }
                    
                    //6210 REMARK STORAGE OF THE SCORES
                    println()
                    a[(frameNumber * player, ball)] = pinsDown
                    
                    //New scoring
                    var playerScoreByFrame = score[player-1]
                    var frameScore = playerScoreByFrame[frameNumber] ?? Frame()
                    if ball == 1 {
                        frameScore.ball1 = pinsDown
                    } else {
                        frameScore.ball2 = pinsDown - previousPinsDown
                    }
                    playerScoreByFrame[frameNumber] = frameScore
                    score[player-1] = playerScoreByFrame
                    
                    if ball == 1 {
                        ball = 2
                        previousPinsDown = pinsDown
                        if frameResult == 3 {
                            //Goes back to 6210 for strike
                            println()
                            a[(frameNumber * player, ball)] = pinsDown
                        } else {
                            //score[(frame * player, ball)] = pinsDown - previousPinsDown
                            //Bug? this will always be zero for ball 2, which will then be set to pins down on next ball
                        }
                    }
                }
                
                a[(frameNumber * player, 3)] = frameResult
            }
        
            //Line 7200
            frameNumber += 1
        }
        
        //Lines 7295-8370
        println("Frames")
        for i in 1...10 {
            print(tab((i-1)*4), i)
        }
        println(tab(40), "Total")
        
        //Lines 7740-8370 Old score
//        for p in 1...numberOfPlayers {
//            for i in 1...3 {
//                for j in 1...10 {
//                    print(tab((j-1)*4), a[(j * p, i)])  //Old score
//                }
//                println()
//            }
//            println()
//        }
        
        score.forEach { scoreByFrame in
            let frameNumbers = scoreByFrame.keys.sorted()
            frameNumbers.forEach { print(tab(($0-1)*4), scoreByFrame[$0]?.ball1 ?? 0) }
            println()
            frameNumbers.forEach { print(tab(($0-1)*4), scoreByFrame[$0]?.total ?? 0) }
            println(tab(41), scoreByFrame.values.reduce(0, { $0 + $1.total }))
            frameNumbers.forEach { print(tab(($0-1)*4), scoreByFrame[$0]?.resultString ?? " ") }
            println(2)
        }
        
        wait(.short)
        
        //Lines 8460-8730
        let response = Response(input("Do you want another game"))
        switch response {
        case .yes:
            bowl(numberOfPlayers)
        case .easterEgg:
            showEasterEgg(.bowling)
        default:
            break
        }
        
        end()
    }
}

//For improved scoring
fileprivate struct Frame {
    var ball1 = 0
    var ball2 = 0
    
    var total: Int { ball1 + ball2 }
    
    var resultString: String {
        switch total {
        case 10:
            return ball1 == 10 ? "X" : "/"
        default:
            return " "
        }
    }
}
