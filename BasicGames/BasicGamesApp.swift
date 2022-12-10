//
//  BasicGamesApp.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import SwiftUI
import Cocoa

@main
struct BasicGamesApp: App {
    @StateObject private var settings = Preferences.shared

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.openURL) private var openURL
    
    @State private var game: Game?
    
    var body: some Scene {
        WindowGroup {
            GameLauncherView()
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
        }
       
//        WindowGroup(id: "game.urlString") {
//            if let game = self.game {
//                GeometryReader { geometry in
//                    TerminalViewRepresentable(frame: geometry.frame(in: .local), executableName: game.executableName, windowTitle: game.stringValue)
//                        .navigationTitle(game.stringValue)
//                }
//                .padding(.leading, 4)
//                .padding(.bottom, 1)
//                .background(Color(.terminalBackground))
//                .frame(minWidth: 580, minHeight: 400)
//            }
//        }
//        .handlesExternalEvents(matching: Game.allGamesSet)

        
        Settings {
            SettingsView()
                .navigationTitle("Preferences")
        }
    }
    
    private func scene(for game: Game) -> some Scene {
        WindowGroup(id: game.urlString) {
            if #available(macOS 13, *) {
                GeometryReader { geometry in
                    TerminalViewRepresentable(frame: geometry.frame(in: .local), executableName: game.executableName, windowTitle: game.stringValue)
                        .navigationTitle(game.stringValue)
                }
                .padding(.leading, 4)
                .padding(.bottom, 1)
                .background(Color(.terminalBackground))
                .frame(minWidth: 660, minHeight: 480) //~ 80 columns in terminal
                .frame(maxWidth: 680)
                .fixedSize()
            } else {
                GeometryReader { geometry in
                    TerminalViewRepresentable(frame: geometry.frame(in: .local), executableName: game.executableName, windowTitle: game.stringValue)
                        .navigationTitle(game.stringValue)
                }
                .padding(.leading, 4)
                .padding(.bottom, 1)
                .background(Color(.terminalBackground))
                .frame(minWidth: 660, minHeight: 480) //~ 80 columns in terminal
                .frame(maxWidth: 680)
            }
        }
        .handlesExternalEvents(matching: game.set)
    }
    
}


