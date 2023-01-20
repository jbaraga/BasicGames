//
//  Hamurabi.swift
//  Hamurabi
//
//  Created by Joseph Baraga on 1/13/23.
//

import Foundation


class Hamurabi: GameProtocol {
    
    func run() {
        printHeader(title: "Hamurabi")
        println(3)
        println("Try your hand at governing ancient Sumeria")
        println("For a ten-year term of office.")
        println()
        wait(.short)
        playGame()
    }
    
    private func playGame() {
        var d1 = 0  //Cumulative deaths
        var p1 = 0  //Running average mortality rate per year
        
        var year = 0  //Z
        var p = 95  //Population
        var i = 5  //# people added for year
        var d = 0  //# people died for year

        var yield = 3  //Y - bushels of grain harvested per acre
        var h = 3000  //Harvested grain in 1 year
        var acres = h / yield
        var s = 2800  // Bushels in store
        var e = h - s  //Loss of bushels to rats for year
        
        repeat {
            println(2)
            println("Hamurabi:  I beg to report to you,")
            year += 1
            println("in year \(year) , \(d) people starved, \(i) came to the city,")
            p += i
            
            //541 REM *** HORROR, A 15% CHANCE OF PLAGUE
            if year > 1 && rnd(1) <= 0.15 {
                p /= 2
                println("A horrible plague struck!  Half the people died.")
            }
            
            println("The population is now \(p)")
            println("The city now owns \(acres) acres.")
            println("You harvested \(yield) bushels per acre.")
            println("Rats ate \(e) bushels.")
            println("You now have \(s) bushels in store.")
            println()
            
            if year < 11 {
                //Lines 310-350
                var c = Int(10.0 * rnd(1))  //Random number, reused throughout code block
                yield = c + 17
                
                println("Land is trading at \(yield) bushels per acre.")
                let q0 = acresToBuy(bushelsPerAcre: yield, withBushels: s)
                switch q0 {
                case _ where q0 < 0:
                    unableToComplyMessage()
                    return
                case _ where q0 > 0:
                    acres += q0
                    s -= yield * q0
                    //c = 0
                default:
                    let q1 = acresToSell(fromAcres: acres)
                    if q1 < 0 {
                        unableToComplyMessage()
                        return
                    }
                    acres -= q1
                    s += yield * q1
                    //c = 0
                }
               
                //Line 400-430
                println()
                let q2 = bushelsToFeed(fromBushels: s)
                if q2 < 0 {
                    unableToComplyMessage()
                    return
                }
                s -= q2
                //c = 1
                println()
                
                //Lines 440-510
                d = acresToPlant(fromAcres: acres, withBushels: s, withPeople: p)
                if d < 0 {
                    unableToComplyMessage()
                    return
                }
                s -= d / 2
                
                c = getC()
                //512 REM *** A BOUNTIFUL HARVEST
                yield = c
                h = d * yield
                e = 0
                
                c = getC()
                if c % 2 == 0 {
                    //523 REM *** RATS ARE RUNNING WILD
                    e = s / c
                }
                s += (h - e)
                
                c = getC()
                //532 REM *** LET'S HAVE SOME BABIES
                i = Int(Double(c * (20 * acres + s)) / Double(p) / 100 + 1)
                
                //539 REM *** HOW MANY PEOPLE HAD FULL TUMMIES?
                let numberFed = q2 / 20
                if p < numberFed {
                    d = 0
                } else {
                    //551 REM *** STARVE ENOUGH FOR IMPEACHMENT?
                    d = p - numberFed
                    if Double(d) > 0.45 * Double(p) {
                        println()
                        println("You starved \(d) people in one year!!!")
                        failure()
                        stop()
                        return
                    } else {
                        p1 = ((year - 1) * p1 + d * 100 / p) / year
                        p = numberFed
                        d1 += d
                    }
                }
            }
        } while year < 11
        
        println("In your 10-year term of office, \(p1) percent of the")
        println("population starved per year on the average, i.e. a total of")
        println("\(d1) people died!!")
        let l = Double(acres) / Double(p)
        println("You started with 10 acres per person and ended with")
        println(String(format: "%.1f acres per person.", l))
        println()
        
        switch p1 {
        case _ where p1 > 33 || l < 7:
           //Line 565
            failure()
        case _ where p1 > 10 || l < 9:
            //Line 940
            println("You heavy-handed performance smacks of Nero and Ivan IV.")
            println("The people (remaining) find you an unpleasant ruler, and,")
            println("frankly, hate your guts!!")
        case _ where p1 > 3 || l < 10:
            //Line 960
            println("Your performance could have been somewhat better, but")
            println("really wasn't too bad at all.  \(Int(Double(p) * 0.8 * rnd(1))) people")
            println("dearly like to see you assassinated but we all have our")
            println("trivial problems.")
        default:
            //Line 900
            println("A fantastic performance!!!  Charlemagne, Disraeli, and")
            println("Jefferson combined could not have done better!")
            wait(.long)
            pauseForEnter()
            showEasterEgg(.hamurabi)
        }
        
        stop()
    }
    
