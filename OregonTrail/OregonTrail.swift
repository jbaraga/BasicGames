//
//  OregonTrail.swift
//  OregonTrail
//
//  Created by Joseph Baraga on 10/30/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation


class OregonTrail: GameProtocol {
    private enum ShootingLevel: Int {
        case unspecified = 0
        case ace = 1
        case good = 2
        case fair = 3
        case needPractice = 4
        case shaky = 5
        
        var value: Int {
            return self.rawValue
        }
        
        init(_ level: Int) {
            self = ShootingLevel(rawValue: level) ?? .unspecified
        }
    }
    
    private enum TurnChoice {
        case fort
        case hunt
        case `continue`
    }
    
    private let delayAfterInput = 0.5  //Seconds after hitting return
    private let TotalCash = 700
    
    //10 REM PROGRAM NAME - OREGON        VERSION:01/01/78
    //20 REM ORIGINAL PROGRAMMING BY BILL HEINEMANN - 1971
    //30 REM SUPPORT RESEARCH AND MATERIALS BY DON RAWITSCH,
    //40 REM      MINNESOTA EDUCATIONAL COMPUTING CONSORTIUM STAFF
    //50 REM CDC CYBER 70/73-26     BASIC 3.1
    //60 REM DOCUMENTATION BOOKLET 'OREGON' AVAILABLE FROM
    //61 REM    MECC SUPPORT SERVICES
    //62 REM    2520 BROADWAY DRIVE
    //63 REM    ST. PAUL, MN  55113
    //80 REM
    //150 REM  *FOR THE MEANING OF THE VARIABLES USED, LIST LINES 6470-6790*
    //155 REM
    
    func run() {
        printHeader(title: Game.oregonTrail.title)
        println(2)
        
        var response = ""
        repeat {
            response = input("Do you need instructions (Yes/No)")
            if response.isYes {
                println()
                showInstructions()
                wait(.long)
            }
        } while !(response.isNo || response.isYes)
        
        playGame()
    }
        
