//
//  King.swift
//  King
//
//  Created by Joseph Baraga on 1/18/23.
//

import Foundation

class King: GameProtocol {
    private let term = 8  //N5 - term in years
    private var year = 0  //X5 - current year
    private var cash = 0  //A - money in treasury
    private var population = 0  //B - countrymen
    private var workers = 0  //C - foreign workers
    private var totalLand = 2000  //D - square miles of land, farm land plus forest land
    private var showLandErrorMessage = true  //X
    
    private var farmLand: Int {
        return totalLand - 1000  //Forest land is fixed at 1000 sq. mi.
    }
    
    private enum StopReason {
        case userTermination
        case excessiveWorkers
        case deaths(Int)
        case famine
        case mismanagement
    }
    
    func run() {
        printHeader(title: "King")
        println(3)
        
        let z$ = input("Do you want instructions")
        if z$.uppercased() == "AGAIN" {
            //Line 1960 - get inputs for prior game
            restore()
        } else {
            if z$.isYes {
                printInstructions()
            }
            //Lines 50-65 - initialize
            cash = Int(60000 + (1000 * rnd(1)) - (1000 * rnd(1)))
            population = Int(500 + (10 * rnd(1)) - (10 * rnd(1)))
        }
        
        wait(.short)
        println()
        play()
    }
    
    private func play() {
        var v3 = 0  //Amount made from tourism previous year
        
        while year < term {
            let landMarketRate = Int(10 * rnd(1) + 95)  //W - current land sale price per square mile
            let plantingCostRate = Int(((rnd(1) / 2) * 10) + 10)  //V9- current cost to plant land per square mile
            
            //Lines 102-162 - show status
            println()
            println("You now have \(cash) rallods in the treasury.")
            print("\(population) countrymen, ")
            if workers > 0 {
                print("\(workers) foreign workers, ")
            }
            println("and \(totalLand) sq. miles of land.")
            println("This year industry will buy land for \(landMarketRate) rallods per sq. mile.")
            println("Land currently costs \(plantingCostRate) rallods per sq. mile to plant.")
            println()
            
            //Lines 200-550 - get inputs
            let landSold = sellLand()  //H
            totalLand -= landSold
            cash += landSold * landMarketRate
            
            let annualPayout = getAnnualPayout()  //I
            cash -= annualPayout
            
            let plantedLand = cash > 0 ? getLandToPlant(atCost: plantingCostRate) : 0  //J
            cash -= plantedLand * plantingCostRate
            
            let pollutionExpenditure = cash > 0 ? pollutionControlSpending() : 0  //K
            cash -= pollutionExpenditure
            
            //Lines 600-606 - all inputs zero stops game
            if landSold == 0 && annualPayout == 0 && plantedLand == 0 && pollutionExpenditure == 0 {
                stop(reason: .userTermination)
            }
            
            println(2)
            let cashReserve = cash  //Line 1020 - A4
            
            //Annual deaths
            let deaths = annualDeaths(for: annualPayout, pollutionControl: pollutionExpenditure, landMarketRate: landMarketRate)
            let totalDeaths = deaths.starved + deaths.pollution  //B5
            population -= totalDeaths
            
            //Immigration/emigration
            let populationChange = annualPopulationChange(landSold: landSold, annualPayout: annualPayout, pollutionExpenditure: pollutionExpenditure, pollutionDeaths: deaths.pollution)
            workers += populationChange.workers
            population += populationChange.countrymen
            
            //Crops
            let harvestedLand = harvestedLand(from: plantedLand)
            let cropProceeds = Int(Double(harvestedLand) * Double((landMarketRate / 2)))
            println(" Making \(cropProceeds) rallods")
            cash += cropProceeds
            
            //Tourism
            let tourismProceeds = tourismIncome(populationChange: populationChange.countrymen, priorYearIncome: v3)
            cash += tourismProceeds
            v3 = tourismProceeds
            
            //Lines 1500-1520 - tests for failure
            if totalDeaths > 200 {
                stop(reason: .deaths(totalDeaths))
            }
          
            if population < 343 {
                stop(reason: .famine)
            }
            
            if cashReserve / 100 > 5 && deaths.starved >= 2 {
                stop(reason: .mismanagement)
            }
            
            if workers > population {
                stop(reason: .excessiveWorkers)
            }
            
            year += 1
        }
        
        //Lines 1920-1950 - fallthrough - success
        println()
        println("Congratulations!!!!!!!!!!!!!!!!!!!")
        println("You have successfully completed your \(term) year term")
        println("of office.  You were, of course, extremely lucky, but")
        println("nevertheless, it's quite an achievement.  Goodbye and good")
        println("luck - you'll probably need it if you're the type that")
        println("plays the game.")
        
        unlockEasterEgg(.king)
        stop()
    }
    
