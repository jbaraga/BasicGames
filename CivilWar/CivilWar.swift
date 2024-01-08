//
//  CivilWar.swift
//  CivilWar
//
//  Created by Joseph Baraga on 12/21/23.
//

//20 REM ORIGINAL GAME DESIGN: CRAM, GOODIE, HIBBARD LEXINGTON H.S.
//30 REM MODIFICATIONS: G. PAUL, R. HESS (TIES) 1973


import Foundation


class CivilWar: GameProtocol {
    
    
    private var battles = [HistoricalBattleData]()  //Zero indexed; original 1 indexed
    private var players = 1
    //60 REM UNION INFO ON LIKELY CONFEDERATE STRATEGY
    private var strategyPercentage = [25.0, 25.0, 25.0, 25.0]  //S() - trategy percentage by index
        
    //Allocations, maintained outside of main loop to allow reuse of prior
    private var south = Army(name: "Confederacy")
    private var north = Army(name: "Union")
    private var southWins = 0  //W
    private var northWins = 0  //L
    private var draws = 0  //W0
    
    private var numberOfBattles: Int { southWins + northWins + draws }
    
    init() {
        battles = loadHistoricalData()
    }
    
    func run() {
        printHeader(title: "Civil War")
        println(4)
        
        var response = Response(input("Do you want instructions"))
        while !response.isYesOrNo {
            response = Response(input("Yes or no -- "))
        }

        if response.isYes {
            printInstructions()
        }

        //Lines 370-450
        println(4)
        print("Are there two generals present ")
        response = Response.other
        while !response.isYesOrNo {
            response = Response(input("(answer yes or no)"))
        }
        if response.isNo {
            println()
            println("      You are the Confederacy.  Good Luck!")
        }
        players = response.isYes ? 2 : 1  //Number of players
        
        //Lines 460-590
        println("Select a battle by typing a number from 1 to 14 on")
        println("request.  Type any other number to end the simulation.")
        println("But '0' brings back exact previous battle situation")
        println("allowing you to replay it")
        println()
        println("Note: a negative food$ entry causes the program to")
        println("use entries from the previous battle")
        println()
        println("After requesting a battle, do you wish battle descriptions")
        response = .other
        while !response.isYesOrNo {
            response = Response(input("(answer yes or no)"))
        }
                
        //Main loop
        var index = 0
        while let a = selectBattle() {
            if a == 0 {
                if index == 0 { endWar() }
            } else {
                index = a
            }
            
            let battle = battles[index - 1]
            let isReplay = a == 0
            
            if !isReplay {
                println(5)
                println("This is the battle of " + battle.name)
                if response.isYes { println(battle.description) }
            } else {
                println(battle.name + " instant replay")
            }
            
            //Lines 970-1070 - set initial conditions
            let menSouth = battle.menSouth  //M1 - men South
            let menNorth = battle.menNorth  //M2 - men North

            //970 REM Inflation calculation
            let i1 = 10.0 + Double(northWins - southWins) * 2  //inflation South
            let i2 = 10.0 + Double(southWins - northWins) * 2  //inflation North
            
            //1000 REM - Money available
            let d1 = 100 * Int((menSouth * (100 - i1) / 2000) * (1 + (south.r - south.expenditures) / (south.r + 1)) + 0.5)
            let d2 = players == 2 ? 100 * Int((menNorth * (100 - i2) / 2000) * (1 + (north.r - north.expenditures) / (north.r + 1)) + 0.5) : 100 * Int(menNorth * (100 - i2) / 2000 + 0.5)
            
            //1050 REM - Men available
            let m5 = floor(menSouth * (1 + (south.actualLosses - south.simulatedLosses) / (south.totalMen + 1)))
            let m6 = floor(menNorth * (1 + (north.actualLosses - north.simulatedLosses) / (north.totalMen + 1)))
            
            let f1 = 5 * menSouth / 6  //F1 - line 1080 - South
            let f2 = 5 * menNorth / 6  //F1 equivalent for North, not in original code

            //Lines 1150-1195
            println()
            println(" ", "Confederacy", "Union")
            println("Men", "  \(Int(m5))", "  \(Int(m6))")
            println("Money", "$ \(d1)", "$ \(d2)")
            println("Inflation", "  \(Int(i1 + 15)) %", "  \(Int(i2)) %")
            println()
            //1200 REM - only in printout is confed inflation = i1 + 15%
            
            //Lines 1210-1540 - allocations
            if players == 2 { print("Confederate General---") }
            println("How much do you wish to spend for")
            south.allocations = getAllocations(totalDollars: d1, isFirstBattle: numberOfBattles == 0)
            println()
            
            if players == 2 {
                print("Union General---")
                println("How much do you wish to spend for")
                north.allocations = getAllocations(totalDollars: d2, isFirstBattle: numberOfBattles == 0)
                println()
            }
            
            //1610 REM - FIND MORALE
            //moraleSouth == O in 1 player mode, O(1) in 2 player mode
            //moraleNorth is only set O(2) and used in two player mode
            let moraleSouth = south.morale(f1: f1)  //O
            let moraleNorth = north.morale(f1: f1)  //O2 - in original uses F1 for South to compute morale for North - ?bug
            if players == 2 {
                println("Confederate " + moraleString(for: moraleSouth))
                println("      Union " + moraleString(for: moraleNorth))
                print("Confederate General---")
            } else {
                println(moraleString(for: moraleSouth))
            }
            
            //1760 REM - ACTUAL OFF/DEF BATTLE SITUATION
            switch battle.m {
            case 1: println("You are on the defensive")
            case 2: println("Both sides are on the offensive")
            case 3: println("You are on the offensive")
            default: fatalError("Invalid M")
            }
            println()
            
            //1850 REM - CHOOSE STRATEGIES
            let strategySouth = getStrategy(for: players == 1 ? "Your" : "Confederate")  //Y1
            let strategyNorth = players == 2 ? getStrategy(for: "Union") : computeStrategy(isReplay: isReplay)  //Y2
            
            //Bug? in original - if 2 player mode, north not allowed to surrender; if south surrenders, battle continues
//            if players == 1, strategySouth == 5 {
//                endWar(southSurrender: strategySouth == 5, northSurrender: strategyNorth == 5)
//            }
            
            //Bug fix - either side or both can surrender - replaces lines 1960-1970 and 2060
            if strategySouth == 5 || strategyNorth == 5 {
                endWar(southSurrender: strategySouth == 5, northSurrender: strategyNorth == 5)
            }
            
            //Casualties
            var casualtiesSouth = 0.0  //C5
            var casualtiesNorth = 0.0  //C6
                        
            //Desertions
            var desertionsSouth = 0.0  //E
            var desertionsNorth = 0.0  //E2
            
            //Flags for excessive losses
            var excessiveLossesSouth = false  //U - South
            var excessiveLossesNorth = false  //U2 - North
            
            //2170 REM - CALCULATE SIMULATED LOSSES
            //Lines 2200-2260 Confederacy
            casualtiesSouth = (2 * Double(battle.lossesSouth) / 5) * (1 + 1 / (2 * (abs(Double(strategyNorth - strategySouth)) + 1)))
            casualtiesSouth = round(casualtiesSouth * (1 + 1 / moraleSouth) * (1.28 + f1 / (Double(south.ammunition) + 1)))
            desertionsSouth = 100 / moraleSouth
            
            //If excessive loss, rescale - uses different logic/calculation than North
            if casualtiesSouth + desertionsSouth >= menSouth * (1 + (south.actualLosses - south.simulatedLosses) / (south.totalMen + 1)) {
                casualtiesSouth = floor(13 * menSouth / 20 * (1 + (south.actualLosses - south.simulatedLosses) / (south.totalMen + 1)))
                desertionsSouth = 7 * casualtiesSouth / 13
                excessiveLossesSouth = true
            }
            
            if players == 1 {
                //Lines 2500-2510
                casualtiesNorth = floor(17 * battle.lossesNorth * battle.lossesSouth / (casualtiesSouth * 20))
                desertionsNorth = 5 * moraleSouth  //5*O
            } else {
                //Lines 2070-2160
                //2070 REM: SIMULATED LOSSES-NORTH
                casualtiesNorth = (2 * battle.lossesNorth / 5) * (1 + 1 / (2 * (abs(Double(strategyNorth - strategySouth)) + 1)))
                casualtiesNorth = round(casualtiesNorth * (1 + 1 / moraleNorth) * (1.28 + f2 / (Double(north.ammunition) + 1)))  //Lines 2090 2100 combined, to mirror confed calculation line 2210
                desertionsNorth = 100 / moraleNorth
                
                //2110 REM - IF LOSS > MEN PRESENT, RESCALE LOSSES
                if casualtiesNorth + desertionsNorth >= m6 {
                    casualtiesNorth = floor(13 * m6 / 20)
                    desertionsNorth = 7 * casualtiesNorth / 13
                    excessiveLossesNorth = true
                }
            }
            
            println()
            println(" ", "Confederacy", "Union")
            println("Casualties", Int(casualtiesSouth), Int(casualtiesNorth))
            println("Desertions", Int(desertionsSouth), Int(desertionsNorth))
            println()
            
            if players == 1 {
                //Lines 2530-2630
                println("Your casualties were \(Int(round(100 * casualtiesSouth / Double(battle.lossesSouth)))) % of ")
                println("the actual casualties at " + battle.name)
                println()
                //2560 REM - FIND WHO WON
                if excessiveLossesSouth || casualtiesSouth + desertionsSouth >= 17 * Double(battle.lossesNorth * battle.lossesSouth) / (casualtiesSouth * 20) + 5 * moraleSouth {
                    println("You lose " + battle.name)
                    if !isReplay { northWins += 1 }
                } else {
                    println("You win " + battle.name)
                    if !isReplay { southWins += 1 }
                }
            } else {
                //Lines 2320-2490
                println("Compared to the actual casualties at " + battle.name)
                println("Confederate: \(Int(round(100 * casualtiesSouth / Double(battle.lossesSouth)))) % of the original")
                println("Union:       \(Int(round(100 * casualtiesNorth / Double(battle.lossesNorth)))) % of the original")
                println()
                
                //2360 REM - 1 WHO ONE
                switch (excessiveLossesSouth, excessiveLossesNorth) {
                case (true, true):
                    println("Battle outcome unresolved")
                    draws += 1  //Draws are tallied even for replay - bug?
                case (true, false):
                    println("The Union wins " + battle.name)
                    if !isReplay { northWins += 1 }
                case (false, true):
                    println("The Confederacy wins " + battle.name)
                    if !isReplay { southWins += 1 }
                default:
                    if casualtiesSouth + desertionsSouth == casualtiesNorth + desertionsNorth {
                        println("Battle outcome unresolved")
                        draws += 1
                    } else if casualtiesSouth + desertionsSouth > casualtiesNorth + desertionsNorth {
                        println("The Union wins " + battle.name)
                        if !isReplay { northWins += 1 }
                    } else {
                        println("The Confederacy wins " + battle.name)
                        if !isReplay { southWins += 1 }
                    }
                }
            }
            
            //2640 REM - CUMULATIVE BATTLE FACTORS WHICH ALTER HISTORICAL
            //2650 REM   RESOURCES AVAILABLE. IF A REPLAY DON'T UPDATE.
            if !isReplay {
                south.simulatedLosses += casualtiesSouth + desertionsSouth
                north.simulatedLosses += casualtiesNorth + desertionsNorth
                south.actualLosses += battle.lossesSouth
                north.actualLosses += battle.lossesNorth
                south.expenditures += Double(south.food + south.salaries + south.ammunition)
                north.expenditures += Double(north.food + north.salaries + north.ammunition)
                south.r += menSouth * (100 - i1) / 20
                north.r += menNorth * (100 - i2) / 20
                south.totalMen += menSouth
                north.totalMen += menNorth
                updateNorthStrategy(for: strategySouth)
            }
            
            println("---------------")
        }
        
        endWar()
    }
    
