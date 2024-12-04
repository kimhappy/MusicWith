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
    @State private  var isDeleteSelected: Bool          = false
    @State private  var isLongSelected  : Bool          = false
    @State private  var selectedParentId: String?       = nil
    @State private  var selectedDeleteId: String?       = nil
    @State          var chats           : [Chat]        = []
    @State          var trackId         : String        = ""
    let testUserId: String = "testuser"
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(chats) { chat in
                        HStack {
                            if chat.parentId == nil {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:40, height:40)
                                    .clipShape(Circle())
                                    .foregroundColor(.pink)
                                    .padding()
                                    .padding(.leading, 4)
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(chat.user)
                                            .font(.headline)
                                        Spacer()
                                        Text(timeFormat(seconds: chat.timeSong!))
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .padding(.trailing, 20)
                                    }
                                    Text(chat.text ?? "deleted")
                                        .font(.title3)
                                        .fixedSize(horizontal: false, vertical: true)
                                    HStack {
                                        Button(action: {
                                            isSelected = true
                                            selectedParentId = chat.id
                                        }) {
                                            Text("답글")
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        Spacer()
                                        if testUserId == chat.user {
                                            Button(action: {
                                                isDeleteSelected = true
                                                selectedDeleteId = chat.id
                                            }) {
                                                Text("삭제")
                                                    .font(.subheadline)
                                                    .padding(.trailing)
                                            }
                                        }
                                    }
                                    .alert(isPresented: $isDeleteSelected) {
                                        Alert(
                                            title: Text("Alert"),
                                            message        : Text("Are you sure you want to delete?"),
                                            primaryButton  : .default(Text("Delete")) {
                                                deleteMessage()
                                            },
                                            secondaryButton: .cancel()
                                        )
                                     }
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        .overlay(
                            Rectangle()
                                .frame(height:1)
                                .foregroundColor(.gray),
                            alignment: .bottom
                        )
                                
                        ForEach(chats) { chat2 in
                            if chat2.parentId == chat.id {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40, height:40)
                                        .clipShape(Circle())
                                        .foregroundColor(.green)
                                        .padding()
                                        .padding(.leading, 50)
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(chat2.user)
                                                .font(.headline)
                                            Spacer()
                                            Text("")
                                        }
                                        Text(chat2.text ?? "deleted")
                                            .font(.title3)
                                            .fixedSize(horizontal: false, vertical: true)
                                        HStack {
                                            if testUserId == chat2.user {
                                                Spacer()
                                                Button(action: {
                                                    isDeleteSelected = true
                                                    selectedDeleteId = chat2.id
                                                }) {
                                                    Text("삭제")
                                                        .font(.subheadline)
                                                        .padding(.trailing)
                                                }
                                            }
                                        }
                                        .alert(isPresented: $isDeleteSelected) {
                                            Alert(
                                                title: Text("Alert"),
                                                message        : Text("Are you sure you want to delete?"),
                                                primaryButton  : .default(Text("Delete")) {
                                                    deleteMessage()
                                                },
                                                secondaryButton: .cancel()
                                            )
                                         }
                                    }
                                    .padding(.bottom, 10)
                                }
                                .overlay(
                                    Rectangle()
                                        .frame(height:1)
                                        .foregroundColor(.gray),
                                    alignment: .bottom
                                )
                            }
                        }
                    }
                    .padding(.bottom, 0.1)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                if isSelected {
                    HStack {
                        ForEach(chats) { chat in
                            if selectedParentId! == chat.id {
                                Text(" \(chat.user) 에게 답장 중")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding(.leading, 20)
                                    .padding(.top, 5)
                            }
                        }
                        Spacer()
                        Text("취소")
                            .padding(.trailing, 30)
                            .onTapGesture {
                                isSelected = false
                                selectedParentId = nil
                            }
                    }
                    .padding(.vertical, 5)
                    HStack {
                        TextField("입력", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size:20))
                            .padding()
                        Button(action: {
                            sendMessage()
                        }) {
                            Text("전송")
                                .font(.system(size:20))
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .offset(x:-11)
                        }
                    }
                }
                else {
                    HStack {
                        TextField("입력", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size:20))
                            .padding()
                        Button(action: {
                            sendMessage()
                        }) {
                            Text("전송")
                                .font(.system(size:20))
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .offset(x:-11)
                        }
                    }
                }
            }
        }
        .task {
            if let state = controlState.playState {
                trackId  = state.song.trackId
            }
            await networkService.connect(trackId: "10", userId: "testuser", chats: $chats)
            let _ = print(trackId)
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
    
    func timeFormat(seconds: Int) -> String {
        let minute = seconds/60
        let second = seconds%60
        return String(format: "%d:%02d", minute, second)
    }
}

#Preview {
    ChatView()
}
