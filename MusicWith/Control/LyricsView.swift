//
//  LyricsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct LyricsView: View {
    @StateObject var controlState = ControlState.shared
    @State       var lyric        = ""
    @State       var beginList: [Int]   = []
    @State       var lineList: [String]     = []
    @Environment(\.colorScheme) var colorSchema

    var body: some View {
        if let state = controlState.playState {
            VStack {
                Text("가사")
                    .padding(.top, 30)
                    .font(.system(size: 20, weight: .semibold))
                ScrollView {
                    ForEach(0..<min(beginList.count, lineList.count), id: \.self) { index in
                        if beginList.count-1 == index { //마지막 요소
                            Text(lineList[index])
                                .foregroundColor(beginList[index]<=Int(state.now) ? Color.blue : colorSchema == .dark ? .white : .black)
                                .padding()
                        }
                        else {
                            Text(lineList[index])
                                .foregroundColor(beginList[index]<=Int(state.now) ? Color.blue : colorSchema == .dark ? .white : .black)
                                .padding()
                        }
                    }
                    /*Text(lyric)
                        .lineSpacing(30)
                        .offset(y:30)
                        .padding(30)*/
                }
            }
            .task {
                (beginList, lineList) = await state.song.lyric() ?? ([],[])
            }
        }
    }
}

#Preview {
    MainView()
}