    //Lines 170-360
    private func printInstructions() {
        println(4)
        println("This is a Civil War simulation.")
        println("To play, type a response when the computer asks.")
        println("Remember that all factors are interrelated and that your")
        println("responses could change history. Facts and figures used are")
        println("based on the actual occurrence. Most battles tend to result")
        println("as they did in the Civil War, but it all depends on you!!")
        println()
        println("The object of the game is to win as many battles as possible.")
        println()
        println("Your choices for defensive strategy are:")
        println("        (1) artillery attack")
        println("        (2) fortification against frontal attack")
        println("        (3) fortification against flanking maneuvers")
        println("        (4) falling back")
        println(" Your choices for offensive strategy are:")
        println("        (1) artillery attack")
        println("        (2) frontal attack")
        println("        (3) flanking maneuvers")
        println("        (4) encirclement")
        println("You may surrender by typing a '5' for your strategy.")
    }
    
    //Lines 620-665
    private func selectBattle() -> Int? {
        println(4)
        guard let a = Int(input("Which battle do you wish to simulate")), a <= battles.count, a >= 0 else { return nil }
        return a
    }
        
    //Lines 1210-1540 allocations
    private func getAllocations(totalDollars: Int, isFirstBattle: Bool) -> (food: Int, salaries: Int, ammunition: Int) {
        var food = -1
        while food <= 0 {
            food = Int(input(" - food...... ")) ?? -1
            if food <= 0 {
                if isFirstBattle {
                    println("No previous entries")
                } else {
                    println("Assume you want to keep same allocations")
                    return (0,0,0)
                }
            }
        }
        
        var salaries = -1
        while salaries < 0 {
            salaries = Int(input(" - salaries.. ")) ?? -1
            if salaries < 0 { println("Negative values are not allowed.") }
        }
        
        var ammunition = -1
        while ammunition < 0 {
            ammunition = Int(input(" - ammunition ")) ?? -1
            if ammunition < 0 { println("Negative values are not allowed.") }
        }
        
        if food + salaries + ammunition > totalDollars {
            println("Think again! You have only $ \(totalDollars)")
            return getAllocations(totalDollars: totalDollars, isFirstBattle: isFirstBattle)
        } else {
            return (food, salaries, ammunition)
        }
    }
    