    //Lines 200-299
    private func sellLand() -> Int {
        let h = Int(input("How many sq. miles do you wish to sell to industry")) ?? -1
        if h < 0 {
            return sellLand()
        }
        if h > farmLand  {
            println("   Think again, you've only \(farmLand) sq. miles of farm land.")
            if showLandErrorMessage {
                printLandErrorExplanation()
            }
            return sellLand()
        }
        return h
    }
    
    private func printLandErrorExplanation() {
        println("(Foreign industry will only buy farm land because")
        println("forest land is uneconomical to strip mine due to trees,")
        println("thicker top soil, etc.)")
        showLandErrorMessage = false
    }
    
    //Lines 320-375
    private func getAnnualPayout() -> Int {
        let i = Int(input("How many rallods will you distribute to your countrymen")) ?? -1
        if i < 0 {
            return getAnnualPayout()
        }
        if i > cash {
            println("   Think again, you've only \(cash) rallods in the treasure")
            return getAnnualPayout()
        }
        return i
    }
    
    //Lines 410-460
    private func getLandToPlant(atCost v9: Int) -> Int {
        let j = Int(input("How many sq. miles do you wish to plant")) ?? -1
        if j < 0 {
            return getLandToPlant(atCost: v9)
        }
        guard j <= population * 2 else {
            println("   Sorry, but each countryman can only plant 2 sq. miles")
            return getLandToPlant(atCost: v9)
        }
        guard j <= farmLand else {
            println("   Sorry, but you've only \(farmLand) sq. miles of farm land")
            return getLandToPlant(atCost: v9)
        }
        if j * v9 > cash {
            println("   Think again, you've only \(cash) rallods left in the treasury")
            return getLandToPlant(atCost: v9)
        }
        return j
    }
    
    //Lines 510-500
    private func pollutionControlSpending() -> Int {
        let k = Int(input("How many rallods do you wish to spend on pollution control")) ?? -1
        if k < 0 {
            return pollutionControlSpending()
        }
        if k > cash {
            println("   Think again, you've only \(cash) rallods remaining")
            return pollutionControlSpending()
        }
        return k
    }
        
    //Lines 1100-1194
    private func annualDeaths(for annualPayout: Int, pollutionControl: Int, landMarketRate: Int) -> (starved: Int, pollution: Int) {
        let numberFed = annualPayout / 100
        let starved = numberFed > population ? 0 : population - annualPayout / 100
        if starved > 0 {
            guard numberFed >= 50 else {
                stop(reason: .famine)
            }
            println("\(starved) countrymen died of starvation")
        }
        
        var pollutionDeaths = Int(rnd(1) * (2000 - Double(totalLand)))  //F1
        if pollutionControl >= 25 {
            pollutionDeaths = Int(Double(pollutionDeaths) / (Double(pollutionControl) / 25))
        }
        if pollutionDeaths > 0 {
            println("\(pollutionDeaths) countrymen died of carbon-monoxide and dust inhalation")
        }
        
        let deaths = starved + pollutionDeaths
        let funeralExpenses = deaths * 9
        if deaths > 0 {
            println("   You were forced to spend \(funeralExpenses) rallods on funeral expenses")
        }
        cash -= funeralExpenses
        if cash < 0 {
            println("Insufficient reserves to cover cost - land was sold")
            totalLand += cash / landMarketRate
            cash = 0
        }
        
        return (starved, pollutionDeaths)
    }

    //Lines 1220-1292
    private func annualPopulationChange(landSold: Int, annualPayout: Int, pollutionExpenditure: Int, pollutionDeaths: Int) -> (workers: Int, countrymen: Int) {
        var c1 = 0
        if landSold > 0 {
            c1 = Int(Double(landSold) + (rnd(1) * 10) - (rnd(1) * 20))
            if workers == 0 {
                c1 += 20
            }
            print(" \(c1) workers came to the country and")
        }
        let p1 = ((annualPayout / 100 - population) / 10) + pollutionExpenditure / 25 - ((2000 - totalLand) / 50) - (pollutionDeaths / 2)
        println(" \(abs(p1)) countrymen \(p1 < 0 ? "left" : "came to") the island.")
        return (c1, p1)
    }
    
    //Lines 1305-1365
    private func harvestedLand(from plantedLand: Int) -> Int {
        let unharvestedLand = Int(Double(2000 - totalLand) * ((rnd(1) + 1.5) / 2))
        let harvestedLand = plantedLand > unharvestedLand ? plantedLand - unharvestedLand : 0

        //Line 1310 - assume IF C=0... is a bug
        if plantedLand > 0 {
            print(" Of \(plantedLand) sq. miles planted,")
        }
        println(" You harvested \(harvestedLand) sq. miles of crops.")
        if unharvestedLand > 0 {
            //Line 1344 - var T1 is not defined or changed. Will assume it is zero and jump to line 1365
            println("   (Due to air and water pollution from foreign industry.)")
        }
        return harvestedLand
    }
    
