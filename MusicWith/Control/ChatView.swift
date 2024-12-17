//
//  ChatView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

private struct _MessageView: View {
    @ObservedObject private var _css = ChatState.shared

    @Environment(\.colorScheme) private var _colorSchema

    public let chat    : Chat
    public let indent  : CGFloat
    public let onReply :  () -> Void
    public let onDelete: (() -> Void)?

    public var body: some View {
        HStack {
            Text("")
                .padding()
                .padding(.leading, 4 + indent)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(chat.name)
                        .font           (.headline)
                        .foregroundColor(_css.online.contains(chat.userId) ? .red : _colorSchema == .dark ? .white : .black)
                    Spacer()
                    if let time = chat.time, case nil = chat.replyTo {
                        Text(timeFormat(Int(time)))
                            .font           (.subheadline)
                            .foregroundColor(.blue)
                            .padding        (.trailing, 20)
                    }
                }

                Text(chat.content ?? "삭제됨")
                    .font     (.title3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    if case nil = chat.replyTo {
                        Button(action: {
                            onReply()
                        }) {
                            Text("답글")
                        }
                        .font           (.subheadline)
                        .foregroundColor(.blue)
                    }

                    Spacer()

                    if let onDelete {
                        Button(action: {
                            onDelete()
                        }) {
                            Text("삭제")
                                .font   (.subheadline)
                                .padding(.trailing)
                        }
                    }
                }
                Divider()
                    .background(.gray)
                    .frame(width: 250, height: 1)
                    .padding(.top, 20)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .black, location: 0.2),
                                .init(color: .black, location: 0.8),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(.vertical, chat.replyTo == nil ? 10 : 5)
        }
    }
}

struct ChatView: View {
    @ObservedObject private var _css                       = ChatState  .shared
    @ObservedObject private var _tps                       = TrackPlayer.shared
    @State          private var _messageText     : String  = ""
    @State          private var _isSelected      : Bool    = false
    @State          private var _selectedParent  : Chat?   = nil
    @State          private var _isDeleteSelected: Bool    = false
    @State          private var _selectedDelete  : Chat?   = nil
    @State          private var _myUserId        : String? = nil

    @Environment(\.colorScheme) private var _colorSchema

    private func _sendMessage() {
        guard !_messageText.isEmpty,
              let info = _tps.info()
        else {
            return
        }

        if _isSelected {
            _css.sendChat(content: _messageText, replyTo: _selectedParent!.chatId)
            _messageText    = ""
            _isSelected     = false
            _selectedParent = nil
        }
        else {
            _css.sendChat(content: _messageText, time: info.now)
            _messageText = ""
        }
    }

    private func _deleteMessage() {
        guard let selectedDeleteId = _selectedDelete?.chatId else { return }
        _css.sendDelete(chatId: selectedDeleteId)
        _isDeleteSelected = false
        _selectedDelete   = nil
    }

    private func _parentChats() -> [Chat] {
        _css.chat.filter { $0.replyTo == nil }
    }

    private func _replies(_ chatId: String) -> [Chat] {
        _css.chat.filter { $0.replyTo == chatId }
    }

    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(_parentChats(), id: \.chatId) { chat in
                        _MessageView(
                            chat       : chat        ,
                            indent     : 0           ,
                            onReply    : {
                                _isSelected     = true
                                _selectedParent = chat
                            },
                            onDelete   : chat.userId == _myUserId ? {
                                _isDeleteSelected = true
                                _selectedDelete   = chat
                            } : nil
                        )
                        ForEach(_replies(chat.chatId), id: \.chatId) { replyChat in
                            _MessageView(
                                chat       : replyChat   ,
                                indent     : 50          ,
                                onReply    : {}          ,
                                onDelete   : chat.userId == _myUserId ? {
                                    _isDeleteSelected = true
                                    _selectedDelete   = replyChat
                                } : nil
                            )
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                if _isSelected, let parent = _selectedParent {
                    HStack {
                        Text(" \(parent.name) 에게 답장 중")
                            .font           (.body)
                            .foregroundColor(.blue)
                            .padding        (.leading, 20)
                            .padding        (.top, 5)
                        Spacer()
                        Text("취소")
                            .padding(.trailing, 30)
                            .onTapGesture {
                                _isSelected     = false
                                _selectedParent = nil
                            }
                    }
                    .padding(.vertical, 5)
                }

                HStack {
                    TextField("입력", text: $_messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font          (.system(size: 20))
                        .padding       ()
                        .padding       (.bottom, 20)
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
                            .padding        (.bottom, 20)
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
            _myUserId = await Auth.shared.state.myUserId()
        }
    }
}