    //Lines 1630-1690
    private func moraleString(for morale: Double) -> String {
        if morale < 5 {
            return "Morale is poor"
        } else if morale < 10 {
            return "Morale is fair"
        } else {
            return "Morale is high"
        }
    }
    
    //Lines 1870-2030
    private func getStrategy(for side: String) -> Int {
        let y = Int(input(side + " strategy ")) ?? 0
        guard y > 0 && y < 6 else {
            println("Strategy \(y) is not allowed.")
            return getStrategy(for: "Your")
        }
//        if side == "Union", y == 5 { return getStrategy(for: "Union") } //Line 2060 - Union not allowed to surrender in 2 player mode - fixed
        return y
    }
    
    //2820 REM------FINISH OFF
    //Lines 2830-3100
    private func endWar(southSurrender: Bool = false, northSurrender: Bool = false) {
        if southSurrender { println("The Confederacy has surrendered.") }
        if northSurrender { println("The Union has surrendered.") }  //This should never execute; North is not allowed to surrender - line 2060 - bug?
        println(6)
        println("The Confederacy has won \(southWins) battles and lost \(northWins)")
        if southSurrender && !northSurrender {
            println("The Union has won the war")
        } else if northSurrender && !southSurrender {
            println("The Confederacy has won the war")
        } else if southWins > northWins {
            println("The Confederacy has won the war")
        } else {
            println("The Union has won the war")  //Tie goes to Union, or if both surrender (which cannot happen)
        }
        
        //Line 2960 - ?no stats if no battles - i.e. immediate south surrender
        if south.r > 0 {
            println("For the \(numberOfBattles) battles fought (excluding reruns)")
            println("                 ", "Confederacy", " Union")
            println("Historical Losses", "\(Int(round(south.actualLosses)))", " \(Int(round(north.actualLosses)))")
            println("Simulated  Losses", "\(Int(round(south.simulatedLosses)))", " \(Int(round(north.simulatedLosses)))")
            println()
            println("    % of Original", "\(Int(round(100 * south.simulatedLosses / south.actualLosses)))", " \(Int(round(100 * north.simulatedLosses / north.actualLosses)))")
            
            if players == 1 {
                println()
                println("Union intelligence suggests that the South used")
                println("strategies 1, 2, 3, 4 in the following percentages")
                println("\(strategyPercentage[0])", "\(strategyPercentage[1])", "\(strategyPercentage[2])", "\(strategyPercentage[3])")
            }
        }
        
        //3090 REM--------------------------
        
        wait(.short)
        println(2)
        let response = input("Hit return to exit", terminator: "")
        if response.isEasterEgg, numberOfBattles > 1 {
            showEasterEgg(.civilWar)
        }

        end()
    }
        
