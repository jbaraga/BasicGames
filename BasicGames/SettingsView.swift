//
//  SettingsView.swift
//  BasicGames
//
//  Created by Joseph Baraga on 2/11/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = Preferences.shared
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Cursor:").padding(.trailing)
                        Toggle("Blinking", isOn: settings.$isBlinkingCursor)
                            .onChange(of: settings.isBlinkingCursor) { newValue in
                                NotificationCenter.default.post(name: .cursorSettingDidChange, object: nil)
                            }
                    }
                    
                    Picker("Text Color:", selection: $settings.foregroundColor) {
                        ForEach(NSColor.allTerminalColors, id: \.self) { color in
                            Text(color.displayName)
                                .foregroundColor(Color(color))
                        }
                    }
                    .fixedSize()
                }
            }
            .padding()
        }
        .frame(width: 300, height: 120)
        .onAppear {
            //Hack to remove focus from Toggle
            Task {
                try await Task.sleep(seconds: 0.1)
                NSApp.windows.last?.makeFirstResponder(nil)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension Notification.Name {
    static let cursorSettingDidChange = Notification.Name("cursorSettingDidChange")
    static let foregroundColorDidChange = Notification.Name("foregroundColorDidChange")
}

//public extension NSTextField {
//    override var focusRingType: NSFocusRingType {
//            get { .none }
//            set { }
//    }
//}
