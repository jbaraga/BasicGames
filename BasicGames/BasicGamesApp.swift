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
    
    @FocusedValue(\.isWindowFocused) private var isTerminalWindowFocused
        
    var body: some Scene {
        WindowGroup(id: "Main") {
            GameLauncherView()
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
                    guard let contentView = NSApp.keyWindow?.contentView else { return }
                    if let pdfView = contentView.firstSubview(ofType: PDFView.self) {
                        pdfView.printView(nil)  //PDFView properly scales and formats pdf document for printing
                    } else {
                        contentView.printView(nil)
                    }
                }
                .keyboardShortcut(KeyEquivalent("P"))
            }
            
            CommandGroup(after: .help) {
                Divider()
                
                Menu("Basic Computer Games") {
                    Button("Introduction") {
                        guard let url = Game.basicGamesIntroURL, let pdf = EasterEggPDF(title: "Basic Computer Games", url: url) else { return }
                        openWindow(value: pdf)
                    }
                    
                    Button("Index") {
                        guard let url = Game.basicGamesAppendixURL, let pdf = EasterEggPDF(title: "Game Index", url: url) else { return }
                        openWindow(value: pdf)
                    }
                }
                
                Menu("More Basic Computer Games") {
                    Button("Introduction") {
                        guard let url = Game.moreBasicGamesIntroURL, let pdf = EasterEggPDF(title: "More Basic Computer Games", url: url) else { return }
                        openWindow(value: pdf)
                    }
                    
                    Button("Appendix") {
                        guard let url = Game.moreBasicGamesAppendixURL, let pdf = EasterEggPDF(title: "Appendix", url: url) else { return }
                        openWindow(value: pdf)
                    }
                }
                
                Button("Basic Games on Github") {
                    guard let url = URL(string: "https://github.com/jbaraga/BasicGames") else { return }
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: true))
        
        WindowGroup(id: "Terminal", for: Game.self) { $game in
            if let game {
                GameView(game: game)
                    .focusedSceneValue(\.isWindowFocused, true)
                    .onOpenURL { url in open(url: url) }
                    .handlesExternalEvents(preferring: game.preferredSet, allowing: ["*"])
            }
        }
        .commands {
            CommandMenu("Terminal") {
                Menu("Command") {
                    ForEach(TerminalCommand.allCases) { command in
                        switch command {
                        case .break:
                            if #unavailable(macOS 14) {
                                Button(command.description) {
                                    DistributedNotificationCenter.default().post(name: .terminalCommand, object: command.escapeSequence)
                                }
                                .keyboardShortcut(KeyEquivalent("c"), modifiers: [.control])
                            }
                        default:
                            Button(command.description) {
                                DistributedNotificationCenter.default().post(name: .terminalCommand, object: command.escapeSequence)
                            }
                        }
                    }
                }
                .disabled(!(isTerminalWindowFocused ?? false))
            }
        }
        .defaultSize(width: 660, height: 640)  //~ 80 columns in terminal
        .windowToolbarStyle(.unifiedCompact(showsTitle: true))
        
        WindowGroup(id: "EasterEgg", for: EasterEggPDF.self) { $pdf in
            if let pdf, let document = pdf.document {
                EggView(document: document)
                    .navigationTitle(pdf.title)
            }
        }
        .defaultSize(NSScreen.main?.size(for: 8/displayScale, height: 10/displayScale) ?? NSSize(width: 640, height: 720))
        .commands {
            SidebarCommands()
        }

        Settings {
            SettingsView()
        }
    }
    
    private func open(url: URL) {
        guard var string = url.fragment(percentEncoded: false) else { return }
        let printPrefix = "string="
        let gamePrefix = "game="
        
        switch string {
        case _ where string.hasPrefix(printPrefix):
            string.removeFirst(printPrefix.count)
            printHardcopy(string)
        case _ where string.hasPrefix(gamePrefix):
            string.removeFirst(gamePrefix.count)
            guard let game = Game(rawValue: string) else { return }
            settings.unlock(game)
        default:
            break
        }
    }
    
    private func printHardcopy(_ string: String) {
        let printInfo = NSPrintInfo.shared
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: printInfo.imageablePageBounds.width - printInfo.leftMargin - printInfo.rightMargin, height: 0))
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.string = string
        textView.printView(nil)
    }
}

struct EasterEggPDF: Codable, Hashable {
    let title: String
    let url: URL
    var pageNumbers: ClosedRange<Int>?
            
    init?(title: String, url: URL) {
        self.title = title
        
        guard let fileURL = Bundle.main.url(forResource: url.deletingPathExtension().lastPathComponent, withExtension: url.pathExtension) else { return nil }
        self.url = fileURL
        
        let prefix = "pages="
        if var string = url.fragment(percentEncoded: false), string.hasPrefix(prefix) {
            string.removeFirst(prefix.count)
            pageNumbers = ClosedRange(string: string)
        }
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

struct WindowFocusKey: FocusedValueKey {
    typealias Value = Bool
}

extension FocusedValues {
    var isWindowFocused: Bool? {
        get { self[WindowFocusKey.self] }
        set { self[WindowFocusKey.self] = newValue }
    }
}


/*
 TO ADD A NEW GAME
 1. Add GameName.swift file to play group, with target membership play.
    GameName.swift
        class GameName: GameProtocol {
            func run() {}
        }
 2.  Add case gameName to Game enum in BasicGames group; specify name of easter egg pdf file and optionally page numbers (default file is BasicGames)
 3.  Add page numbers to Game enum for app if easter egg pdf derived from BasicGames.pdf. Otherwise, create easter egg pdf with Preview. Edit Permissions... and set read and owner passwords from KeyChain (PDF Reader, PDF Owner), deselect all privileges. Drag easter egg pdf to Resources group, and select copy to folder.
 4.  Add image for game either as Image set in Assets or use system image specified in Game enum; add optional tint.
 5.  In Play struct (PlayCommand file), add enum case game: GameName().run()
 6.  Write the game code in GameName.swift. Have fun!
 */

