//
//  AppDelegate.swift
//  MacTerminal
//
//  Created by Miguel de Icaza on 3/11/20.
//  Copyright © 2020 Miguel de Icaza. All rights reserved.
//

import AppKit


class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let center = DistributedNotificationCenter.default()
        center.addObserver(forName: Notification.Name.consoleWillPrint, object: nil, queue: .main) { notification in
            guard let string = notification.object as? String else { return }
            self.printHardcopy(string)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func printHardcopy(_ string: String) {
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 300, height: 0))
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.string = string
        
        let printInfo = NSPrintInfo.shared
//        printInfo.isHorizontallyCentered = true
//        printInfo.isVerticallyCentered = true
        textView.frame = NSRect(origin: .zero, size: printInfo.imageablePageBounds.size)
//        textView.sizeToFit()
        
        let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
        printOperation.run()
    }
}

