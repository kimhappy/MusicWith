//
//  ControlCoreView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct ControlCoreView: View {
    @StateObject var controlState = ControlState.shared

    var body: some View {
        if let state = controlState.playState {

            HStack {
                AsyncImage(url: URL(string: state.song.image)) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    Text(state.song.title)
                        .font(.headline)
                    Text(state.song.artist)
                        .font(.subheadline)
                }
                VStack(alignment: .center) {
                    HStack {
                        Button(action : controlState.playPrev) {
                            Image(systemName: "backward.fill")
                                .frame(width: 50, height: 50)
                        }
                        .padding(.horizontal, 5)


                        Button(action : controlState.togglePlaying) {
                            if state.isPlaying {
                                Image(systemName: "pause")
                                    .frame(width: 50, height: 50)
                            }
                            else {
                                Image(systemName: "play")
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .padding(.horizontal, 5)
                        Button(action : controlState.playNext) {
                            Image(systemName: "forward.fill")
                                .frame(width: 50, height: 50)
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.top, 30)



                    Slider(value: Binding(get: {state.now}, set: {
                        newNow in
                        state.now = newNow

                        if !controlState.isDragging {
                            controlState.seek(newNow)
                        }


                    }) ,
                           in: 0...state.duration,
                           onEditingChanged: {
                        isEditing in
                        controlState.isDragging = isEditing
                        if !isEditing {
                            controlState.seek(state.now)
                        }
                    })
                    .padding()
                }
            }
            .padding()
        }
        else {
            EmptyView()
        }
    }
}

#Preview {
    MainView()
}
