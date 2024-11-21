//
//  Websocket.swift
//  MusicWith
//
//  Created by 2020014975 on 11/19/24.
//

import Foundation

class NetworkService: ObservableObject {
    
    static let shared = NetworkService()
    private var webSocketTask: URLSessionWebSocketTask?
    
    struct ChatNotice: Decodable {
        let Chat: ChatInfo
        struct ChatInfo: Decodable {
            let user_id: String
            let chat_id: Int
            let content: String?
            let time: Int?
            let reply_to: Int?
        }
    }
    struct DeleteNotice: Decodable {
        let Delete: DeleteChatID
        struct DeleteChatID: Decodable {
            let chat_id: Int
        }
    }
    struct JoinUser: Decodable {
        let Join: JoinUserID
        struct JoinUserID: Decodable {
            let user_id: String
        }
    }
    struct LeaveUser: Decodable {
        let Leave: LeaveUserID
        struct LeaveUserID: Decodable {
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
    struct OnlineUser: Decodable {
        let Online: OnlineUserList
        struct OnlineUserList: Decodable {
            let items: [String]
        }
    }
    
    func connect(trackID: String, userID: String) {
        guard let url = URL(string: "ws://127.0.0.1:8000/chat/\(trackID)/\(userID)") else {return}
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        //self.startPing()
        receiveMessage()
        
    }
    
    private func receiveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case.failure(let error):
                print(error.localizedDescription)
            case.success(let message):
                switch message {
                case.string(let stringMessage):
                    self?.handleMessage(stringMessage)
                case.data:
                    break
                @unknown default:
                    break
                }
            }
            self?.receiveMessage()
        })
    }
    
    
    private func handleMessage(_ message: String) {
        let json = message.data(using: .utf8)!
        
        print(message)
        
        if(message.contains("Chat")) {
            guard let info = try? JSONDecoder().decode(ChatNotice.self, from: json) else {return}
            
            print("Chat response received")
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
            print("History response received")
        }
        if(message.contains("Online")) {
            guard let info = try? JSONDecoder().decode(OnlineUser.self, from: json) else {return}
            print("Online response received")
        }
    }
    
    private func sendMessage() {
        
    }
}
