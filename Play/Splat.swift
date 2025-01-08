//
//  Splat.swift
//  Splat
//
//  Created by Joseph Baraga on 3/22/22.
//

import Foundation


class Splat: GameProtocol {
    
    private var chuteOpenAltitudes = [Double]()  //Array A - history of chute opening altitudes
    static let key = "altitudes"
    
    init() {
        if let array = UserDefaults.standard.array(forKey: Self.key) as? [Double] {
            chuteOpenAltitudes = array
        }
    }
    
    func run() {
        printHeader(title: "Splat")
        println("Welcome to 'Splat' -- the game that simulates a parachute")
        println("jump.  Try to open your chute at the last possible")
        println("moment without going splat.")
        
        repeat {
            play()
            wait(.short)
        } while playAgain().isYes
                
        println("SSSSSSSSSS.")
        wait(.short)
        println()
        promptForReset()
        end()
    }
    
    //2000-2005
    private func playAgain() -> Response {
        let response = Response(input("Do you want to play again"))
        switch response {
        case .other:
            println("Yes or no")
            return playAgain()
        case .no:
            return playAgain2(prompt: "Please")
        case .yes: return response
        }
    }
    
    private func playAgain2(prompt: String) -> Response {
        let response = Response(input(prompt))
        switch response {
        case .other: return playAgain2(prompt: "Yes or no please")
        default: return response
        }
    }
    
    private func play() {
        //Line 118
        println(2)
        let d1 = round(9001 * rnd(1) + 1000)  //Altitude (feet)

        print(" Select your own terminal velocity (yes or no)")
        let v1 = getTerminalVelocity()  //Terminal velocity (ft/sec)
        let v = v1 + (v1 * rnd(1) / 20) - (v1 * rnd(1) / 20)  //Add random variation
        
        print("Want to select acceleration due to gravity (yes or no)")
        let a2 = getAcceleration()  //Acceleration (ft/sec/sec)
        let a = a2 + (a2 * rnd(1) / 20) - (a2 * rnd(1) / 20)  //Add random variation

        println()
        println("    Altitude         = \(Int(d1)) ft")
        println("    Term.Velocity    = \(v1.formatted(.basic))) ft/sec +-5%")
        println("    Acceleration     = " + String(format: "%.1f", a2) + " ft/sec/sec +-5%")
        println("Set the timer for your freefall.")
        
        let t = Double(input("How many seconds")) ?? 0
        
        println("Here we go.")
        println()
        wait(.short)
        jump(d1: d1, v: v, a: a, t: t)
        
        if chuteOpenAltitudes.count > 3 { unlockEasterEgg(.splat) }
        tryAgain()
    }
    
    //Lines 119-130
    private func getTerminalVelocity() -> Double {
        let response = Response(input())
        switch response {
        case .yes:
            let velocity = Double(input("What terminal velocity (mi/hr)")) ?? round(1000 * rnd(1))
            return velocity * 5280 / 3600  //Convert to feet per second
        case .no:
            let velocity = round(1000 * rnd(1))
            println("Ok.  Terminal velocity = \(Int(velocity)) mi/hr")
            return velocity * 5280 / 3600  //Convert to feet per second
        default:
            print("Yes or no")
            return getTerminalVelocity()
        }
    }
    
    //Lines 136-170
    private func getAcceleration() -> Double {
        let response = Response(input())
        switch response {
        case .yes:
            return Double(input("What acceleration (ft/sec/sec)")) ?? 32.16
        case .no:
            switch Int(1 + 10 * rnd(1)) {
            case 1:
                println("Fine. You're on Mercury. Acceleration=12.2ft/sec/sec")
                return 12.2
            case 2:
                println("Alright. You're on Venus. Acceleration=28.3ft/sec/sec")
                return 28.3
            case 3:
                println("The you're on Earth. Acceleration=32.16ft/sec/sec")
                return 32.16
            case 4:
                println("Fine. You're on the Moon. Acceleration=5.15ft/sec/sec")
                return 5.15
            case 5:
                println("Alright. you're on Mars. Acceleration=12.5ft/sec/sec")
                return 12.5
            case 6:
                println("Then you're on Jupiter. Acceleration=85.2ft/sec/sec")
                return 85.2
            case 7:
                println("Fine. You're on Saturn. Acceleration=37.6ft/sec/sec")
                return 37.6
            case 8:
                println("Alright. You're on Uranus. Acceleration=33.8ft/sec/sec")
                return 33.8
            case 9:
                println("Then you're on Neptune. Acceleration=39.6ft/sec/sec")
                return 39.6
            case 10:
                println("Fine. You're on the Sun. Acceleration=896ft/sec/sec")
                return 896.0
            default:
                fatalError("Impossible case")
            }
        default:
            print("Yes or no")
            return getAcceleration()
        }
    }
    
