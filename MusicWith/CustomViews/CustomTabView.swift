//
//  CustomTabView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct CustomTabView< Content: View >: View {
    private let _isTop   : Bool
    private let _tabCount: Int
    private let _content : Content

    @Binding private var _selection: Int

    public init(isTop: Bool, selection: Binding< Int >, tabCount: Int, @ViewBuilder content: () -> Content) {
        self._isTop      = isTop
        self.__selection = selection
        self._tabCount   = tabCount
        self._content    = content()
    }

    public var body: some View {
        if _isTop {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Array(0..<_tabCount), id: \.self) { index in
                        Rectangle()
                            .fill (index == _selection ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
                TabView(selection: $_selection) {
                    _content
                }
                .tabViewStyle(.page)
            }
        }
        else {
            VStack(spacing: 0) {
                TabView(selection: $_selection) {
                    _content
                }
                .tabViewStyle(.page)
                HStack(spacing: 0) {
                    ForEach(Array(0..<_tabCount), id: \.self) { index in
                        Rectangle()
                            .fill (index == _selection ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}
