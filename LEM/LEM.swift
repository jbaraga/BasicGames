//
//  LEM.swift
//  LEM
//
//  Created by Joseph Baraga on 1/5/22.
//

import Foundation


class LEM: GameProtocol {
    private var isNewPilot = true  //Q$ == "NO"
    private var isTryAgain = false //Z$  == "YES"
    private var isMetricUnits = true  //K == 1
    
    private var lengthUnitString: String {  //M$
        return isMetricUnits ? "meters" : "feet"
    }
    
    private var distanceUnitString: String {  //N$
        return isMetricUnits ? " kilometers" : "N.miles"
    }
    
    private enum LandingResult {
        case lostInSpace
        case crashed
        case missedLandingSite
        case success
    }
    
    //Main program flow
    func run() {
        printDescription()
        selectExperienceLevel()
        selectUnits()
        if isNewPilot {
            printInstructions()
        }
        printIOstatements()
        performLanding()
    }
        
    //Lines 2-9
    private func printDescription() {
        printHeader(title: "LEM")
        // ROCKT2 IS AN INTERACTIVE GAME THAT SIMULATES A LUNAR
        // LANDING IS SIMILAR TO THAT OF THE APOLLO PROGRAM.
        // THERE IS ABSOLUTELY NO CHANCE INVOLVED.
        println()
        println("Lunar Landing Simulation")
        println()
    }
    
    //Lines 155-185
    private func selectExperienceLevel() {
        print("Have you flown an Apollo/LEM mission before")
        var response = ""
        while !(response.isYes || response.isNo) {
            response = input(" (yes or no)")
            if !(response.isYes || response.isNo) {
                print("Just answer the question, please,")
            }
        }
        
        isNewPilot = response.isNo
    }
    
    //Lines 190-245
    private func selectUnits() {
        if !isNewPilot {
            print("Input measurement option number")
        } else {
            println("Which system of measurement do you prefer")
            println(" 1=metric     0=english")
            print("Enter the appropriate number")
        }
        isMetricUnits = getUnits() == 1
    }
    
    private func getUnits() -> Int {
        guard let k = Int(input()), k == 0 || k == 1 else {
            print("Enter the appropriate number")
            return getUnits()
        }
        return k
    }
    
    //Lines 315-480
    private func printInstructions() {
        println()
        println("  You are on a lunar landing mission.  As the pilot of")
        println("the Lunar Excursion Module, you will be expected to")
        println("give certain commands to the module navigation system.")
        println("The on-board computer will give a running account")
        println("of the information needed to navigate the ship")
        println(2)
        println("The attitude angle called for is described as follows.")
        println("+ or -180 degrees is directly away from the moon")
        println("-90 degrees is on a tangent in the direction of orbit")
        println("+90 degrees is on a tangent from the direction of orbit")
        println("0 (zero) degrees is directly toward the moon")
        println()
        println(tab(30), "-180,180")
        println(tab(34), "^")
        println(tab(27), "-90 < -+- > 90")
        println(tab(34), "!")
        println(tab(34), "0")
        println(tab(23), "<< Direction of orbit <<")
        println()
        println(tab(27), "Surface of moon")
        println(2)
        println("All angles between -180 and 180 are accepted.")
        
        println()
        println("1 fuel unit = 1 sec. at max thrust")
        println("Any discrepancies are accounted for in the use of fuel")
        println("for an attitude change.")
        println("Available engine power: 0 (zero) and any value between")
        println("10 and 100 percent.")
        println()
        println("Negative thrust or time is prohibited.")
        println()
    }
    
    //Lines 485-565
    private func printIOstatements() {
        println()
        println("Input: Time interval in seconds ------ (T)")
        println("       Percentage of thrust ---------- (P)")
        println("       Attitude angle in degrees ----- (A)")
        println()
        
        if isNewPilot {
            println("For example:")
            println("T,P,A? 10,65,-60")
            println("To abort the mission at any time, enter 0,0,0")
            println()
        }
        
        println("Output: Total time in elapsed seconds")
        println("        Height in " + lengthUnitString)
        println("        Distance from landing site in " + lengthUnitString)
        println("        Vertical velocity in " + lengthUnitString + "/second")
        println("        Horizontal velocity in " + lengthUnitString + "/second")
        println("        Fuel units remaining")
        println()
    }
    