    //Lines 3110-3290
    //3110 REM - UNION STRATEGY IS COMPUTER CHOSEN
    private func computeStrategy(isReplay: Bool) -> Int {
        print("Union strategy is ")
        
        var strategy = 0  //Y2
        if isReplay {
            //Lines 3140-3140
            repeat {
                strategy = Int(input()) ?? 0
                if strategy > 0 && strategy < 5 { return strategy }
                strategy = 0
                println("Enter 1, 2, 3, or 4 (usually previous Union strategy)")
            } while strategy == 0
        } else {
            //Lines 3180-3280
            let r = 100 * rnd(1)
            var s0 = 0.0
            for percentage in strategyPercentage {
                s0 += percentage
                strategy += 1
                //3220 REM - IF ACTUAL STRATEGY INFO IS IN PROGRAM DATA STATEMENT
                //3230 REM   THEN R-100 IS EXTRA WEIGHT GIVEN TO THAT STRATEGY.
                if r < s0 { break }
            }
            //3260 REM - IF ACTUAL STRAT. IN, THEN HERE IS Y2 = HIST. STRAT.
            println("\(strategy)")
            return strategy
        }
        
        fatalError("computeStrategy impossible fallthrough strategy \(strategy)")
    }
    
    //Lines 3300-3410
    private func updateNorthStrategy(for southStrategy: Int) {
        //3300 REM LEARN PRESENT STRATEGY, START FORGETTING OLD ONES
        //3310 REM - PRESENT STRATEGY OF SOUTH GAINS 3*S, OTHERS LOSE S
        //3320 REM   PROBABILITY POINTS, UNLESS A STRATEGY FALLS BELOW 5%.
        let delta = 3.0  //S
        strategyPercentage = strategyPercentage.map { $0 > 5 ? $0 - delta : $0 }  //Decrease all strategies if > 5%
        strategyPercentage[southStrategy - 1] = strategyPercentage[southStrategy - 1] + (100 - strategyPercentage.reduce(0, +))  //Renormalize by increasing target strategy
    }
    
