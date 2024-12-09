//
//  ControlCoreView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct ControlCoreView: View {
    @StateObject                var controlState = ControlState.shared
    @State                      var songName     = ""
    @State                      var songArtist   = ""
    @State                      var songImageUrl = ""
    @Environment(\.colorScheme) var colorSchema

    var body: some View {
        if let state = controlState.playState {
            HStack {
                AsyncImage(url: URL(string: songImageUrl)) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    CustomScrollText(text: songName, font: UIFont.preferredFont(forTextStyle: .headline))
                        .frame(width : 100)
                        .font(.headline)
                    CustomScrollText(text: songArtist, font: UIFont.preferredFont(forTextStyle: .headline))
                        .frame(width : 100)
                        .font(.subheadline)
                }
                VStack(alignment: .center) {
                    HStack {
                        Button(action : {
                            Task { await controlState.playPrev() }
                        }) {
                            Image(systemName: "backward.fill")
                                .frame(width: 50, height: 50)
                                .foregroundStyle(colorSchema == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 5)
                        Button(action : controlState.togglePlaying) {
                            Image(systemName: state.isPlaying ? "pause" : "play")
                                .frame(width: 50, height: 50)
                                .foregroundStyle(colorSchema == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 5)
                        Button(action : {
                            Task { await controlState.playNext() }
                        }) {
                            Image(systemName: "forward.fill")
                                .frame(width: 50, height: 50)
                                .foregroundStyle(colorSchema == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.top, 80)

                    Slider(value: Binding(get: { state.now }, set: { newNow in
                        state.now = newNow

                        if !controlState.isDragging {
                            controlState.seek(newNow)
                        }
                    }),

                    in: 0...state.duration,
                    onEditingChanged: { isEditing in
                        controlState.isDragging = isEditing

                        if !isEditing {
                            controlState.seek(state.now)
                        }
                    })
                    .accentColor(.black)
                    HStack {
                        Text(formatTime(controlState.playState?.now ?? 0.0))
                            .font(.caption)
                        Spacer()
                        Text(formatTime(controlState.playState?.duration ?? 0.0))
                            .font(.caption)
                    }
                    .padding(.bottom, 50)
                }
            }
            .task {
                songName     = await state.song.name    () ?? ""
                songArtist   = await state.song.artist  () ?? ""
                songImageUrl = await state.song.imageUrl() ?? ""
            }
            .padding()
        }
        else {
            EmptyView()
        }
    }

    func formatTime(_ time : Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60

        return String(format : "%02d:%02d", minutes, seconds)
    }
}