    //Lines 1400-1482
    private func tourismIncome(populationChange: Int, priorYearIncome v3: Int) -> Int {
        let v1 = (population - populationChange) * 22 + Int(rnd(1) * 500)
        let v2 = (2000 - totalLand) * 15
        let proceeds = abs(v1 - v2)
        println(" You made \(proceeds) rallods from tourist trade.")
        if v2 > 0 && proceeds < v3 {
            print("   Decrease because ")
            let g1 = 10 * rnd(1)
            switch g1 {
            case 0...2:
                println("fish population has dwindled due to water pollution.")
            case 2...4:
                println("air pollution is killing game bird population.")
            case 4...6:
                println("mineral baths are being ruined by water pollution.")
            case 6...8:
                println("unpleasant smog is discouraging sun bathers.")
            default:
                println("hotels are looking shabby due to smog grit.")
            }
        }
        return proceeds
    }
    
    //Lines 20-46
    private func printInstructions() {
        println(3)
        println("Congratulations! You've just been elected premier of Setats")
        println("Detinu, a small communist island 30 by 70 miles long.  Your")
        println("job is to decide upon the country's budget and distribute")
        println("money to your countrymen from the communal treasury.")
        println("The money system is rallods, and each person needs 100")
        println("rallods per year to survive.  Your country's income comes")
        println("from farm produce and tourists visiting your magnificent")
        println("forests, hunting, fishing, etc.  Half your land is farm land")
        println("which also has an excellent mineral content and may be sold")
        println("to foreign industry (strip mining) who import and support")
        println("their own workers.  Crops cost between 10 and 15 rallods per")
        println("sq. mile to plant.")
        println("Your goal is to complete your \(term) year term of office.")
        println("Good luck.")
    }
    
    private func stop(reason: StopReason) -> Never {
        switch reason {
        case .userTermination:
            //Lines 609-618 - fixed grammatical errors
            println()
            println("Goodbye.")
            println("(If you wish to continue this game at a later date, answer")
            println("'Again' when asked if you want instructions, at the start.)")
            end()
        case .excessiveWorkers:
            //Lines 1550-1564
            println(2)
            println("The number of foreign workers has exceeded the number")
            println("of countrymen.  As a majority they have revolted and")
            println("taken over the country.")
            finalDisposition()
        case .deaths(let deaths):
            //Lines 1600-1692
            println(2)
            println("\(deaths) countrymen died in one year!!!!!")
            println("Due to this extreme mismanagement you have not only")
            println("been impeached and thrown out of office but you")
            let m6 = Int(rnd(1) * 10)
            switch m6 {
            case 0...3:
                println("also had your left eye gouged out.")
            case 3...6:
                println("have also gained a very bad reputation.")
            default:
                println("have also been declared national fink.")
            }
            stop()
        case .famine:
            //Lines 1700-1730
            println(2)
            println("Over one third of the population has died since you")
            println("were elected to office.  The people (remaining)")
            println("hate your guts.")
            finalDisposition()
        case .mismanagement:
            //Lines 1807-1850
            println()
            println("Money was left over in the treasury which you did")
            println("not spend.  As a result some of your countrymen died")
            println("of starvation.  The public is enraged and you have")
            println("been forced to either resign or commit suicide.")
            println("The choice is yours.")
            println("If you choose the latter, please turn off your computer")
            println("before proceeding.")
            stop()
        }
    }
    
    //Lines 1570-1580
    private func finalDisposition() -> Never {
        if rnd(1) < 0.5 {
            println("You have been assassinated.")
        } else {
            println("You have been thrown out of office and you are now")
            println("residing in prison.")
        }
        stop()
    }
    
    //Lines 1590-1596
    private func stop() -> Never {
        println(2)
        wait(.short)
        end()
    }
    
    //Lines 1960-2040
    private func restore() {
        year = term
        while year >= term {
            year = Int(input("How many years had you been in office when interrupted")) ?? -1
            if year >= term {
                println("   Come on, your term in office is only \(term) years.")
            }
        }
        guard year > 0 else { stop() }
        
        cash = Int(input("How much did you have in the treasury")) ?? -1
        if cash < 0 { stop() }
        
        population = Int(input("How many countrymen")) ?? -1
        if population < 0 { stop() }

        workers = Int(input("How many workers")) ?? -1
        if workers < 0 { stop() }

        totalLand = 0
        while totalLand <= 1000 || totalLand > 2000 {
            totalLand = Int(input("How many sq. mile of land")) ?? -1
            if totalLand < 0 { stop() }
            if totalLand <= 1000 || totalLand > 2000 {
                println("   Come on, you started with 1000 sq. miles of farm land")
                println("   and 1000 sq. miles of forest land.")
            }
        }
    }
}
