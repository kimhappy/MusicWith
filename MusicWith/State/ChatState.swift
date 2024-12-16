//
//  ChatState.swift
//  MusicWith
//
//  Created by kimhappy on 12/16/24.
//

import Foundation

class ChatState: ObservableObject {
    // Client -> Server messages
    private struct _AJoin: Encodable {
        let user_id: String
        let name   : String
    }

    private struct _AChat: Encodable {
        let content : String
        let time    : Double?
        let reply_to: String?
    }

    private struct _ADelete: Encodable {
        let chat_id: String
    }

    private enum _AMsg: Encodable {
        case join  (_AJoin  )
        case chat  (_AChat  )
        case delete(_ADelete)

        enum CodingKeys: String, CodingKey {
            case join
            case chat
            case delete
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .join(let value):
                try container.encode(value, forKey: .join)

            case .chat(let value):
                try container.encode(value, forKey: .chat)

            case .delete(let value):
                try container.encode(value, forKey: .delete)
            }
        }
    }

    // Server -> Client messages
    private struct _BJoin: Decodable {
        let user_id: String
    }

    private struct _BJoinResult: Decodable {
        let history: [_BChat]
        let online : [String]
    }

    private struct _BLeave: Decodable {
        let user_id: String
    }

    private struct _BChat: Decodable {
        let user_id : String
        let name    : String
        let chat_id : String
        let content : String?
        let time    : Double?
        let reply_to: String?
    }

    private struct _BDelete: Decodable {
        let chat_id: String
    }

    private enum _BMsg: Decodable {
        case join       (_BJoin      )
        case join_result(_BJoinResult)
        case leave      (_BLeave     )
        case chat       (_BChat      )
        case delete     (_BDelete    )

        enum CodingKeys: String, CodingKey {
            case join
            case join_result
            case leave
            case chat
            case delete
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try? container.decode(_BJoin.self, forKey: .join) {
                self = .join(value)
            }
            else if let value = try? container.decode(_BJoinResult.self, forKey: .join_result) {
                self = .join_result(value)
            }
            else if let value = try? container.decode(_BLeave.self, forKey: .leave) {
                self = .leave(value)
            }
            else if let value = try? container.decode(_BChat.self, forKey: .chat) {
                self = .chat(value)
            }
            else if let value = try? container.decode(_BDelete.self, forKey: .delete) {
                self = .delete(value)
            }
            else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "No valid key found for _BMsg."
                    )
                )
            }
        }
    }

    static public var shared = ChatState()
    private init() {}

    private var _webSocketTask: URLSessionWebSocketTask? = nil

    @Published public var chat  : [Chat  ] = []
    @Published public var online: [String] = []

    private func _text2msg(_ text: String) -> _BMsg? {
        text.data(using: .utf8).flatMap { try? JSONDecoder().decode(_BMsg.self, from: $0) }
    }

    private func _msg2text(_ msg: _AMsg) -> String? {
        (try? JSONEncoder().encode(msg)).flatMap { String(data: $0, encoding: .utf8) }
    }

    private func _receiveMsg(_ msg: _BMsg) {
        switch msg {
        case .join(let info):
            online.append(info.user_id)

        case .join_result(let info):
            chat += info.history.map { Chat(
                userId : $0.user_id,
                name   : $0.name   ,
                chatId : $0.chat_id,
                content: $0.content,
                time   : $0.time   ,
                replyTo: $0.reply_to
            ) }
            online += info.online
            chat.sort { ($0.time ?? 0) < ($1.time ?? 0) }

        case .leave(let info):
            if let idx = online.firstIndex(where: { $0 == info.user_id }) {
                online.remove(at: idx)
            }

        case .chat(let info):
            chat.append(Chat(
                userId : info.user_id,
                name   : info.name   ,
                chatId : info.chat_id,
                content: info.content,
                time   : info.time   ,
                replyTo: info.reply_to
            ))
            chat.sort { ($0.time ?? 0) < ($1.time ?? 0) }

        case .delete(let info):
            if let idx = chat.firstIndex(where: { $0.chatId == info.chat_id }) {
                chat[ idx ].content = nil
            }
        }
    }

    private func _sendMsg(_ msg: _AMsg) {
        guard let _webSocketTask,
              let text = _msg2text(msg)
        else {
            return
        }

        _webSocketTask.send(.string(text), completionHandler: { error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }

    private func _listen() {
        _webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            if case .success(let message) = result ,
               case .string (let text   ) = message,
               let  msg                   = self._text2msg(text) {
                DispatchQueue.main.async {
                    self._receiveMsg(msg)
                }
            }

            self._listen()
        }
    }

    public func connect(trackId: String) {
        guard let url  = URL(string: "ws://34.122.154.52:8000/chat/\(trackId)") else { return }
        let request    = URLRequest(url: url)
        _webSocketTask = URLSession.shared.webSocketTask(with: request)
        _webSocketTask?.resume()
        _listen()
    }

    public func disconnect() {
        _webSocketTask?.cancel(with: .goingAway, reason: nil)
        _webSocketTask = nil
        chat  .removeAll()
        online.removeAll()
    }

    public func sendChat(content: String, time: Double? = nil, replyTo: String? = nil) {
        _sendMsg(_AMsg.chat(_AChat(content: content, time: time, reply_to: replyTo)))
    }

    public func sendDelete(chatId: String) {
        _sendMsg(_AMsg.delete(_ADelete(chat_id: chatId)))
    }

    public func sendJoin(userId: String, name: String) {
        _sendMsg(_AMsg.join(_AJoin(user_id: userId, name: name)))
    }

    deinit {
        disconnect()
    }
}
