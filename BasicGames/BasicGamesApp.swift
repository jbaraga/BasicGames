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
            GameLauncherView()
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
    
    private struct EggScene: Scene {
        @Binding var url: URL?
        
        var body: some Scene {
            WindowGroup(id: "easterEgg") {
                if let url = url, let document = PDFDocument(url: url) {
                    EggView(document: document)
                }
            }
            .handlesExternalEvents(matching: Egg.set)
        }
    }
    
    private func showPDF(with filename: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: "pdf") else { return }
        eggURL = URL(fileURLWithPath: path)
        if let url = Egg.url {
            openURL(url)
        }
    }
}


/*
 TO ADD A NEW GAME
 1. Add new CLI target with GameName (i.e. no spaces, camel case).
 2. Add Group with GameName.
 3. Add target membership GameName to Extensions, Egg, ConsoleIO, GameProtocol
 4. Add files to GameName group, with target membership GameName:
    main.swift
        let game = GameName()
        game.run()
    GameName.swift
        class GameName: GameProtocol {
            func run() {}
        }
 5.  Add case gameName to Egg enum; specify name of easter egg pdf file (standard is 101_mmddyy)
 6.  Create easter egg pdf with Preview. Edit Permissions... and set read and owner passwords from KeyChain, deselect all privileges. Drag easter egg pdf to Resources group, and select copy to folder.
 7.  Add case gameName to Game enum in BasicGames group.
 8.  Add image for game either as Image set in Assets or use system image specified in Game enum.
 9.  BasicGamesApp - add scene(for: .gameName)
 10. BasicGames target -> Build Phases
        Target Dependencies - add game CLI target
        Copy Bundle Resources - drag game CLI from Products group
 11. Write the game code in GameName.swift. Have fun!
 */