    //MARK: Main program
    private func playGame() {
        //Initialize game
        var animals = 0  //A - amount spent on animals
        var ammunition = 0  //B - ammount spent on ammunition
        var clothing = 0 //C - amount spend on clothing
        var food = 0 //F - amount spent on food
        var supplies = 0  //M1 - amount spent on miscellaneous supplies
        var cash = 0 //T - cash left over after initial purchase
        
        var foodChoice = 0  //E
        
        var eventCounter = 0  //D1 - counter in generating events
        var turnCounter = 0 //D3 - turn number for setting date
        var eventRandomNumber = 0  //R1 - random number in choosing events
        
        var mileageThroughPreviousTurn = 0 //M2 - total mileage up through previous turn
        var totalMileage = 0  //M - total mileage whole trip
        var fractionOfTwoWeeksTraveledFinalTurn = 0.0  //F9
        
        var shootingLevel = ShootingLevel.unspecified  //D9 - shooting expertise level
        var ridersAreHostile = false  //S5 - hostility of riders factor
        var tacticalChoice = 0  //T1 - choice of tactics when attacked
        
        var insufficientClothing = false  //C1 - flag for insufficient clothing in cold weather
        var clearedSouthPass = false  //F1 - flag for clearing South Pass
        var clearedSouthPassInSettingMileage = false  //M9 - flag for clearing South Pass in setting mileage
        var clearedBlueMountains = false  //F2 - flag for clearing Blue Mountains
        var injury = false  //K8 - flag for injury
        var seriousIllness = false  //S4 - flag for illness
        var blizzard = false  //L1 - flag for blizzard
        var showFortOption = false  //X1 - flag for fort option

        println(2)
        shootingLevel = getMarksmanshipLevel()
        initialPurchase()

        //Turn loop
        while turnCounter < 20 {
            wait(.long)
            if totalMileage >= 2040 {
                finalTurn()
                return
            }
            
            println()
            if let date = date(for: turnCounter) {
                println(date)
            } else {
                println("You have been on the trail too long ------")
                println("Your family dies in the first blizzard of winter")
                failure()
                return
            }
            println()

            turnCounter += 1
            
            if food < 0 { food = 0 }
            if ammunition < 0 { ammunition = 0 }
            if clothing < 0 { clothing = 0 }
            if supplies < 0 { supplies = 0 }
            if food < 13 {
                println("You'd better do some hunting or buy food and soon!!!!")
            }
            
            mileageThroughPreviousTurn = totalMileage
            
            //Illness or injury - pay for doctor
            if injury || seriousIllness {
                cash = cash - 20
                if cash < 0 {
                    cannotAffordDoctor()
                    return
                }
                
                println("Doctor's bill is $20")
                injury = false
                seriousIllness = false
            }
            
            if clearedSouthPassInSettingMileage {
                println("Total mileage is 950")
                clearedSouthPassInSettingMileage = false
            } else {
                println("Total mileage is \(totalMileage)")
            }
            
            showInventory()
            wait(.long)

            //Turn, lines 2060-2270
            //Toggle - fort option available every other turn
            let choice = getTurnChoice()  //option 1 stop at fort, 2 hunt, 3 continue
            showFortOption = !showFortOption
            
            switch choice {
            case .fort:
                fort()
            case .hunt:
                hunt()
            case .continue:
                break
            }
            
            //Lines 2720-2730
            if food < 13 {
                outOfFood()
                return
            } else {
                foodChoice = eat() ?? 0
            }
            
            wait(.short)
            
            //Move forward, lines 2860-2870
            totalMileage += Int(200 + (Double(animals) - 220) / 5 + 10 * rnd())
            blizzard = false
            insufficientClothing = false
            
            //Possible riders encounter, lines 2880-2890
            if rnd() * 10 <= (pow(Double(totalMileage) / 100 - 4, 2.0) + 72) / (pow(Double(totalMileage) / 100 - 4, 2.0) + 12) - 1 {
                ridersAttack()
                wait(.short)
            }
            
            selectEvent()
            
            wait(.short)

            //Line 4710
            if totalMileage > 950 {
                mountains()
            }
        }
        
        //Fallthrough - used up all turns
        println("You have been on the trail too long ------")
        println("Your family dies in the first blizzard of winter")
        failure()
        
        //MARK: Subroutines
        func showInventory() {
            println("Food", "Bullets", "Clothing", "Misc. Supp.", "Cash", tabInterval: 15)
            println(" \(food)", " \(ammunition)", " \(clothing)", " \(supplies)", " \(cash)", tabInterval: 15)
        }
        
        //Initial purchase, lines 800-1180
        func initialPurchase() {
            println()
            animals = 0
            while animals < 200 || animals > 300 {
                if let amount = Int(input("How much do you want to spend on your oxen team")) {
                    animals = amount
                }
                if animals < 200 {
                    println("Not enough")
                }
                if animals > 300 {
                    println("Too much")
                }
            }
            
            food = -1
            while food < 0 {
                if let amount = Int(input("How much do you want to spend on food")) {
                    food = amount
                }
                if food < 0 {
                    println("Impossible")
                }
            }
            
            ammunition = -1
            while ammunition < 0 {
                if let amount = Int(input("How much do you want to spend on ammunition")) {
                    ammunition = amount
                }
                if ammunition < 0 {
                    println("Impossible")
                }
            }
            
            clothing = -1
            while clothing < 0 {
                if let amount = Int(input("How much do you want to spend on clothing")) {
                    clothing = amount
                }
                if clothing < 0 {
                    println("Impossible")
                }
            }
            
            supplies = -1
            while supplies < 0 {
                if let amount = Int(input("How much do you want to spend on miscellaneous supplies")) {
                    supplies = amount
                }
                if supplies < 0 {
                    println("Impossible")
                }
            }
            
            cash = TotalCash - (animals + food + ammunition + clothing + supplies)
            
            if cash < 0 {
                println("You overspent--you only had $700 to spend.  Buy again")
                initialPurchase()
            } else {
                println("After all your purchases, you now have \(cash) dollars left")
                ammunition = 50 * ammunition  //Converts to number of bullets
            }
        }

        //Line 2060-2260
        //Default choice is continue
        func getTurnChoice() -> TurnChoice {
            if showFortOption {
                println("Do you want to (1) stop at the next fort, (2) hunt,")
                println("or (3) continue")
            } else {
                println("Do you want to (1) hunt, or (2) continue")
            }
            guard var selection = Int(input()) else { return .continue }
            
            //Duplicates original logic - fort = 1, hunt = 2, else continue
            if !showFortOption { selection += 1 }
            switch selection {
            case 1:
                return .fort
            case 2:
                if ammunition < 40 {
                    println("Tough---you need more bullets to go hunting")
                    return getTurnChoice()
                } else {
                    return .hunt
                }
            default:
                return .continue
            }
        }
        
        //Fort, lines 2280-2520
        func fort() {
            func getAmount() -> Int {
                guard let amount = Int(input()), amount > 0 else { return 0 }
                if amount > cash {
                    println("You don't have that much--keep your spending down")
                    println("You miss your chance to spend on that item")
                    return 0
                }
                cash -= amount
                return amount
            }
            
            println("Enter what you wish to spend on the following")

            print("Food")
            food += Int(Double(getAmount()) * (2.0 / 3.0))
            
            print("Ammunition")
            ammunition += Int(Double(getAmount()) * (2.0 / 3.0) * 50)

            print("Clothing")
            clothing += Int(Double(getAmount()) * (2.0 / 3.0))

            print("Miscellaneous supplies")
            supplies += Int(Double(getAmount()) * (2.0 / 3.0))
        }
        
        //Hunt, lines 2530-2710
        func hunt() {
            totalMileage -= 45
            let responseTime = shoot(shootingLevel)
            
            if responseTime <= 1 {
                //Add bells
                println("Right between the eyes---you got a big one!!!!")
                println("Full bellies tonight!")
                food += 52 + Int(rnd() * 6)
                ammunition -= (10 + Int(rnd() * 4))
                return
            }
            
            if 100 * rnd() < 13 * responseTime {
                println("You missed---and your dinner got away.....")
            } else {
                food += 48 - Int(2 * responseTime)
                println("Nice shot--Right on target--Good eatin' tonight!!")
                ammunition -= (10 + Int(3 * responseTime))
            }
        }
        
        //Lines 2740-2870
        func eat() -> Int? {
            println("Do you want to eat (1) poorly  (2) moderately")
            print("or (3) well")
            
            guard let foodChoice = Int(input()), foodChoice > 0 && foodChoice < 4 else {
                return eat()
            }
            
            let foodRequested = 8 + 5 * foodChoice
            if foodRequested > food {
                println("You can't eat that well")
                return eat()
            }
            
            food -= foodRequested
            return foodChoice
        }
        
        //Lines 2900-3530
        func ridersAttack() {
            if rnd() < 0.8 {
                println("Riders ahead. They look hostile")
                ridersAreHostile = true
            } else {
                println("Riders ahead. They don't look hostile")
                ridersAreHostile = false
            }
            
            println("Tactics")
            tacticalChoice = 0
            while tacticalChoice < 1 || tacticalChoice > 4 {
                println("(1) Run,  (2) Attack,  (3) Continue,  (4) Circle wagons")
                if rnd() < 0.2 {
                    ridersAreHostile = !ridersAreHostile
                }
                
                tacticalChoice = Int(input()) ?? 0
            }
            
            func shootingResult(_ responseTime: Double) {
                switch responseTime {
                case _ where responseTime <= 1:
                    println("Nice shooting---you drove them off")
                case _ where responseTime > 4:
                    println("Lousy shot---you got knifed")
                    injury = true
                    println("You have to see Ol' Doc Blanchard")
                default:
                    println("Kinda slow with your Colt .45")
                }
            }
           
            if ridersAreHostile {
                switch tacticalChoice {
                case 1:
                    totalMileage += 20
                    supplies -= 15
                    ammunition -= 150
                    animals -= 40
                case 2:
                    let responseTime = shoot(shootingLevel)
                    ammunition -= Int(responseTime * 40 + 80)
                    shootingResult(responseTime)
                case 3:
                    if rnd() >= 0.8 {
                        println("They did not attack")
                        return
                    } else {
                        ammunition -= 150
                        supplies -= 15
                    }
                case 4:
                    let responseTime = shoot(shootingLevel)
                    ammunition -= Int(responseTime * 30 + 80)
                    totalMileage -= 25
                    shootingResult(responseTime)
                default:
                    break
                }
            } else {
                switch tacticalChoice {
                case 1:
                    totalMileage += 15
                    animals -= 10
                case 2:
                    totalMileage -= 5
                    ammunition -= 100
                case 3:
                    break
                case 4:
                    totalMileage -= 20
                default:
                    break
                }
            }
            
            if ridersAreHostile {
                println("Riders were hostile--check for losses")
                if ammunition < 0 {
                    println("You rand out of bullets and got massacred by the riders")
                    failure()
                }
            } else {
                println("Riders were friendly, but check for possible losses")
            }
        }
        
        //Lines 3540-4690
        func selectEvent() {
            eventCounter = 0
            eventRandomNumber = Int.random(in: 0...100)
            let data = [6, 11, 13, 15, 17, 22, 32, 35, 37, 42, 44, 54, 64, 69, 95]
            while eventCounter < 15 {
                if eventRandomNumber < data[eventCounter] {
                    break
                }
                eventCounter += 1
            }
            
            switch eventCounter {
            case 0:
                //Line 3660
                println("Wagon breaks down--lose time and supplies fixing it")
                totalMileage -= Int(15 + 5 * rnd())
                supplies -= 8
            case 1:
                //Line 3700
                println("Ox injures leg---slows you down rest of trip")
                totalMileage -= 25
                animals -= 20
            case 2:
                //Line 3740
                println("Bad luck---your daughter broke her arm")
                println("You had to stop and use supplies to make a sling")
                totalMileage -= Int(5 + 4 * rnd())
                supplies -= Int(2 + 3 * rnd())
            case 3:
                //Line 3790
                println("Ox wanders off---spend time looking for it")
                totalMileage -= 17
            case 4:
                //Line 3820
                println("Your son gets lost---spend half the day looking for him")
                totalMileage -= 10
            case 5:
                //Line 3850
                println("Unsafe water--lose time looking for clean spring")
                totalMileage -= Int(10 * rnd() + 2)
            case 6:
                //Line 3880
                if totalMileage > 950 {
                    if clothing <= Int(22 * 4 * rnd()) {
                        insufficientClothing = true
                    }
                    print("Cold weather---Brrrrrrrr!---You")
                    print(insufficientClothing ? " dont't " : " ")
                    println("have enough clothing to keep you warm")
                    if insufficientClothing {
                        illness()
                    }
                } else {
                    println("Heavy rains---time and supplies lost")
                    food -= 10
                    ammunition -= 500
                    supplies -= 15
                    totalMileage -= Int(10 * rnd() + 5)
                }
            case 7:
                //Line 3960
                println("Bandits attack")
                let responseTime = shoot(shootingLevel)
                ammunition -= Int(20 * responseTime)
                if ammunition < 0 {
                    println("You ran out of bullets---they got lots of cash")
                    cash = Int(Double(cash) / 3)
                }
                
                if ammunition < 0 || responseTime > 1 {
                    println("You got shot in the leg and they took one of your oxen")
                    injury = true
                    println("Better have a doc look at our wound")
                    supplies -= 5
                    animals -= 20
                } else {
                    println("Quickest draw outside of Dodge City!!!")
                    println("You got 'em!")
                }
            case 8:
                //Line 4130
                println("There was a fire in your wagon--food and supplies damage!")
                food -= 40
                ammunition -= 400
                supplies -= Int(rnd() * 8 + 3)
            case 9:
                //Line 4190
                println("Lose your way in heavy fog---time is lost")
                totalMileage -= Int(10 + 5 * rnd())
            case 10:
                //Line 4220
                println("You killed a poisonous snake after it bit you")
                ammunition -= 10
                supplies -= 5
                if supplies < 0 {
                    println("You die of snakebite since you have no medicine")
                    failure()
                }
            case 11:
                //Line 4290
                println("Wagon gets swamped fording river--lose food and clothes")
                food -= 30
                clothing -= 20
                totalMileage -= Int(20 + 20 * rnd())
            case 12:
                //Line 4340
                println("Wild animals attack!")
                let responseTime = shoot(shootingLevel)
                
                if ammunition < 40 {
                    println("You were too low on bullets--")
                    println("The wolves overpowered you")
                    died(ofInjury: true)
                }
                
                if responseTime > 2 {
                    println("Slow on the draw---they got at your food and clothes")
                    ammunition -= Int(20 * responseTime)
                    clothing -= Int(responseTime * 4)
                    food -= Int(responseTime * 8)
                } else {
                    println("Nice shootin' partner---they didn't get much")
                }
            case 13:
                //Line 4560
                println("Hail storm---supplies damaged")
                totalMileage -= Int(5 + rnd() * 10)
                ammunition -= 200
                supplies -= Int(4 + rnd() * 3)
            case 14:
                //Line 4610
                switch foodChoice {
                case 1:
                    illness()
                case 2:
                    if rnd() > 0.25 {
                        illness()
                    }
                case 3:
                    if rnd() < 0.5 {
                        illness()
                    }
                default:
                    break
                }
            default:
                //eventCounter = 15 or 16
                //Line 4670
                println("Helpful Indians show you where to find more food")
                food += 14
            }
        }
        
        //Lines 4700-4960
        func mountains() {
            if rnd() * 10 <= 9 - (pow(Double(totalMileage / 100 - 15), 2.0) + 72) / (pow(Double(totalMileage / 100 - 15), 2.0) + 12) {
                println("Rugged mountains")
                if rnd() <= 0.1 {
                    println("You got lost---lose valuable time trying to find trail!")
                    totalMileage -= 60
                } else {
                    if rnd() <= 0.11 {
                        println("Wagon damaged!---lose time and supplies")
                        supplies -= 5
                        ammunition -= 200
                        totalMileage -= Int(20 + 30 * rnd())
                    } else {
                        println("The going gets slow")
                        totalMileage -= Int(45 + rnd() / 0.02)
                    }
                }
            }
            
            //Line 4860
            if !clearedSouthPass {
                clearedSouthPass = true
                if rnd() < 0.8 {
                    blizzard = true
                } else {
                    println("You made it safely through South Pass--no snow")
                    if totalMileage >= 1700 && !clearedBlueMountains {
                        clearedBlueMountains = true
                        if rnd() < 0.7 {
                            blizzard = true
                        }
                    }
                }
                
                if blizzard {
                    blizzardHits()
                }
            }
            
            //Line 4940
            if totalMileage <= 950 {
                clearedSouthPassInSettingMileage = true
            }
        }
        
        //Lines 4970-5040
        func blizzardHits() {
            println("Blizzard in mountain pass--time and supplies lost")
            food -= 25
            supplies -= 10
            ammunition -= 300
            totalMileage -= Int(30 + 40 * rnd())
            if clothing < Int(18 + 2 * rnd()) {
                illness()
            }
        }

        //Final turn, lines 5420-6120
        func finalTurn() {
            fractionOfTwoWeeksTraveledFinalTurn =
                Double(2040 - mileageThroughPreviousTurn) / Double(totalMileage - mileageThroughPreviousTurn)
            food = food + Int((1.0 - fractionOfTwoWeeksTraveledFinalTurn) * Double(8 + 5 * foodChoice))
            
            println()
            //Generate beep for next two lines
            consoleIO.ringBell()
            println("You finally arrived at Oregon City")
            consoleIO.ringBell()
            println("After 2040 long miles---HOORAY!!!")
            println("A real pioneer!")
            println()
            
            let daysTraveledLastTwoWeeks = Int(fractionOfTwoWeeksTraveledFinalTurn * 14)
            let totalDays = turnCounter * 14 + daysTraveledLastTwoWeeks
            
            //Calculate date and day of week
            let day: String
            switch daysTraveledLastTwoWeeks {
            case 0, 7:
                day = "Monday"
            case 1, 8:
                day = "Tuesday"
            case 2, 9:
                day = "Wednesday"
            case 3, 10:
                day = "Thursday"
            case 4, 11:
                day = "Friday"
            case 5, 12:
                day = "Saturday"
            case 6, 13:
                day = "Sunday"
            default:
                day = ""
            }
            
            let date: String
            switch totalDays {
            case 92...124:
                date = "July \(totalDays - 93)"
            case 125...155:
                date = "August \(totalDays - 124)"
            case 156...185:
                date = "September \(totalDays - 155)"
            case 186...216:
                date = "October \(totalDays - 185)"
            case 217...246:
                date = "November \(totalDays - 216)"
            case 247...277:
                date = "December \(totalDays - 246)"
            default:
                date = ""
            }
            
            println(day + " " + date + " 1847")
            println()
            
            if ammunition < 0 { ammunition = 0 }
            if food < 0 { food = 0 }
            if clothing < 0 { clothing = 0 }
            if supplies < 0 { supplies = 0 }
            if cash < 0 { cash = 0 }
            showInventory()
            
            println()
            println("   President James K. Polk sends you his")
            println("       heartiest congratulations")
            println()
            println("   and wishes you a prosperous life ahead")
            println()
            println("       at your new home")
            
            stop(true)
        }

        //Illness subroutine, lines 6290-6460
        func illness() {
            if 100 * rnd() < 10 + 35 * (Double(foodChoice) - 1) {
                println("Mild illness---medicine used")
                totalMileage -= 5
                supplies -= 2
            } else {
                if 100 * rnd() < 100 - (40 / pow(4, Double(foodChoice) - 1)) {
                    println("Bad illness---medicine used")
                    totalMileage -= 5
                    supplies -= 5
                } else {
                    println("Serious illness---")
                    println("You must stop for medical attention")
                    totalMileage -= 10
                    seriousIllness = true
                }
            }
            
            if supplies < 0 {
                notEnoughSuppliesForTreatment()
            }
        }
    }
    
