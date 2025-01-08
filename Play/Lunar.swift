//
//  Lunar.swift
//  Lunar
//
//  Created by Joseph Baraga on 1/2/22.
//

import Foundation


class Lunar: GameProtocol {
    private let g = 1.01e-3  //lunar gravity miles/sec/sec
    private let z = 1.8  //Z - burn force conversion?
    private let capsuleWeight = 16500.0  //N - This is capsule weight, not including fuel. Incorrectly labeled fuel weight in description.
    
    private struct BurnResult {
        var velocity: Double
        var altitude: Double
    }

    func run() {
        printHeader(title: "Lunar", newlines: 1)
        println("This is a computer simulation of an Apollo lunar")
        println("landing capsule.")
        println(2)
        println("The on-board computer has failed (it was made by")
        println("Xerox) so you have to land the capsule manually.")
        
        repeat {
            printInstructions()
            performLanding()
            wait(.short)
        } while Response(input("Try again", terminator: "??")).isYes
        
        end()
    }
    
    private func performLanding() {
        var weight = 33000.0  //M - weight of capsule, including remaining fuel (lbs) and ?additional 500 lbs for astronauts?
        var altitude = 120.0  //A - miles
        var velocity = 1.0  //V - vertical velocity mps
        var elapsedTime = 0.0 //L - seconds
        
        var remainingFuel: Double { weight - capsuleWeight }  //M-N
        var isOutOfFuel: Bool { remainingFuel < 1e-3 }
        
        var elapsedTimeString: String { elapsedTime.formatted(.basic) }
        var velocityString: String { (velocity * 3600).formatted(.basic) }
        var fuelString: String { remainingFuel.formatted(.basic) }
        var altitudeString: String { "\(Int(altitude))  \(Int(5280 * (altitude - Double(Int(altitude)))))" }
                
        //Line 130
        println("SEC", "MI + FT", "MPH", "LB FUEL", "BURN RATE")
        println()
        
        //Lines 150-230
        while !isOutOfFuel && altitude > 0 {
            print(elapsedTimeString, altitudeString, velocityString, fuelString, "")
            var rate = Double(input()) ?? 0.0  //K - burn rate lbs per second
            if rate < 0 { rate = 0 }
            if rate > 200 { rate = 200 }
            var t = 10.0  //T seconds - interval time counter during segment, each segment is 10 seconds long
            
            //Lines 160-230
            while t >= 1e-3 && !isOutOfFuel {
                //Lines 180-200
                var s = remainingFuel >= t * rate ? t : remainingFuel / rate  //S - burn time in seconds for requested burn rate, capped by available fuel, or t if rate = 0
                var burnResult = performBurn(forTime: s, rate: rate, weight: weight, velocity: velocity, altitude: altitude)
                
                //Lines 210-220 - if vertical velocity switches from positive to negative during burn, shorten burn  to compute altitude when velocity is near zero to detect potential impact
                if velocity > 0 && burnResult.velocity < 0 {
                    //Line 370-410
                    let w = (1 - weight * g/(z * rate)) / 2
                    s = weight * velocity / (z * rate * (w + sqrt(w * w + velocity / z))) + 0.05
                    burnResult = performBurn(forTime: s, rate: rate, weight: weight, velocity: velocity, altitude: altitude)
                }
                
                //Commit burn results if no impact
                if burnResult.altitude > 0 {
                    velocity = burnResult.velocity
                    altitude = burnResult.altitude
                    if s > t {
                        s = t  //Prevents interval of >10 sec for rounding error if velocity switches to negative
                    }
                    t -= s
                    elapsedTime += s
                    weight -= s * rate
                } else {
                    //Lines 340-360 - iteratively compute burn for segment shortened by impact.
                    while s >= 5e-3 {
                        let d = velocity + sqrt(velocity * velocity + 2 * altitude * (g - z * rate / weight))
                        s = 2 * altitude / d
                        let result = performBurn(forTime: s, rate: rate, weight: weight, velocity: velocity, altitude: altitude)
                        velocity = result.velocity
                        altitude = result.altitude
                        elapsedTime += s
                        weight -= s * rate
                    }
                    //Force end of loop landing
                    altitude = 0
                    t = 0
                }
            }
        }
        
        println()

        if isOutOfFuel {
            //Lines 240-250 - free fall
            println("Fuel out at \(elapsedTimeString) seconds")
            let s = (sqrt(velocity * velocity + 2 * altitude * g) - velocity) / g  //S (reused) - Free fall time
            velocity += g * s
            elapsedTime += s
        }
        
        println("On moon at \(elapsedTimeString) seconds - impact velocity \(velocityString) mph")
        
        let mph = velocity * 3600
        switch mph {
        case ...1.2:
            println("Perfect landing!")
            unlockEasterEgg(.lunar)
        case 1.2...10:
            println("Good landing (could be better)")
            unlockEasterEgg(.lunar)
        case 10...60:
            println("Craft damage... you're stranded here until a rescue")
            println("party arrives. Hope you have enough oxygen!")
        default:
            println("Sorry there were no survivors. You blew it!")
            let feet = (mph * 0.277).formatted(.basic)
            println("In fact, you blasted a new lunar crater \(feet) feet deep!")
        }
        
        println(3)
    }
    
    private func printInstructions() {
        println()
        println("Set the burn rate of retro rockets to any value between")
        println("0 (free fall) and 200 (maximum burn) pounds per second.")
        println("Set new burn rate every 10 seconds.")
        println("Capsule weight 32,500 lbs; fuel weight 16,500 lbs.")
        println()
        println("Good luck")
        println()
        wait(.long)
    }
    
    //Lines 420-430. rate is burn rate
    private func performBurn(forTime s: Double, rate: Double, weight: Double, velocity: Double, altitude: Double) -> BurnResult {
        let q = s * rate / weight
        guard q > 0 else {
            return BurnResult(velocity: velocity + g * s, altitude: altitude - g * s * s / 2 - velocity * s)
        }
        
        let finalVelocity = velocity + g * s + z * log(1 - q)
        let finalAltitude = altitude - g * s * s / 2 - velocity * s + z * s * ((1 - q) * log(1 - q) / q + 1)
        //Original code, Taylor's expansion to calculate log(1-q)
//        let finalVelocity = velocity + g * s - z * (q + pow(q,2)/2 + pow(q,3)/3 + pow(q,4)/4 + pow(q,5)/5)  //series expansion ln(1-q)
//        let finalAltitude = altitude - g * s * s / 2 - velocity * s + z * s * (q/2 + pow(q,2)/6 + pow(q,3)/12 + pow(q,4)/20 + pow(q,5)/30)  //Integral of velocity
        return BurnResult(velocity: finalVelocity, altitude: finalAltitude)
    }
}
