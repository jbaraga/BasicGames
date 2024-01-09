//
//  GameLauncherView.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import SwiftUI


struct GameLauncherView: View {
    @ObservedObject private var settings = Preferences.shared
    @Environment(\.openWindow) private var openWindow
    
    private let imageWidth: CGFloat = 40
    private let radius: CGFloat = 8
    
    private var games: [Game] {
        if settings.category == .all { return Game.allCases }
        return Game.allCases.filter { $0.category == settings.category }
    }
    
    private func image(for game: Game) -> Image {
        if let systemName = game.imageSystemName {
            return Image(systemName: systemName)
        }
        else {
            return Image(game.imageName)
        }
    }
    
    private struct FilterButton: View {
        @Binding var selection: Category
        
        var body: some View {
            Picker("", selection: $selection) {
                ForEach(Category.allCases) { category in
                    Text(category.stringValue + " (\(category.count(Game.allCases)))")
                }
            }
            .labelsHidden()
            .fixedSize()
        }
    }
        
    var body: some View {
        List {
            ForEach(games, id: \.self) { game in
                Button(action: { launch(game) }) {
                    HStack {
                        image(for: game)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidth, alignment: .center)
                            .foregroundColor(game.imageTint)
                            .cornerRadius(radius)
                        
                        Text(game.stringValue)
                            .font(.title)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .frame(minWidth: 480, minHeight: 200)
        .navigationTitle("101+ Basic Games")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                FilterButton(selection: $settings.category)
            }
        }
    }
    
    private func launch(_ game: Game) {
        openWindow(value: game)
    }
}

struct GameLauncherView_Previews: PreviewProvider {
    static var previews: some View {
        GameLauncherView()
    }
}