    //Instructions, lines 230-680
    private func showInstructions() {
        println("This program simulates a trip over the Oregon Trail from")
        println("Independence, Missouri to Oregon City, Oregon in 1847.")
        println("Your family of five will cover the 2040 mile Oregon Trail")
        println("in 5-6 months --- if you make it alive.")
        println()
        println("You had saved $900 to spend for the trip, and you've just")
        println("   paid $200 for a wagon.")
        println("You will need to spend the rest of your money on the")
        println("   following items:")
        println()
        println("   Oxen - You can spend $200-$300 on your team.")
        println("       The more you spend, the faster you'll go")
        println("       because you'll have better animals")
        println()
        println("   Food - The more you have, the less chance there")
        println("       is of getting sick")
        println()
        println("   Ammunition - $1 buys you a belt of 50 bullets")
        println("       You will need bullets for attacks by animals")
        println("       and bandits, and for hunting food")
        println()
        println("   Clothing - This is especially important for the cold")
        println("       weather you will encounter when crossing")
        println("       the mountains")
        println()
        println("   Miscellaneous supplies - This includes medicine and")
        println("       other things you will need for sickness")
        println("       and emergency repairs")
        println()
        println()
        println("You can spend all your money before you start your trip -")
        println("or you can save some of your case to spend at forts along")
        println("the way when you run low. However, items cost more at")
        println("the forts. You can also go hunting along the way to get")
        println("more food.")
        println("Whenever you have to use your trusty rifle along the way,")
        println("you will be told to type in a word (one that sounds like a")
        println("gun shot). The faster you type in that word and hit the")
        println("\"return\" key, the better luck you will have with your gun.")
        println()
        println("At each turn, all items are shown in dollar amounts")
        println("except bullets")
        println("When asked to enter money amounts, don't use a \"$\".")
        println()
        println("Good luck!!!")
    }
    
        
    //Lines 710-790
    private func getMarksmanshipLevel() -> ShootingLevel {
        println("How good a shot are you with your rifle?")
        println("   (1) Ace marksman, (2) Good shot, (3) Fair to middlin',")
        println("       (4) Need more pracice, (5) Shaky knees")
        wait(.short)
        println("Enter one of the above -- the better you claim you are, the")
        println("faster you'll have to be with your gun to be successful.")
        let response = input()
        guard let level = Int(response) else { return .unspecified }
        return ShootingLevel(level)
    }