    //Lines 82-88, 3420-4000
    //3420 REM - Historical data...can add more (strat.,etc) by inserting
    //3430 REM   data statements after appro. info, and adjusting read
    private func loadHistoricalData() -> [HistoricalBattleData] {
        return [
            HistoricalBattleData(name: "Bull Run", menSouth: 18000, menNorth: 18500, lossesSouth: 1967, lossesNorth: 2708, m: 1, description: "July 21, 1861.  Gen. Beauregard, commanding the South, met\nUnion forces with Gen. McDowell in a premature battle at\nBull Run.  Gen. Jackson helped push back the Union attack."),
            HistoricalBattleData(name: "Shiloh", menSouth: 40000, menNorth: 44894, lossesSouth: 10699, lossesNorth: 13047, m: 3, description: "April 6-7, 1862.  The Confederate surprise attack at\nShiloh failed due to poor organization."),
            HistoricalBattleData(name: "Seven Days", menSouth: 95000, menNorth: 115000, lossesSouth: 20614, lossesNorth: 15849, m: 3, description: "June 25-July 1, 1862.  General Lee (CSA) upheld the\noffensive throughout the battle and forced Gen. McClellan\nand the Union forces away from Richmond."),
            HistoricalBattleData(name: "Second Bull Run", menSouth: 54000, menNorth: 63000, lossesSouth: 10000, lossesNorth: 14000, m: 2, description: "August 29-30, 1862.  The combined Confederate forces under Lee\nand Jackson drove the Union forces back into Washington."),
            HistoricalBattleData(name: "Antietam", menSouth: 40000, menNorth: 50000, lossesSouth: 10000, lossesNorth: 12000, m: 3, description: "Sept 17, 1862.  The South failed to incorporate Maryland\ninto the Confederacy."),
            HistoricalBattleData(name: "Fredericksburg", menSouth: 75000, menNorth: 120000, lossesSouth: 5377, lossesNorth: 12653, m: 1, description: "Dec 13, 1862.  The Confederacy under Lee successfully\nrepulsed an attack by the Union under Gen. Burnside."),
            HistoricalBattleData(name: "Murfreesboro", menSouth: 38000, menNorth: 45000, lossesSouth: 11000, lossesNorth: 12000, m: 1, description: "Dec 31, 1862.  The South under Gen. Bragg won a close battle."),
            HistoricalBattleData(name: "Chancellorsville", menSouth: 32000, menNorth: 90000, lossesSouth: 13000, lossesNorth: 17197, m: 2, description: "May 1-6, 1863.  The South had a costly victory and lost\none of their outstanding generals, 'Stonewall' Jackson."),
            HistoricalBattleData(name: "Vicksburg", menSouth: 50000, menNorth: 70000, lossesSouth: 12000, lossesNorth: 19000, m: 1, description: "July 4, 1863.  Vicksburg was a costly defeat for the South\nbecause it gave the Union access to the Mississippi."),
            HistoricalBattleData(name: "Gettysburg", menSouth: 72500, menNorth: 85000, lossesSouth: 20000, lossesNorth: 23000, m: 3, description: "July 1-3, 1863.  A Southern mistake by Gen. Lee at Gettysburg\ncost them one of the most crucial battles of the war."),
            HistoricalBattleData(name: "Chickamauga", menSouth: 66000, menNorth: 60000, lossesSouth: 18000, lossesNorth: 16000, m: 2, description: "Sept. 15, 1863. Confusion in a forest near Chickamauga led\nto a costly Southern victory."),
            HistoricalBattleData(name: "Chattanooga", menSouth: 37000, menNorth: 60000, lossesSouth: 36700, lossesNorth: 5800, m: 2, description: "Nov. 25, 1863. After the South had sieged Gen. Rosencrans'\narmy for three months, Gen. Grant broke the siege."),
            HistoricalBattleData(name: "Spotsylvania", menSouth: 62000, menNorth: 110000, lossesSouth: 17723, lossesNorth: 18000, m: 2, description: "May 5, 1864.  Grant's plan to keep Lee isolated began to\nfail here, and continued at Cold Harbor and Petersburg."),
            HistoricalBattleData(name: "Atlanta", menSouth: 65000, menNorth: 100000, lossesSouth: 8500, lossesNorth: 3700, m: 1, description: "August, 1864.  Sherman and three veteran armies converged\non Atlanta and dealt the death blow to the Confederacy.")
        ]
    }
    
