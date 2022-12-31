//
//  GameLauncherView.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import SwiftUI


struct GameLauncherView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject private var settings = Preferences.shared
    
    private let imageWidth: CGFloat = 40
    private let radius: CGFloat = 8
    
    private var games: [Game] {
        if settings.category == .all {
            return Game.allCases
        }
        
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
    
    @ViewBuilder
    private func FilterButton() -> some View {
        Picker("", selection: $settings.category) {
            ForEach(Category.allCases) { category in
                Text(category.stringValue)
            }
        }
        .labelsHidden()
    }
    
    var body: some View {
        List {
            ForEach(games, id: \.self) { game in
                Button(action: { launch(game) }) {
                    HStack {
                        image(for: game)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidth, height: imageWidth, alignment: .center)
                            .foregroundColor(game.imageTint)
                            .cornerRadius(radius)
                        
                        Text(game.stringValue)
                            .font(.title)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                
                Divider()
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .frame(minWidth: 300, minHeight: 200)
        .navigationTitle("101+ Basic Games")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                FilterButton()
            }
        }
    }
    
    private func launch(_ game: Game) {
        guard let url = game.url else { return }
        openURL(url)
    }
}

struct GameLauncherView_Previews: PreviewProvider {
    static var previews: some View {
        GameLauncherView()
    }
}
