//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

private struct _MessageView: View {
    public let chat       : Chat
    public let myUserId   : String
    public let activeUsers: [String]
    public let colorScheme: ColorScheme
    public let indent     : CGFloat
    public let onReply    : (String) -> Void
    public let onDelete   : (String) -> Void

    public var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .resizable      ()
                .scaledToFill   ()
                .frame          (width: 40, height: 40)
                .clipShape      (Circle())
                .foregroundColor(chat.parentId == nil ? .pink : .green)
                .padding        ()
                .padding        (.leading, 4 + indent)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(chat.user)
                        .font           (.headline)
                        .foregroundColor(activeUsers.contains(chat.user) ? .red : colorScheme == .dark ? .white : .black)
                    Spacer()
                    if let time = chat.timeSong, chat.parentId == nil {
                        Text(timeFormat(time))
                            .font           (.subheadline)
                            .foregroundColor(.blue)
                            .padding        (.trailing, 20)
                    }
                }

                Text(chat.text ?? "삭제됨")
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    if chat.parentId == nil {
                        Button(action: {
                            onReply(chat.id)
                        }) {
                            Text("답글")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }

                    Spacer()

                    if myUserId == chat.user {
                        Button(action: {
                            onDelete(chat.id)
                        }) {
                            Text("삭제")
                                .font(.subheadline)
                                .padding(.trailing)
                        }
                    }
                }
            }
            .padding(.vertical, chat.parentId == nil ? 20 : 10)
        }
    }
}


struct ChatView: View {
    @ObservedObject             private var _nss                        = NetworkService.shared
    @ObservedObject             private var _tps                        = TrackPlayer.shared
    @State                      private var _myUserId        : String   = ""
    @State                      private var _messageText     : String   = ""
    @State                      private var _isSelected      : Bool     = false
    @State                      private var _selectedParentId: String?  = nil
    @State                      private var _isDeleteSelected: Bool     = false
    @State                      private var _selectedDeleteId: String?  = nil
    @State                      private var _chats           : [Chat]   = []
    @State                      private var _activeUser      : [String] = []
    @Environment(\.colorScheme) private var _colorSchema

    private func _sendMessage() {
        guard !_messageText.isEmpty else { return }

        if _isSelected {
            _nss.sendChat(content: _messageText, time: nil, reply_to: _selectedParentId)
            _messageText      = ""
            _isSelected       = false
            _selectedParentId = nil
        }
        else if let info = _tps.info() {
            _nss.sendChat(content: _messageText, time: Int(info.now), reply_to: nil)
            _messageText = ""
        }
    }

    private func _deleteMessage() {
        guard let deleteId = _selectedDeleteId else { return }
        _nss.askDelete(chatId: deleteId)
        _isDeleteSelected = false
        _selectedDeleteId = nil
    }

    private var _parentChats: [Chat] {
        _chats.filter { $0.parentId == nil }
    }

    private func _replies(_ chatId: String) -> [Chat] {
        _chats.filter { $0.parentId == chatId }
    }

    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(_parentChats) { chat in
                        _MessageView(
                            chat       : chat,
                            myUserId   : _myUserId,
                            activeUsers: _activeUser,
                            colorScheme: _colorSchema,
                            indent     : 0,
                            onReply    : { parentId in
                                _isSelected       = true
                                _selectedParentId = parentId
                            },
                            onDelete   : { chatId in
                                _selectedDeleteId = chatId
                                _isDeleteSelected = true
                            }
                        )

                        ForEach(_replies(chat.id)) { replyChat in
                            _MessageView(
                                chat       : replyChat,
                                myUserId   : _myUserId,
                                activeUsers: _activeUser,
                                colorScheme: _colorSchema,
                                indent     : 50,
                                onReply    : { _ in },
                                onDelete   : { chatId in
                                    _selectedDeleteId = chatId
                                    _isDeleteSelected = true
                                }
                            )
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                if _isSelected, let selectedParentId = _selectedParentId {
                    HStack {
                        if let parentChat = _chats.first(where: { $0.id == selectedParentId }) {
                            Text(" \(parentChat.user) 에게 답장 중")
                                .font           (.body)
                                .foregroundColor(.blue)
                                .padding        (.leading, 20)
                                .padding        (.top, 5)
                        }
                        Spacer()
                        Text("취소")
                            .padding(.trailing, 30)
                            .onTapGesture {
                                _isSelected       = false
                                _selectedParentId = nil
                            }
                    }
                    .padding(.vertical, 5)
                }

                HStack {
                    TextField("입력", text: $_messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font          (.system(size: 20))
                        .padding       ()
                    Button(action: {
                        _sendMessage()
                    }) {
                        Text("전송")
                            .font           (.system(size: 20))
                            .padding        (10)
                            .foregroundColor(.white)
                            .background     (Color.blue)
                            .cornerRadius   (10)
                            .offset         (x: -11)
                    }
                }
            }
        }
        .alert(isPresented: $_isDeleteSelected) {
            Alert(
                title        : Text("Alert"),
                message      : Text("정말 삭제하시겠습니까?"),
                primaryButton: .default(Text("Delete")) {
                    _deleteMessage()
                },
                secondaryButton: .cancel()
            )
        }
        .task {
            if let userId = await User.myUserId(),
               let info = _tps.info() {
                _myUserId = userId
                await _nss.connect(trackId: info.trackId, userId: _myUserId, chats: $_chats, activeUser: $_activeUser)
                _nss.askHistory()
            }
        }
        .onDisappear {
            _nss.disconnect()
            _chats = []
        }
    }
}
