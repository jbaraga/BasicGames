//
//  Slalom.swift
//  play
//
//  Created by Joseph Baraga on 1/23/25.
//

import Foundation

class Slalom: BasicGame {
    
    private enum Command: String, CustomStringConvertible, CaseIterable {
        case instructions = "INS"
        case maximumSpeeds = "MAX"
        case startRun = "RUN"
        
        var description: String {
            switch self {
            case .instructions: return "instructions"
            case .maximumSpeeds: return "approximate maximum speeds"
            case .startRun: return "the beginning of the race"
            }
        }
    }
    
    private enum Option: Int, CaseIterable {
        case elapsedTime, speedUpLot, speedUpLittle, speedUpTeensy, maintainSpeed, checkTeensy, checkLittle, checkLot, skipGate
        
        var description: String {
            switch self {
            case .elapsedTime: return "see how long you've taken"
            case .speedUpLot: return "speed up a lot"
            case .speedUpLittle: return "speed up a little"
            case .speedUpTeensy: return "speed up a teensy"
            case .maintainSpeed: return "keep going the same speed"
            case .checkTeensy: return "check a teensy"
            case .checkLittle: return "check a little"
            case .checkLot: return "check a lot"
            case .skipGate: return "cheat and try to skip a gate"
            }
        }
    }
    
    private enum Medal: CustomStringConvertible, CaseIterable {
        case gold, silver, bronze
        
        var description: String {
            switch self {
            case .gold: return "Gold"
            case .silver: return "Silver"
            case .bronze: return "Bronze"
            }
        }
    }
    
    private let gateMaximumSpeeds = [14,18,26,29,18,25,28,32,29,20,29,29,25,21,26,29,20,21,20,18,26,25,33,31,22]
    
    func run() {
        printHeader(title: "Slalom")
        play()
    }
    
    private func play() {
        let gates = getGates()  //V
        
        //1440
        println()
        for command in Command.allCases {
            println("Type \"\(command.rawValue)\" for \(command)")
        }
        var command = Command.instructions
        repeat {
            command = getCommand(prompt: "Command--")
            //1490 REM
            switch command {
            case .instructions:
                printInstructions()
            case .maximumSpeeds:
                printMaximumGateSpeeds(number: gates)
            case .startRun:
                break
            }
            
        } while command != .startRun
        
        let rating = getRating()  //A
        var medals = [Medal]()
        repeat {
            if let medal = startRun(gates: gates, rating: rating) {
                medals.append(medal)
            }
        } while playAgain() == .yes
                    
        //1740
        println("Thanks for the race")
        
        for medal in Medal.allCases {
            let count = (medals.filter { $0 == medal }).count
            if count > 0 {
                println("\(medal) Medals: \(count)")
                if medal == .gold {
                    unlockEasterEgg(.slalom)
                }
            }
        }
        
        end()
    }
    
    private func getGates() -> Int {
        let v = input("How many gates does this course have (1 to 25)") ?? 0
        guard v > 0 else {
            println("Try again, ")
            return getGates()
        }
        if v > 25 {
            println("25 is the limit")
            return 25
        }
        return v
    }
    
    private func getRating() -> Int {
        guard let a = Int(input("Rate yourself as a skier, (1-worst, 3-best)")), a > 0, a < 4 else {
            println("The bounds are 1-3")
            return getRating()
        }
        return a
    }
    
