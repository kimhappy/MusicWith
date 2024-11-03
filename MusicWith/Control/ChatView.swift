//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [String] = []
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages, id: \.self) { message in
                        HStack {
                            Text(message)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            Spacer()
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
            messages.append(messageText)
            messageText = ""
        }
    }
}

#Preview {
    ChatView()
}