    //Setting date, lines 1200-1680
    private func date(for turnNumber: Int) -> String? {
        let day: String
        switch turnNumber {
        case 0: day = "March 29"
        case 1: day = "April 12"
        case 2: day = "April 26"
        case 3: day = "May 10"
        case 4: day = "May 24"
        case 5: day = "June 7"
        case 6: day = "June 21"
        case 7: day = "July 5"
        case 8: day = "July 19"
        case 9: day = "August 2"
        case 10: day = "August 16"
        case 11: day = "August 31"
        case 12: day = "September 13"
        case 13: day = "September 27"
        case 14: day = "October 11"
        case 15: day = "October 25"
        case 16: day = "November 8"
        case 17: day = "November 22"
        case 18: day = "December 6"
        case 19: day = "December 20"
        default:
            return nil
        }
        
        return "Monday " + day + " 1847"
    }
    
    //Lines 5050-5070
    private func outOfFood() {
        println("You ran out of food and starved to death")
        failure()
    }
    
    //Lines 5080-5090
    private func cannotAffordDoctor() {
        println("You can't afford a doctor")
        failure()
    }
    
    //Lines 5110-5160
    private func notEnoughSuppliesForTreatment() {
        println("You ran out of medical supplies")
    }
    
    private func died(ofInjury injury: Bool) {
        if injury {
            println("You died of injuries")
        } else {
            println("You died of pneumonia")
        }
        failure()
    }
    
