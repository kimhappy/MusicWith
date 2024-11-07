//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

struct ChatView: View {
    @StateObject var controlState = ControlState.shared

    @State private var messageText     : String = ""
    @State private var isSelected      : Bool   = false
    @State private var selectedParentId: Int?   = nil
    @State private var globalTestId    : Int    = 2

    //서버에서 해당 곡에 대한 채팅 목록을 불러오도록 구현해야 함
    @State private var chats: [Chat] = [Chat(id: 1, user: "dummyuser", text: "hi", timeSong: 2, parentId: nil)]

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chats, id:\.id) { chatting in
                        HStack {
                            if chatting.parentId == nil {
                                Text(chatting.text)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        isSelected       = true
                                        selectedParentId = chatting.id
                                    }
                                Spacer()
                                Text(String(chatting.timeSong))
                                    .font(.system(size:15))

                            }
                        }

                        ForEach(chats) { chat2 in
                            if chat2.parentId == chatting.id {
                                HStack {
                                    Text("ㄴ")

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
                if isSelected {
                    TextField("답장", text: $messageText)
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
            }
            .padding()
        }
    }

    private func sendMessage() {
        if messageText.isEmpty {
            return
        }

        chats.append(Chat(id: globalTestId, user: "user", text: messageText, timeSong: controlState.playState!.now, parentId: selectedParentId))

        messageText       = ""
        isSelected        = false
        selectedParentId  = nil
        globalTestId     += 1
    }
}

#Preview {
    MainView()
}
