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
    @Environment(\.openWindow) private var openWindow
    @Environment(\.pixelLength) private var pixelLength
    @Environment(\.displayScale) private var displayScale
    
    var body: some Scene {
        WindowGroup(id: "Main") {
            GameLauncherView()
                .onReceive(DistributedNotificationCenter.default().publisher(for: Notification.Name.showEasterEgg)) { notification in
                    if let string = notification.object as? String {
                        showPDF(with: string)
                    }
                }
        }
        .defaultSize(width: 300, height: 500)
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
        
        WindowGroup(id: "Terminal", for: Game.self) { $game in
            TerminalView(game: game ?? .amazing)
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: true))
        .defaultSize(width: 660, height: 640)  //~ 80 columns in terminal
        
        WindowGroup(id: "EasterEgg", for: EasterEggPDF.self) { $pdf in
            if let pdf, let document = pdf.document {
                EggView(document: document)
            }
        }
        .defaultSize(NSScreen.main?.size(for: 8/displayScale, height: 10/displayScale) ?? NSSize(width: 640, height: 720))
        .commands { SidebarCommands() }

        Settings {
            SettingsView()
        }
    }
        
    private func showPDF(with pdfString: String) {
        guard let pdf = EasterEggPDF(pdfString: pdfString) else { return }
        openWindow(value: pdf)
    }
    
    private struct EasterEggPDF: Codable, Hashable {
        let url: URL
        var pageNumbers: ClosedRange<Int>?
        
        init?(pdfString: String) {
            let components = pdfString.components(separatedBy: "-")
            if let last = components.last, let range = ClosedRange(string: last) {
                self.pageNumbers = range
                let filename = pdfString.replacingOccurrences(of: "-" + last, with: "")
                guard let url = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return nil }
                self.url = url
                return
            }
            
            guard let url = Bundle.main.url(forResource: pdfString, withExtension: "pdf") else { return nil }
            self.url = url
        }
        
        var document: PDFDocument? {
            guard let doc = PDFDocument(url: url) else { return nil }
            if let pageNumbers {
                return PDFDocument(document: doc, pageNumbers: pageNumbers)
            } else {
                return doc
            }
        }
    }
}


/*
 TO ADD A NEW GAME
 1. Add new CLI target with GameName (i.e. no spaces, camel case).
 2. Add target membership for GameName CLI to Extensions, Game, ConsoleIO, GameProtocol
 3. Add GameName.swift file to GameName group, with target membership GameName.
    main.swift
        let game = GameName()
        game.run()
    GameName.swift
        class GameName: GameProtocol {
            func run() {}
        }
 4.  Add case gameName to Game enum in BasicGames group; specify name of easter egg pdf file (standard is BasicGames)
 5.  Add page numbers to Game enum for app if easter egg pdf derived from BasicGames.pdf. Otherwise, create easter egg pdf with Preview. Edit Permissions... and set read and owner passwords from KeyChain (PDF Reader, PDF Owner), deselect all privileges. Drag easter egg pdf to Resources group, and select copy to folder.
 6.  Add image for game either as Image set in Assets or use system image specified in Game enum; add optional tint.
 7.  BasicGames target -> Build Phases
        Target Dependencies - add game CLI target
        Copy Bundle Resources - drag game CLI from Products group
 8.  Write the game code in GameName.swift. Have fun!
 */