    //Lines 320-324, 710-711
    private func acresToBuy(bushelsPerAcre y: Int, withBushels s: Int) -> Int {
        let q = Int(input("How many acres do you wish to buy")) ?? 0
        guard y * q <= s else {
            println("Hamurabi:  think again, you have only")
            println("\(s) bushels of grain.  Now then,")
            return acresToBuy(bushelsPerAcre: y, withBushels: s)
        }
        return q
    }
    
    //Lines 340-344, 720
    private func acresToSell(fromAcres a: Int) -> Int {
        let q = Int(input("How many acres do you wish to sell")) ?? 0
        guard q <= a else {
            insufficientAcresMessage(a)
            return acresToSell(fromAcres: a)
        }
        return q
    }
    
    //lines 410-430
    private func bushelsToFeed(fromBushels s: Int) -> Int {
        let q = Int(input("How many bushels do you wish to feed your people")) ?? 0
        //418 REM *** TRYING TO USE MORE GRAIN THAN IS IN SILOS?
        guard q <= s else {
            insufficientBushelsMessage(s)
            return bushelsToFeed(fromBushels: s)
        }
        return q
    }
    
    //Lines 440-470
    private func acresToPlant(fromAcres a: Int, withBushels s: Int, withPeople p: Int) -> Int {
        let d = Int(input("How many acres do you wish to plant with seeds")) ?? 0
        //444 REM *** TRYING TO PLAN MORE ACRES THAN YOU OWN?
        guard d <= a else {
            insufficientAcresMessage(a)
            return acresToPlant(fromAcres: a, withBushels: s, withPeople: p)
        }
        
        //449 REM *** ENOUGH GRAIN FOR SEED?
        guard d / 2 <= s else {
            insufficientBushelsMessage(s)
            return acresToPlant(fromAcres: a, withBushels: s, withPeople: p)
        }
        
        //454 REM *** ENOUGH PEOPLE TO TEND THE CROPS?
        guard d < 10 * p else {
            println("But you have only \(p) people to tend the fields!  Now then,")
            return acresToPlant(fromAcres: a, withBushels: s, withPeople: p)
        }
        
        return d
    }
    
    //Lines 565-567
    private func failure() {
        println("Due to this extreme mismanagement you have not only")
        println("been impeached and thrown out of office but you have")
        println("also been declared national fink!!!!")
    }
    
    //Lines 710-711
    private func insufficientBushelsMessage(_ s: Int) {
        println("Hamurabi:  think again, you have only")
        println("\(s) bushels of grain.  Now then,")
    }
    
    //Line 720
    private func insufficientAcresMessage(_ a: Int) {
        println("Hamurabi: think again,  You own only \(a) acres.  Now then,")
    }
    
    //Line 800 - random number from 1 to 6
    private func getC() -> Int {
        return Int(5.0 * rnd(1)) + 1
    }
    
    //Lines 850-855
    private func unableToComplyMessage() {
        println()
        println("Hamurabi:  I cannot do what you wish.")
        println("Get yourself another steward!!!!!")
        stop()
    }
    

    private func stop() {
        consoleIO.ringBell(10)
        println("So long for now.")
        println()
        wait(.long)
        end()
    }
}