    //Lines 218-1020
    private func jump(d1: Double, v: Double, a: Double, t: Double) {
        println("Time (sec)", "Dist to Fall (Ft)")
        println(String(repeating: "=", count: 10), String(repeating: "=", count: 17))
        
        var d = d1
        var i = 0.0
        //Additional precomputed convenience variables
        let tvTime = v/a  //Time terminal velocity is reached
        var splatTime = tvTime + (d1 - v * v / (2 * a)) / v  //Line 1010 - time of impact if terminal velocity reached
        while i <= t && t > 0 {
            if i > tvTime {
                d = d1 - ((v * v / (2 * a)) + v * (i - tvTime))
                //Extra condition added to original code to suppress message if impact occurs before terminal velocity is reached within current interval
                if (i - t/8) <= tvTime && tvTime <= splatTime {
                    println(String(format: "Terminal velocity reached at T plus %.6f seconds", v/a))
                }
            } else {
                d = d1 - ((a / 2) * i * i)
            }
            
            if d <= 0 {
                //Line 1000, 1010
                if i < tvTime { splatTime = sqrt(2 * d1 / a) }  //Line 1000 - time of impact if terminal velocity not reached
                println(String(format: " %.6f Splat", splatTime))
                splatMessage()
                return
            }
            
            println(" \(i)", String(format: " %0.2f", d))
            i += t/8
        }
        
        //Line 500
        println("Chute Open")
        
        //Lines 510-751 - revised with chuteOpenAltitudes array
        let k = chuteOpenAltitudes.count
        if k < 3 {
            let jumpNumber = k == 0 ? "1st" : ( k == 1 ? "2nd" : "3rd")
            println("Amazing!!! Not bad for your " + jumpNumber + " successful jump!!!")
            chuteOpenAltitudes.append(d)
        } else {
            let sortedAltitudes = chuteOpenAltitudes.sorted()
            let placement = sortedAltitudes.firstIndex(where: { d < $0 }) ?? k  // k - k1
            chuteOpenAltitudes.append(d)
            
            if placement <= Int(0.1 * Double(k)) {
                println("Wow!  That's some jumping.  Of the \(k) successful jumps")
                println("before yours, only \(placement) opened their chutes lower than")
                println("you did.")
            }
            else if placement <= Int(0.25 * Double(k)) {
                println("Pretty good!  \(k) successful jumps preceded yours and only")
                println("\(placement) of them got lower than you did before their chutes")
                println("opened.")
            }
            else if placement <= Int(0.5 * Double(k)) {
                println("Not bad.  There have been \(k) successful jumps before yours.")
                println("You were beaten out by \(placement) of them.")
            }
            else if placement <= Int(0.75 * Double(k)) {
                println("Conservative, aren't you?  You ranked only \(k) in the")
                println("\(k) successful jumps before yours.")
            }
            else if placement <= Int(0.9 * Double(k)) {
                println("Humph!  Don't you have any sporting blood?  There were")
                println("\(k) successful jumps before yours and you came in \(k - placement) jumps")
                println("better than the worst.  Shape up!!!")
            }
            else {
                println("Hey!  You pulled the rip cord much too soon.  \(k) successful")
                println("jumps before yours and you came in number \(placement)!  Get with it!")
            }
        }
    }
    
    private func splatMessage() {
        switch Int(1 + 10 * rnd(1)) {
        case 1: println("Requiescat in pace.")
        case 2: println("May the angel of heaven lead you into paradise")
        case 3: println("Rest in peace")
        case 4: println("Son-of-a-gun")
        case 5: println("#$%&&&!$")
        case 6: println("A kick in the pants is a boost if you're headed right")
        case 7: println("Hmmm. Should have picked a shorter time.")
        case 8: println("Mutter. Mutter. Mutter.")
        case 9: println("Pushing up daisies.")
        case 10: println("Easy come, easy go.")
        default:
            fatalError("Impossible case - you and the program crashed.")
        }
        
        //Line 1950
        println("I'll give you another chance.")
    }
    
    //Lines 2000-2046
    private func tryAgain(message: String = "Do you want to play again") {
        print(message)
        let response = Response(input("Do you want to play again"))
        
        switch response {
        case .yes:
            play()
        case .no:
            if message == "Please" {
                println("SSSSSSSSSS.")
                wait(.short)
                println()
                promptForReset()
                end()
            } else {
                tryAgain(message: "Please")
            }
        default:
            println("Yes or no")
            tryAgain()
        }
    }
    
    private func promptForReset() {
        if input("Do you want to save the prior jumps").isYes {
            UserDefaults.standard.set(chuteOpenAltitudes, forKey: Self.key)
            println("Jump history saved.")
        } else {
            UserDefaults.standard.set(nil, forKey: Self.key)
        }
    }
}
