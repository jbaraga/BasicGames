//
//  SettingsView.swift
//  BasicGames
//
//  Created by Joseph Baraga on 2/11/22.
//

import SwiftUI
import SwiftTerm


struct SettingsView: View {
    @ObservedObject private var settings = Preferences.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CursorStyleView(cursorStyle: $settings.cursorStyle)
            
            VStack(alignment: .leading) {
                Text("Text Color").fontWeight(.semibold)
                Picker("", selection: $settings.foregroundColor) {
                    ForEach(NSColor.allTerminalColors, id: \.self) { color in
                        Text(color.displayName)
                            .foregroundColor(Color(color))
                    }
                }
                .labelsHidden()
                .fixedSize()
            }
        }
        .padding()
        .frame(minWidth: 300, alignment: .leading)
        .fixedSize()
    }
    
    private struct CursorStyleView: View {
        @Binding var cursorStyle: CursorStyle
        
        private var shape: Binding<String> {
            Binding(
                get: { cursorStyle.shape },
                set: {
                    guard let style = try? CursorStyle(shape: $0, isBlinking: isBlinking.wrappedValue) else { return }
                    cursorStyle = style
                    NotificationCenter.default.post(name: .cursorStyleDidChange, object: nil)
                }
            )
        }
        
        private var isBlinking: Binding<Bool> {
            Binding(
                get: { cursorStyle.isBlinking },
                set: {
                    guard let style = try? CursorStyle(shape: shape.wrappedValue, isBlinking: $0) else { return }
                    cursorStyle = style
                    NotificationCenter.default.post(name: .cursorStyleDidChange, object: nil)
                }
            )
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Cursor").fontWeight(.semibold)
                
                HStack(alignment: .top) {
                    Picker("", selection: shape) {
                        ForEach(CursorStyle.allShapes, id: \.self) { shape in
                            Text(shape)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.radioGroup)
                    
                    Spacer()
                    Toggle("Blinking", isOn: isBlinking)
                    Spacer()
                }
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
    static let cursorStyleDidChange = Notification.Name("cursorStyleDidChange")
    static let foregroundColorDidChange = Notification.Name("foregroundColorDidChange")
}
