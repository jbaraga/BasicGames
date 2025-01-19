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
    
    private let imageWidth: CGFloat = 36
    private let radius: CGFloat = 8
    
    private var games: [Game] { settings.category.games }
 
    private func image(for game: Game) -> Image {
        if let systemName = game.imageSystemName {
            return Image(systemName: systemName)
        }
        else {
            return Image(game.imageName)
        }
    }
    
    private func cornerRadius(for game: Game) -> CGFloat {
        switch game {
        case .banner, .oregonTrail: return 8
        default:
            return 0
        }
    }
    
    private struct FilterButton: View {
        @Binding var selection: Category
        
        var body: some View {
            Picker("", selection: $selection) {
                ForEach(Category.allCases) { category in
                    Text(category.stringValue + " (\(category.games.count))")
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
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageWidth, height: imageWidth, alignment: .center)
                            .foregroundColor(game.imageTint)
                            .cornerRadius(cornerRadius(for: game))
                        
                        Text(game.description)
                            .font(.title)
                        
                        Spacer()
                        
                        if settings.isUnlocked(game) {
                            Image(systemName: "circle.fill")
                                .imageScale(.small)
                                .foregroundStyle(Color.green)
                                .brightness(-0.1)
                                .help("Easter egg unlocked (right click to open)")
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .contextMenu {
                    Button("Easter egg...") {
                        showEasterEgg(game)
                    }
                    .disabled(!settings.isUnlocked(game))
                }
            }
        }
        .frame(minWidth: 480, minHeight: 200)
        .navigationTitle("101+ Basic Games")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                FilterButton(selection: $settings.category)
            }
        }
    }
    
    private func showEasterEgg(_ game: Game) {
        guard let url = game.eggURL, let pdf = EasterEggPDF(url: url) else { return }
        openWindow(value: pdf)
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
