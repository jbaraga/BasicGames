//
//  TerminalViewRepresentable.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import AppKit
import SwiftUI
import SwiftTerm


struct TerminalViewRepresentable: NSViewRepresentable {
    typealias NSViewType = LocalProcessTerminalView
    
    let frame: CGRect
    let executableName: String
    var windowTitle: String?
    
    @ObservedObject private var settings = Preferences.shared
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let terminalView = LocalProcessTerminalView(frame: frame)
        guard let path = Bundle.main.path(forResource: executableName, ofType: nil) else {
            return terminalView
        }
        terminalView.nativeForegroundColor = settings.foregroundColor
        terminalView.caretColor = settings.foregroundColor
        terminalView.nativeBackgroundColor = .terminalBackground
        let terminal = terminalView.getTerminal()
        context.coordinator.terminal = terminal
        terminalView.processDelegate = context.coordinator
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            terminalView.startProcess(executable: path, args: [], environment: nil, execName: nil)
        }
        return terminalView
    }
    
    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        if nsView.nativeForegroundColor != settings.foregroundColor {
            nsView.nativeForegroundColor = settings.foregroundColor
            nsView.caretColor = settings.foregroundColor
            nsView.send(txt: " " + .deleteCharacter)  //Forces refresh of text in TerminalView
        }
    }
    
    internal class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
        var parent: TerminalViewRepresentable
        weak var terminal: Terminal?
        
        private var isAwaitingInput = false {
            didSet {
                isCursorBlinkingEnabled = isAwaitingInput && Preferences.shared.isBlinkingCursor
            }
        }
        
        private var isCursorBlinkingEnabled = false {
            didSet {
                blinkCursor()
            }
        }
        
        private var isCursorHidden = false {
            didSet {
                isCursorHidden ? terminal?.hideCursor() : terminal?.showCursor()
            }
        }
        
        init(_ parent: TerminalViewRepresentable) {
            self.parent = parent
            super.init()
                        
            NotificationCenter.default.addObserver(forName: .cursorSettingDidChange, object: nil, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                self.isCursorBlinkingEnabled = self.isAwaitingInput
            }
            
            let center = DistributedNotificationCenter.default()
            center.addObserver(forName: NSNotification.Name("com.starwaresoftware.basicGames.input"), object: nil, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                guard let isAwaitingInput = notification.object as? String else { return }
                self.isAwaitingInput = isAwaitingInput == true.description
            }
            
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { notification in
                guard let window = notification.object as? NSWindow, window.title == parent.windowTitle else {
                    return
                }
                center.post(name: NSNotification.Name("com.starwaresoftware.basicGames.close"), object: parent.executableName, userInfo: nil)
            }
        }
                
        func blinkCursor() {
            guard isCursorBlinkingEnabled, Preferences.shared.isBlinkingCursor else {
                terminal?.showCursor()
                return
            }
            
            let delay = 0.5
            terminal?.hideCursor()
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                if !self.isCursorHidden {
                    self.terminal?.showCursor()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.blinkCursor()
                }
            }
        }
        
        //LocalProcessTerminalViewDelegate
        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {
            //Hack to restore cursor position on window resize
            isCursorHidden = true
            source.send(txt: " " + .deleteCharacter)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                isCursorHidden = false
            }
        }
        
        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
            return
        }
        
        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
            return
        }
        
        func processTerminated(source: TerminalView, exitCode: Int32?) {
            return
        }
    }
}


