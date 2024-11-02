//
//  ControlCoreView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct ControlCoreView: View {
    @EnvironmentObject var controlState: ControlState
    //
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
                    // change
                    
                    // 실시간 반영 안됨
                    HStack {
                        Button(action : controlState.togglePlaying) {
                            if state.isPlaying {
                                Image(systemName: "pause")
                            }
                            else {
                                Image(systemName: "play")
                            }
                        }
                    }
                    
                    // changed ended
                    
                    ProgressView(value: state.now, total: state.duration)
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