    //Lines 10-1085
    private func performLanding() {
        //Lines 10-130
        var m = 17.95  //M
        let f1 = 5.25  //F1
        let r0 = 926.0  //R0 - distance conversion constant
        let v0 = 1.29  //V0
        var t = 0.0  //T - elapsed time (seconds)
        var h0 = 60.0 //H0 - height in nautical miles
        var r = { r0 + h0 }()  //R
        var a = -3.425  //A - r0 * a = distance from landing site in nautical miles
        var r1 = 0.0  //R1 - vertical velocity in nautical miles per second
        var a1 = 8.84361e-4  //A1
        var m1 = 7.45  //M1 - remaining fuel
        let m0 = 7.45 //M0 - initial fuel
        let b = 750.0  //B - initial fuel units
        var t1 = 0.0  //T1 - time interval
        var f = 0.0  //F - thrust fraction
        var p = 0.0  //P - attitude (degrees)
        
        //Lines 250-300
        let z = { isMetricUnits ? 1852.8 : 6080.0 }()  //Z - conversion nautical miles to meters (exact 1852) or feet (exact 6076.12)
        let g3 = { isMetricUnits ? 3.6 : 0.592 } () //G3 - conversion of meters/sec to km/hr or feet/sec to nautical mph
        let g5 = { isMetricUnits ? 1000 : z }()  //G5 - conversion meters to kilometers if metric
        
        //Lines 810-830
        var height: Double {  //H - height in current units
            return h0 * z
        }
        
        var verticalVelocity: Double {  //H1 - vertical velocity in current units
            return r1 * z
        }
        
        var distance: Double {  //D - distance from landing site in current units (feet or meters)
            return r0 * a * z
        }
        
        var horizontalVelocity: Double {  //D1 - horizontal velocity in current units
            return r * a1 * z
        }
        
        var remainingFuelUnits: Double {
            return m1 * b / m0  //Fraction of fuel remaining is m1 / m0; total fuel units b = 750
        }
        
        var isOnSurface: Bool {
            return h0 < 3.287828e-4  //From line 845 - within 2 feet of surface
        }
        
        var isLostInSpace: Bool {
            return r0 * a > 164.4736  //From line 850; more than 164 nautical miles from landing site
        }
                
        //Lines 580-615
        func getInputs() {
            let input = input("T,P,A")
            let values = input.components(separatedBy: ",")
            guard values.count == 3, let time = Double(values[0]), let thrust = Double(values[1]), let angle = Double(values[2]) else {
                getInputs()
                return
            }
            
            guard time >= 0 else {
                //Lines 905 - 920
                println()
                println("This spacecraft is not able to violate the space-")
                println("time continuum.")
                getInputs()
                return
            }
            t1 = time
            
            f = thrust / 100
            //Lines 605-610; bug in original where negative thrust value is not caught
            guard f >= 0 && abs(f - 0.05) >= 0.05 && abs(f - 0.05) <= 1 else {
                //Lines 945-990
                println()
                print("Impossible thrust value  ")
                switch f {
                case _ where f < 0:
                    println("negative")
                case _ where f - 0.05 < 0.05:
                    println("too small")
                default:
                    println("too large")
                }
                getInputs()
                return
            }
            
            guard abs(angle) <= 180 else {
                //Lines 925-935
                println("If you want to spin around, go outside the module")
                println("for an E.V.A.")
                getInputs()
                return
            }
            p = angle
        }
        
        //Lines 810-840
        func printStatus() {
            //Prints elapsed time in seconds, height, distance form landing site, vertical velocity, horizontal velocity, fuel units remaining
            let timeString = formatter.string(from: t)
            let hString = formatter.string(from: height)
            let vvelString = formatter.string(from: verticalVelocity)
            let dString = formatter.string(from: distance)
            let hvelString = formatter.string(from: horizontalVelocity)
            let fuelString = formatter.string(from: remainingFuelUnits)
            
            print("  " + timeString)
            print(tab(11), hString)
            print(tab(24), dString)
            print(tab(38), vvelString)
            print(tab(50), hvelString)
            println(tab(61), fuelString)
        }
        
        //Execution starts here
        printStatus()
        //Main loop
        while !(isOnSurface || isLostInSpace) {
            if m1 > 0 {
                getInputs()
                if t1 == 0 {
                    //Lines 1090-1095
                    println("Mission Abended")
                    tryAgain()
                    return
                }
            } else {
                t1 = 20
                f = 0
                p = 0
            }
            
            //Lines 620-665 - set variables from inputs
            let n = t1 < 400 ? 20 : t1 / 20   //N - number of iterations during burn, capped at 20
            t1 = t1 / n  //T1 - now used at time interval of each iteration
            p = p * .pi / 180  //Convert attitude to radians
            let s = sin(p)  //S - sine of attitude
            let c = cos(p)  //C - cosine of attitude
            var m2 = m0 * t1 * f / b  //M2 - fuel * burn interval * thrust fraction / initial fuel units (750)
            var r3 = -0.5 * r0 * (pow(v0 / r, 2)) + r * a1 * a1  //R3
            var a3 = -2 * r1 * a1 / r  //A3

            //Lines 670-805
            for _ in 1...Int(round(n)) {
                if m1 == 0 {
                    f = 0
                    m2 = 0
                } else {
                    m1 = m1 - m2
                    if m1 <= 0 {
                        f = f * (1 + m1 / m2)
                        m2 = m1 + m2
                        println("You are out of fuel.")
                        m1 = 0
                    }
                }
                
                //Lines 725-800
                m = m - 0.5 * m2
                let r4 = r3
                r3 = -0.5 * r0 * (pow(v0 / r, 2)) + r * a1 * a1
                let r2 = (3 * r3 - r4) / 2 + 0.00526 * f1 * f * c / m
                let a4 = a3
                a3 = -2 * r1 * a1 / r
                let a2 = (3 * a3 - a4) / 2 + 0.0056 * f1 * f * s / (m * r)
                let x = r1 * t1 + 0.5 * r2 * t1 * t1
                r = r + x
                h0 = h0 + x
                r1 = r1 + r2 * t1
                a = a + a1 * t1 + 0.5 * a2 * t1 * t1
                a1 = a1 + a2 * t1
                m = m - 0.5 * m2
                t = t + t1
                if h0 < 3.287828e-4 { break }  //Impact - within 2 feet of surface
            }
            
            printStatus()
        }
        
        //Landing finished or failed
        //Lines 880-895
        let result: LandingResult
        if isLostInSpace {
            result = .lostInSpace
        } else {
            if r1 < -8.21957e-4 || abs(r * a1) > 4.931742e-4 || h0 < -3.287828e-4 {
                //Crashed if more than 2 feet below surface or going too fast
                result = .crashed
            } else {
                if abs(distance) > 10 * z {  //More than 10 nautical miles from landing site
                    result = .missedLandingSite
                } else {
                    result = .success
                }
            }
        }

        //Lines 995-1085
        println()
        switch result {
        case .lostInSpace:
            println("You have been lost in space with no hope of recovery.")
        case .crashed:
            let hString = formatter.string(from: abs(h0 * z))
            let x1 = sqrt(horizontalVelocity * horizontalVelocity + verticalVelocity * verticalVelocity) * g3
            let xString = formatter.string(from: x1)
            println("Crash !!!!!!!!!!!!!!!!")
            println("Your impact created a crater " + hString + " " + lengthUnitString + " deep.")
            println("At contact you were traveling " + xString + " " + distanceUnitString + "/hr")
        case .missedLandingSite:
            let dString = formatter.string(from: abs(distance / g5))
            println("You are down safely - ")
            println()
            println("but missed the landing site by " + dString + " " + distanceUnitString)
        case .success:
            println("Tranquility Base here -- the Eagle has landed")
            println("Congratulations -- there was no spacecraft damage")
            println("You may now proceed with surface exploration")
            tryAgain(true)
            return
        }
        
        tryAgain()
    }
    
    //Lines 1100-1145
    private func tryAgain(_ success: Bool = false) {
        wait(.long)
        println()
        let response = Response(input("Do you want to try it again (yes/no)"))
        switch response {
        case .easterEgg:
            if success {
                showEasterEgg(.lem)
                end()
                return
            }
        case .yes:
            isNewPilot = false
            selectInstructions()
            performLanding()
            return
        default:
            break
        }
        
        println("Too bad, the space program hates to lose experienced")
        println("astronauts.")
        println()
        end()
    }
    
    //Lines 1150-1210
    private func selectInstructions() {
        println()
        println("OK, Do you want the complete instructions or the input -")
        println("output statements")
        
        var response = 0  //B1
        while response < 1 || response > 3 {
            println("1=Complete Instructions")
            println("2=Input-Output Statements")
            println("3=Neither")
            response = Int(input()) ?? 0
        }
        
        switch response {
        case 1:
            isNewPilot = true
            selectUnits()
            printInstructions()
            printIOstatements()
        case 2:
            selectUnits()
            printIOstatements()
        default:
            selectUnits()
            println()
        }
    }
}

