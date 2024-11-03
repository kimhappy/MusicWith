//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

struct ChatView: View {
    @EnvironmentObject var controlState: ControlState
    @State private var messageText: String = ""
    @State private var messages: [String] = []
    @State private var chats: [Chat] = []
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chats, id:\.id) { chatting in
                        HStack {
                            Text(chatting.text)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            Spacer()
                            if let state = controlState.playState {
                                Text(String(state.now))
                                    .font(.system(size:15))
                            }
                            
                        }
                    }
                    
                }
                .padding()
            }
            HStack {
                TextField("입력", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size:20))
                Button(action: {
                    sendMessage()
                }) {
                    Text("전송")
                        .font(.system(size:20))
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        if !messageText.isEmpty {
            chats.append(Chat(user: "user", text: messageText, song: "song", time_global: "time", time_song: "now"))
            messageText = ""
        }
    }
}

#Preview {
    MainView()
}

