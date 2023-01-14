//
//  BasicGamesApp.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import SwiftUI
import Cocoa
import PDFKit


@main
struct BasicGamesApp: App {
    @StateObject private var settings = Preferences.shared

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.openURL) private var openURL
    
    @State private var game: Game?
    @State private var eggURL: URL?
    
    var body: some Scene {
        WindowGroup {
            GameLauncherView(game: $game)
                .onReceive(DistributedNotificationCenter.default().publisher(for: Notification.Name.showEasterEgg)) { notification in
                    if let filename = notification.object as? String {
                        showPDF(with: filename)
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandGroup(replacing: .printItem) {
                Button("Page Setup...") {
                    NSApp.runPageLayout(nil)
                }
                .keyboardShortcut(KeyEquivalent("P"), modifiers: [.shift, .command])

                Button("Print...") {
                    NSApp.keyWindow?.printWindow(nil)
                }
                .keyboardShortcut(KeyEquivalent("P"))
            }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: true))
        
//        GameScene(game: $game)
        
        Group {
            scene(for: .amazing)
            scene(for: .depthCharge)
            scene(for: .icbm)
            scene(for: .joust)
            scene(for: .lunar)
            scene(for: .lem)
            scene(for: .rocket)
            scene(for: .oregonTrail)
            scene(for: .starTrek)
        }

        Group {
            scene(for: .animal)
            scene(for: .banner)
            scene(for: .blackjack)
            scene(for: .calendar)
            scene(for: .weekday)
            scene(for: .football)
            scene(for: .ftball)
            scene(for: .stockMarket)
            scene(for: .threeDPlot)
        }

        Group {
            scene(for: .bounce)
            scene(for: .splat)
            scene(for: .target)
            scene(for: .aceyDucey)
            scene(for: .guess)
            scene(for: .orbit)
            scene(for: .digits)
            scene(for: .evenWins1)
            scene(for: .evenWins2)
        }
        
        Group {
            scene(for: .hamurabi)
        }

        EggScene(url: $eggURL)
            .commands {
                SidebarCommands()
            }
        
        Settings {
            SettingsView()
                .navigationTitle("Preferences")
        }
    }
    
    private func scene(for game: Game) -> some Scene {
        WindowGroup(id: game.urlString) {
            GeometryReader { geometry in
                TerminalViewRepresentable(frame: geometry.frame(in: .local), executableName: game.executableName, windowTitle: game.stringValue)
                    .navigationTitle(game.stringValue)
            }
            .padding(.leading, 4)
            .padding(.bottom, 1)
            .background(Color(.terminalBackground))
            .frame(minWidth: 660, minHeight: 480) //~ 80 columns in terminal
        }
        .handlesExternalEvents(matching: game.set)
    }
    
    private struct GameScene: Scene {
        @Binding var game: Game?
        
        var body: some Scene {
            WindowGroup(id: Game.baseURLString) {
                if let game = game {
                    GeometryReader { geometry in
                        TerminalViewRepresentable(frame: geometry.frame(in: .local), executableName: game.executableName, windowTitle: game.stringValue)
                            .navigationTitle(game.stringValue)
                    }
                    .padding(.leading, 4)
                    .padding(.bottom, 1)
                    .background(Color(.terminalBackground))
                    .frame(minWidth: 660, minHeight: 480) //~ 80 columns in terminal
                }
            }
            .handlesExternalEvents(matching: Game.allGamesSet)
        }
    }
    
    private struct EggScene: Scene {
        @Binding var url: URL?
        
        var body: some Scene {
            WindowGroup(id: "easterEgg") {
                if let url = url, let document = PDFDocument(url: url) {
                    EggView(document: document)
                }
            }
            .handlesExternalEvents(matching: Game.eggSet)
        }
    }
    
    private func showPDF(with filename: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: "pdf") else { return }
        eggURL = URL(fileURLWithPath: path)
        if let url = Game.eggURL {
            openURL(url)
        }
    }
}


/*
 TO ADD A NEW GAME
 1. Add new CLI target with GameName (i.e. no spaces, camel case).
 2. Add target membership GameName to Extensions, Egg, ConsoleIO, GameProtocol
 3. Add GameName.swift file to GameName group, with target membership GameName:
    main.swift
        let game = GameName()
        game.run()
    GameName.swift
        class GameName: GameProtocol {
            func run() {}
        }
 4.  Add case gameName to Game enum in BasicGames group; specify name of easter egg pdf file (standard is 101_mmddyy)
 5.  Create easter egg pdf with Preview. Edit Permissions... and set read and owner passwords from KeyChain, deselect all privileges. Drag easter egg pdf to Resources group, and select copy to folder.
 6.  Add image for game either as Image set in Assets or use system image specified in Game enum; add optional tint.
 7.  BasicGamesApp - add scene(for: .gameName)
 8.  BasicGames target -> Build Phases
        Target Dependencies - add game CLI target
        Copy Bundle Resources - drag game CLI from Products group
 9.  Write the game code in GameName.swift. Have fun!
 */
