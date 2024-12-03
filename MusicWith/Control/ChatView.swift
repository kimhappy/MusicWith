//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

struct ChatView: View {
    @StateObject    var controlState                    = ControlState.shared
    @ObservedObject var networkService                  = NetworkService.shared
    @State private  var messageText     : String        = ""
    @State private  var isSelected      : Bool          = false
    @State private  var isLongSelected  : Bool          = false
    @State private  var selectedParentId: String?       = nil
    @State private  var selectedDeleteId: String?       = nil
    @State          var chats           : [Chat]        = []
    @State          var trackId         : String        = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chats) { chatting in
                        HStack {
                            if chatting.parentId == nil {
                                Text(chatting.text ?? "deleted")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        isSelected       = true
                                        selectedParentId = chatting.id
                                    }
                                    .onLongPressGesture(minimumDuration: 1.0) {
                                        isLongSelected   = true
                                        selectedDeleteId = chatting.id
                                    }
                                    .alert(isPresented: $isLongSelected) {
                                        Alert(
                                            title: Text("Alert"),
                                            message        : Text("Are you sure you want to delete?"),
                                            primaryButton  : .default(Text("Delete")) {
                                                deleteMessage()
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    }
                                Spacer()
                                chatting.timeSong.map { Text(String($0)) }
                                    .font(.system(size:15))
                            }
                        }

                        ForEach(chats) { chat2 in
                            if chat2.parentId == chatting.id {
                                HStack {
                                    Text("ㄴ")
                                    Text(chat2.text ?? "deleted")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.leading, 5)
                                        .onLongPressGesture(minimumDuration: 1.0) {
                                            isLongSelected   = true
                                            selectedDeleteId = chat2.id
                                        }
                                        .alert(isPresented: $isLongSelected) {
                                            Alert(
                                                title          : Text("Alert"),
                                                message        : Text("Are you sure you want to delete?"),
                                                primaryButton  : .default(Text("Delete")) {
                                                    deleteMessage()
                                                },
                                                secondaryButton: .cancel()
                                            )
                                        }
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
        .task {
            if let state = controlState.playState {
                trackId  = state.song.trackId
            }
            //let _      = print(trackId)
            await networkService.connect(trackId: "10", userId: "uu", chats: $chats)
            networkService.askHistory()
        }
        
        .onDisappear {
            networkService.disconnect()
            chats = []
        }
    }
    
    private func sendMessage() {
        if messageText.isEmpty {
            return
        }
        
        if(isSelected) {    // reply
            networkService.sendChat(content: messageText, time: nil, reply_to: selectedParentId)
            messageText      = ""
            isSelected       = false
            selectedParentId = nil
        }
        else {
            networkService.sendChat(content: messageText, time: Int(controlState.playState!.now), reply_to: nil)
            messageText = ""
        }
    }
    
    private func deleteMessage() {
        //if()
        networkService.askDelete(chatId: selectedDeleteId!)
        isLongSelected   = false
        selectedDeleteId = nil
    }
}

#Preview {
    ChatView()
}