    //Lines 5170-5410
    private func failure() {
        println()
        println("Due to your unfortunate situation, there are a few")
        println("formalities we must go through")
        println()
        let _ = input("Would you like a minister")
        let _ = input("Would you like a fancy funeral")
        let response = input("Would you like to inform your next of kin")
        if response.isYes {
            println("That will be $4.50 for the telegraph charge.")
        } else {
            println("But your Aunt Sadie in St. Louis is really worried about you.")
        }
        
        println()
        println("We thank you for this information and we are sorry you")
        println("didn't make it to the great territory of Oregon")
        println("Better luck next time")
        println()
        println()
        println("           Sincerely")
        println()
        println("   The Oregon City Chamber of Commerce")

        stop(false)
    }
        
    //Shooting subroutine, lines 6130-6280.
    private func shoot(_ level: ShootingLevel) -> Double {
        var responseTime = 0.0
        let MaximumTime = 9.0  //9 seconds maximum = failure
        let word: String
        switch Int.random(in: 0...3) {
        case 0: word = "bang"
        case 1: word = "blam"
        case 2: word = "pow"
        case 3: word = "wham"
        default:
            word = "shazam"
        }
        
        let startTime = Date()
        let response = input("TYPE " + word)
        let shootTime = Date().timeIntervalSince(startTime) - delayAfterInput  //Remove input delay
        
        if response.uppercased() != word.uppercased() {
            responseTime = MaximumTime
        } else {
            
        }
        
        responseTime = shootTime * 2 - (Double(level.value) - 1)
        if responseTime < 0 { responseTime = 0 }
        return responseTime
    }
    
