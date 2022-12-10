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
            GeometryReader { geometry in
                TerminalViewRepresentable(frame: geometry.frame(in: .local), executableName: game.executableName, windowTitle: game.stringValue)
                    .navigationTitle(game.stringValue)
            }
            .padding(.leading, 4)
            .padding(.bottom, 1)
            .background(Color(.terminalBackground))
            .frame(minWidth: 660, minHeight: 400) //~ 80 columns in terminal
            .frame(maxWidth: 680)
        }
        .handlesExternalEvents(matching: game.set)
    }
}


//MARK: Terminal Colors
extension NSColor {
    static let terminalBackground = NSColor(colorSpace: .deviceRGB, hue: 0, saturation: 0, brightness: 0.1, alpha: 1)
    static let terminalWhite = NSColor(colorSpace: .deviceRGB, hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
    static let terminalGreen = NSColor(red: 100/255, green: 225/255, blue: 100/255, alpha: 1)
    static let terminalBlue = NSColor(red: 75/255, green: 175/255, blue: 255/255, alpha: 1)
    
    var displayName: String {
        switch self {
        case .terminalWhite: return "White"
        case .terminalGreen: return "Green"
        case .terminalBlue: return "Blue"
        default:
            fatalError("Missing terminal color")
        }
    }
}

struct TerminalColors {
    static let all: [NSColor] = [.terminalWhite, .terminalGreen, .terminalBlue]
}
