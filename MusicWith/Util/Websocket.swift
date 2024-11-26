//
//  Websocket.swift
//  MusicWith
//
//  Created by 2020014975 on 11/19/24.
//

import Foundation
import SwiftUI

class NetworkService: ObservableObject {
    static  let shared                                  = NetworkService()
    private var webSocketTask: URLSessionWebSocketTask?
    
    struct ChatNotice: Decodable {
        let Chat: ChatInfo
        struct ChatInfo: Decodable {
            let user_id : String
            let chat_id : Int
            let content : String?
            let time    : Int?
            let reply_to: Int?
        }
    }
    struct DeleteNotice: Decodable {
        let Delete: DeleteChatId
        struct DeleteChatId: Decodable {
            let chat_id: Int
        }
    }
    struct JoinUser: Decodable {
        let Join: JoinUserId
        struct JoinUserId: Decodable {
            let user_id: String
        }
    }
    struct LeaveUser: Decodable {
        let Leave: LeaveUserId
        struct LeaveUserId: Decodable {
            let user_id: String
        }
    }
    struct HistoryResponse: Decodable {
        let History: HistoryItems
        struct HistoryItems: Decodable {
            let items: [Items]
        }
        struct Items: Decodable {
            let user_id: String
            let chat_id: Int
            let content: String?
            let time: Int?
            let reply_to: Int?
        }
    }
    struct OnlineUserResponse: Decodable {
        let Online: OnlineUserList
        struct OnlineUserList: Decodable {
            let items: [String]
        }
    }
    
    struct AskChat: Encodable {
        let Chat: ChatInfo
        struct ChatInfo : Encodable {
            let content : String
            let time    : Int?
            let reply_to: Int?
        }
    }
    struct AskDelete: Encodable {
        let Delete: DeleteChatId
        struct DeleteChatId: Encodable {
            let chat_id: Int
        }
    }
    struct AskHistory: Encodable {
        let History: Temp
        struct Temp: Encodable { }
    }
    struct AskOnlineUser: Encodable {
        let Online: Temp
        struct Temp: Encodable { }
    }
    
    func connect(trackId: String, userId: String, chats: Binding<[Chat]>) async {
        guard let url = URL(string: "ws://127.0.0.1:8000/chat/\(trackId)/\(userId)") else {return}
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        //self.startPing()
        receiveMessage(chats: chats)
        
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func receiveMessage(chats: Binding<[Chat]>) {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case.failure(let error):
                print(error.localizedDescription)
            case.success(let message):
                switch message {
                case.string(let stringMessage):
                    self?.handleMessage(stringMessage, chats: chats)
                case.data:
                    break
                @unknown default:
                    break
                }
            }
            self?.receiveMessage(chats: chats)
        })
    }
    
    
    private func handleMessage(_ message: String, chats: Binding<[Chat]>) {
        let json = message.data(using: .utf8)!
        
        print(message)
        
        if(message.contains("Chat")) {
            guard let info = try? JSONDecoder().decode(ChatNotice.self, from: json) else {return}
            let newChat = Chat(id: info.Chat.chat_id, user: info.Chat.user_id, text: info.Chat.content, timeSong: info.Chat.time, parentId: info.Chat.reply_to)
            chats.wrappedValue.append(newChat)
        }
        if(message.contains("Delete")) {
            guard let info = try? JSONDecoder().decode(DeleteNotice.self, from: json) else {return}
            print("Delete response received")
        }
        if(message.contains("Join")) {
            guard let info = try? JSONDecoder().decode(JoinUser.self, from: json) else {return}
            print("Join response received")
        }
        if(message.contains("Leave")) {
            guard let info = try? JSONDecoder().decode(LeaveUser.self, from: json) else {return}
            print("Leave response received")
        }
        if(message.contains("History")) {
            guard let info = try? JSONDecoder().decode(HistoryResponse.self, from: json) else {return}
            for item in info.History.items {
                let historyChat = Chat(id: item.chat_id, user: item.user_id, text: item.content, timeSong: item.time, parentId: item.reply_to)
                chats.wrappedValue.append(historyChat)
            }
        }
        if(message.contains("Online")) {
            guard let info = try? JSONDecoder().decode(OnlineUserResponse.self, from: json) else {return}
            print("Online response received")
        }
    }
    
    func sendChat(content: String, time: Int?, reply_to: Int?) {
        let msg = AskChat(Chat: AskChat.ChatInfo(content: content, time: time, reply_to: reply_to))
        guard let json = try? JSONEncoder().encode(msg) else {
            return
        }
        let message = String(data: json, encoding: .utf8)!
        webSocketTask?.send(.string(message), completionHandler: {error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    func askDelete(chatId: Int) {
        let msg = AskDelete(Delete: AskDelete.DeleteChatId(chat_id: chatId))
        guard let json = try? JSONEncoder().encode(msg) else {
            return
        }
        let message = String(data: json, encoding: .utf8)!
        webSocketTask?.send(.string(message), completionHandler: {error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    func askHistory() {
        let msg = AskHistory(History: AskHistory.Temp())
        guard let json = try? JSONEncoder().encode(msg) else {
            return
        }
        let message = String(data: json, encoding: .utf8)!
        webSocketTask?.send(.string(message), completionHandler: {error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    func askOnline() {
        
    }
}
