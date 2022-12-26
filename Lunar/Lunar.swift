//
//  Lunar.swift
//  Lunar
//
//  Created by Joseph Baraga on 1/2/22.
//

import Foundation


class Lunar: GameProtocol {
    private let tab = 12
    
    func run() {
        printDescription()
        printInstructions()
        performLanding()
    }
    
    private func performLanding() {
        var weight = 33000.0  //M - weight of capsule, including remaining fuel (lbs) and ?additional 500 lbs for astronauts?
        let capsuleWeight = 16500.0  //N - This is capsule weight, not including fuel. Incorrectly labeled fuel weight in description.
        var altitude = 120.0  //A - miles
        var velocity = 1.0  //V - vertical velocity mps
        var elapsedTime = 0.0 //L - seconds
        let g = 1.01e-3  //lunar gravity miles/sec/sec
        let z = 1.8  //Z - burn force conversion?
        
        var t = 10.0  //T seconds - interval time counter during segment, each segment is 10 seconds long
        var segmentAltitude = 120.0  //I - altitude (miles) used during segment for iterative calculation
        var segmentVelocity = 1.0  //J - velocity (mps) used during segment for iterative calculation
        
        var remainingFuel: Double {
            return weight - capsuleWeight
        }
        
        var elapsedTimeString: String {
            return formatter.string(from: elapsedTime)
        }
        
        var velocityString: String {
            let mph = velocity * 3600
            return formatter.string(from: mph)
        }
        
        var fuelString: String {
            return formatter.string(from: remainingFuel)
        }

        var altitudeString: String {
            return "\(Int(altitude))  \(Int(5280 * (altitude - Double(Int(altitude)))))"
        }
        
        //Line 330. s is burn time in seconds, rate is burn rate
        func commitTrialBurn(for s: Double, rate: Double) {
            elapsedTime += s
            t -= s
            weight -= s * rate
            altitude = segmentAltitude
            velocity = segmentVelocity
        }
        
        //Lines 420-430. s is burn time in seconds, rate is burn rate
        func performTrialBurn(for s: Double, rate: Double) {
            let q = s * rate / weight
            segmentVelocity = velocity + g * s - z * (q + pow(q,2)/2 + pow(q,3)/3 + pow(q,4)/4 + pow(q,5)/5)  //series expansion ln(1-q)
            segmentAltitude = altitude - g * s * s / 2 - velocity * s + z * s * (q/2 + pow(q,2)/6 + pow(q,3)/12 + pow(q,4)/20 + pow(q,5)/30)  //Integral of velocity
            
            //Alternate - no expansion
//            segmentVelocity = velocity + g * s + z * log(1 - q)
//            segmentAltitude = altitude - g * s * s / 2 - velocity * s - z * s * ((q - 1) * (log(1 - q) - 1) - 1)
        }
        
        //Lines 340-360. Iteratively compute burn for segment shortened by impact. s does not have to be updated
        func performFinalBurn(for s: Double, rate: Double) {
            var s = s
            while s >= 5e-3 {
                let d = velocity + sqrt(velocity * velocity + 2 * altitude * (g - z * rate / weight))
                s = 2 * altitude / d
                performTrialBurn(for: s, rate: rate)
                commitTrialBurn(for: s, rate: rate)
            }
        }
        
        //Line 130
        printHeader()
        println()
        
        //Lines 150-230
        outerLoop: while remainingFuel >= 1e-3 {
            printTab(elapsedTimeString, tab: tab)
            printTab(altitudeString, tab: tab)
            printTab(velocityString, tab: tab)
            printTab(fuelString, tab: tab)
            let rate = Double(input()) ?? 0.0  //K - burn rate lbs per second
            t = 10.0  //T seconds - interval time counter
            
            //Lines 160-230
            while t >= 1e-3 {
                //Lines 180-200
                var s = remainingFuel >= t * rate ? t : remainingFuel / rate  //S - burn time in seconds for requested burn rate, capped by available fuel
                performTrialBurn(for: s, rate: rate)
                
                if segmentAltitude <= 0 {  //Impact during trial burn
                    performFinalBurn(for: s, rate: rate)
                    break outerLoop
                }
                
                if velocity > 0 && segmentVelocity < 0 {
                    //If vertical velocity has switched from positive to negative during trial burn, must iteratively compute altitude and velocity during burn, and detect case where impact occurred while velocity was still positive
                    while velocity > 0 && segmentVelocity < 0 {
                        //Line 370-410
                        let w = (1 - weight * g/(z * rate)) / 2
                        s = weight * velocity / (z * rate * (w + sqrt(w * w + velocity / z))) + 0.05
                        performTrialBurn(for: s, rate: rate)
                        
                        if segmentAltitude <= 0 {  //Impact during trial burn
                            performFinalBurn(for: s, rate: rate)
                            break outerLoop
                        } else {
                            commitTrialBurn(for: s, rate: rate)
                        }
                    }
                } else {
                    commitTrialBurn(for: s, rate: rate)
                }
            }
        }
        
        println()

        if remainingFuel < 1e-3 {
            println("Fuel out at \(elapsedTime) seconds")
            let ffTime = (sqrt(velocity * velocity + 2 * altitude * g) - velocity) / g  //S (reused) - Free fall time
            velocity += g * ffTime
            elapsedTime += ffTime
        }
        
        let timeString = formatter.string(from: elapsedTime)
        println("On moon at " + timeString + " - impact velocity " + velocityString + " mph")
        
        let mph = velocity * 3600
        switch mph {
        case ...1.2:
            println("Perfect landing!")
        case 1.2...10:
            println("Good landing (could be better)")
        case 10...60:
            println("Craft damage... you're stranded here until a rescue")
            println("party arrives. Hope you have enough oxygen!")
        default:
            println("Sorry there were no survivors. You blew it!")
            let feet = formatter.string(from: mph * 0.277)
            println("In fact, you blasted a new lunar crater \(feet) feet deep!")
        }
        
        wait(.long)
        println(3)
        let response = input("Try again")
        if response.isEasterEgg, mph <= 10 {
            showEasterEgg(Egg.lunar.filename)
        }
        
        if response.isYes {
            printInstructions()
            performLanding()
        } else {
            end()
        }
    }
    
    //Lines 10-110
    private func printDescription() {
        printHeader(title: "Lunar")
        print(tab(15))
        println("CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY")
        println()
        println("This is a computer simulation of an Apollo lunar")
        println("landing capsule.")
        println()
        println("The on-board computer has failed (it was made by")
        println("Xerox) so you have to land the capsule manually.")
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
    
    //Line 130
    private func printHeader() {
        printTab("SEC", tab: tab)
        printTab("MI + FT", tab: tab)
        printTab("MPH", tab: tab)
        printTab("LB FUEL", tab: tab)
        println("BURN RATE")
    }
}
