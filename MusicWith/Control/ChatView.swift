//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

/*class MyChat: ObservableObject {
    @Published var chattings: [Chat] = []
}*/

struct ChatView: View {
    @StateObject var controlState = ControlState.shared
    @ObservedObject var networkService = NetworkService.shared
    @State private var messageText     : String = ""
    @State private var isSelected      : Bool   = false
    @State private var selectedParentId: Int?   = nil

    @State var chats: [Chat] = []

    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chats, id:\.id) { chatting in
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
                                Spacer()
                                chatting.timeSong.map { Text(String($0)) }
                                //Text(String(chatting.timeSong))
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
            await networkService.connect(trackID: "100", userID: "testapp", chats: $chats)
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
        networkService.sendChat(time: Int(controlState.playState!.now), content: messageText)
        messageText       = ""
        isSelected        = false
        selectedParentId  = nil
    }
}

#Preview {
    MainView()
}