    private struct HistoricalBattleData {
        let name: String  //C$
        let menSouth: Double  //M1
        let menNorth: Double  //M2
        let lossesSouth: Double  //C1
        let lossesNorth: Double  //C2
        let m: Int
        let description: String
    }
    
    private struct Army {
        let name: String
        
        //Allocations for each round, stored for reuse
        var food = 0  //f
        var salaries = 0  //h
        var ammunition = 0  //b
        
        //Cumulative battle factors which alter historical resources available
        var totalMen = 0.0  //M3, M4 - cumulative men
        var actualLosses = 0.0  //P1, P2 - cumulative historical losses (casualites and desertions)
        var simulatedLosses = 0.0  //T1, T2 - cumulative simulated losses
        var expenditures = 0.0  //Q1, Q2 - cumulative allocation expenditures
        var r = 0.0  //R1, R2 - ?Cumulative inflation adjusted target expenditures for #of men (M1,M2)
        
        var allocations: (food: Int, salaries: Int, ammunition: Int) {
            get { (food, salaries, ammunition) }
            set { set(allocations: newValue) }
        }
        
        mutating func set(allocations: (food: Int, salaries: Int, ammunition: Int)) {
            guard allocations.food > 0 else { return }  //Choice of 0 for food = use previous allocations
            food = allocations.food
            salaries = allocations.salaries
            ammunition = allocations.ammunition
        }
        
        //Original code, morale for both sides calculated from F1 computed from South only - assumed bug
        func morale(f1: Double) -> Double {
            Double(2 * food * food + salaries * salaries) / (f1 * f1) + 1
        }
    }
}
