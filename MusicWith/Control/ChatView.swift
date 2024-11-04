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
    @State private var isSelected:  Bool = false
    @State private var selectedParentId: UUID?
    
    //서버에서 해당 곡에 대한 채팅 목록을 불러오도록 구현해야 함
    @State private var chats: [Chat] = [Chat(user: "dummyuser", text: "hi", song: "song", time_global: "time", time_song: "now", isReply: false, parentId: nil)]
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chats, id:\.id) { chatting in
                        HStack {
                            if chatting.isReply == false {
                                Text(chatting.text)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        isSelected = true
                                        selectedParentId = chatting.id
                                    }
                                Spacer()
                                if let state = controlState.playState {
                                    Text(String(state.now))
                                        .font(.system(size:15))
                                }
                            }
                        }
                        
                        ForEach(chats) { chat2 in
                            if chat2.parentId == chatting.id {
                                HStack {
                                    Text("ㄴ")
                                        .padding(.leading, 5)
                                    Text(chat2.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.leading, 5)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            HStack {
                if isSelected == false {
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
                else {
                    
                    TextField("답장", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size:20))
                    Button(action: {
                        sendMessage()
                        isSelected = false
                    }) {
                        Text("전송")
                            .font(.system(size:20))
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        if !messageText.isEmpty {
            if isSelected == true {
                chats.append(Chat(user: "user", text: messageText, song: "song", time_global: "time", time_song: "now", isReply: true, parentId: selectedParentId))
                messageText = ""
            }
            else {
                chats.append(Chat(user: "user", text: messageText, song: "song", time_global: "time", time_song: "now", isReply: false, parentId: nil))
                messageText = ""
            }
            
        }
    }
}

#Preview {
    MainView()
}