    private func stop(_ isSuccessful: Bool = false) {
        println()
        println("Run complete.")
        wait(.long)
        
        //Added option to run again
        println(4)
        let response = input("Run again")
        
        if response.isEasterEgg, isSuccessful {
            showEasterEgg(.oregonTrail)
        }
        
        if response.isYes {
            playGame()
        } else {
            end()
        }
    }
    
    //6470 REM ***IDENTIFICATION OF VARIABLES IN THE PROGRAM***
    //6480 REM A = AMOUNT SPENT ON ANIMALS
    //6490 REM B = AMOUNT SPENT ON AMMUNITION
    //6500 REM B1 = ACUTAL RESPONSE TIME FOR INPUTTING "BANG"
    //6510 REM B3 = CLOCK TIME AT START OF INPUTTING "BANG"
    //6520 REM C = AMOUNT SPENT ON CLOTHING
    //6530 REM C1 = FLAG FOR INSUFFICIENT CLOTHING IN COLD WEATHER
    //6540 REM C$ = YES/NO RESPONSE TO QUESTIONS
    //6550 REM D1 = COUNTER IN GENERATION EVENTS
    //6560 REM D3 = TURN NUMBER FOR SETTING DATE
    //6570 REM D4 = CURRENT DATE
    //6580 REM D9 = CHOICE OF SHOOTING EXPERTISE LEVEL
    //6590 REM E = CHOICE OF EATING
    //6600 REM F = AMOUNT SPENT ON FOOD
    //6610 REM F1 = FLAG FOR CLEARING SOUTH PASS
    //6620 REM F2 = FLAG FOR CLEARING BLUE MOUNTAINS
    //6630 REM F9 = FRACTION OF 2 WEEKS TRAVELLED ON FINAL TURN
    //6640 REM K8 = FLAG FOR INJURY
    //6650 REM L1 = FLAG FOR BLIZZARD
    //6660 REM M = TOTAL MILEAGE WHOLE TRIP
    //6670 REM M1 = AMOUNT SPENT ON MISCELLANEOUS SUPPLIES
    //6680 REM M2 = TOTAL MILEAGE UP THROUGH PREVIOUS TURN
    //6690 REM M9 = FLAG FOR CLEARING SOUTH PASS IN SETTING MILEAGE
    //6700 REM P = AMOUNT SPENT ON ITEMS AT THE FORT
    //6710 REM R1 = RANDOM NUMBER IN CHOOSING EVENTS
    //6720 REM S4 = FLAG FOR ILLNESS
    //6730 REM S5 = ""HOSTILITY OF RIDERS"" FACTOR
    //6740 REM S6 = SHOOTING WORD SELECTOR
    //6750 REM S$ = VARIATIONS OF SHOOTING WORD
    //6760 REM T = CASH LEFT OVER AFTER INITIAL PURCHASES
    //6770 REM T1 = CHOICE OF TACTICS WHEN ATTACKED
    //6780 REM X = CHOICE OF ACTION FOR EACH TURN
    //6790 REM X1 = FLAG FOR FORT OPTION
}