    //480-730
    private func startRun(gates: Int, rating: Int) -> Medal? {
        println("The starter counts down...5...4...3...2...1...go!")
        
        var elapsedTime = 0.0
        var speed = Int(rnd() * 9 + 9)
        println()
        println("Your're off!")
        
        var index = 0
        repeat {
            let startingSpeed = speed
            println()
            println("Here comes gate #\(index + 1)")
            println(" \(speed) M.P.H.")
            
            var option = Option.elapsedTime
            repeat {
                option = getOption()
                //990-
                switch option {
                case .elapsedTime:
                    println("You've taken \((elapsedTime + rnd()).formatted(.basic)) seconds")
                case .speedUpLot:
                    speed += Int(rnd() * 5 + 5)
                case .speedUpLittle:
                    speed += Int(rnd() * 2 + 3)
                case .speedUpTeensy:
                    speed += Int(rnd() * 3 + 1)
                case .maintainSpeed:
                    break
                case .checkTeensy:
                    speed -= Int(rnd() * 3 + 1)
                case .checkLittle:
                    speed -= Int(rnd() * 2 + 3)
                case .checkLot:
                    speed -= Int(rnd() * 5 + 5)
                case .skipGate:
                    println("***Cheat")
                    if rnd() < 0.7 {
                        println("An official caught you!")
                        println("You took \((elapsedTime + rnd()).formatted(.basic)) seconds")
                        return nil
                    } else {
                        println("You made it!")
                    }
                }
            } while option == .elapsedTime
            
            if option == .skipGate {
                elapsedTime += 1.5
                index += 1
            } else {
                println(" \(speed) M.P.H.")
                
                let maxSpeed = gateMaximumSpeeds[index]  //Q
                if speed > maxSpeed {
                    //1290
                    if rnd() < Double(speed - maxSpeed) * 0.1 + 0.2 {
                        println("You took over max. speed and \(rnd() < 0.5 ? "snagged a flag!" : "wiped out!")")
                        println("You took \((elapsedTime + rnd()).formatted(.basic)) seconds")
                        return nil
                    } else {
                        println("You took over max. speed and made it!")
                    }
                } else if speed > maxSpeed - 1 {
                    println("Close one!")
                }
                
                if speed < 7 {
                    println("Let's be realistic, ok?  Let's go back and try again...")  //1390
                    speed = startingSpeed
                } else {
                    elapsedTime += Double(maxSpeed - speed + 1)  //650
                    if speed > maxSpeed { elapsedTime += 0.5 }
                    index += 1
                }
            }
            
        } while index < gates
        
        //680
        println("You took \((elapsedTime + rnd()).formatted(.basic)) seconds")
        
        let m = elapsedTime / Double(gates)  //Average time per gate
        if m < 1.5 - (Double(rating) * 0.1) {
            println("You won a gold medal!")
            return .gold
        } else if m < 2.9 - (Double(rating) * 0.1) {
            println("You won a silver medal")
            return .silver
        } else if m < 4.4 - (Double(rating) * 0.01) {
            println("You won a bronze medal")
            return .bronze
        }
        return nil
    }
    
    private func getOption() -> Option {
        guard let number = Int(input("Option")), let option = Option(rawValue: number) else {
            println("What?")
            return getOption()
        }
        return option
    }
    
    private func playAgain() -> Response {
        let response = Response(input("Do you want to race again"))
        if response == .other {
            println("Please type 'yes' or 'no'")
            return playAgain()
        }
        return response
    }
    
    //1470-1480
    private func getCommand(prompt: String? = nil) -> Command {
        if let prompt {
            println()
            print(prompt)
        }
        let string = input().uppercased()
        guard let command = Command(rawValue: string) else {
            print("\"\(string)\" is an illegal command--retry")
            return getCommand()
        }
        return command
    }
    
    //820-960
    private func printInstructions() {
        println()
        println("***Slalom:  This is the 1976 Winter Olympic Giant Slalom.  You are")
        println("            the American Team's only hope of a gold medal.")
        println()
        for option in Option.allCases {
            println("     \(option.rawValue)--type this if you want to " + option.description)
        }
        println()
        println(" The place to use these options is when the computer asks:")
        println()
        println("Option?")
        println()
        println(tab(14), "Good luck,")
        println()
    }
    
    //1550-1620
    private func printMaximumGateSpeeds(number: Int) {
        println("Gate Max")
        println(" #  M.P.H.")
        println("----------")
        for (index, speed) in gateMaximumSpeeds[..<number].enumerated() {
            println(" \(index+1)    \(speed)")
        }
    }
}
