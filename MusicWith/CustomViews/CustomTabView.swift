//
//  CustomTabView.swift
//  HappyTest
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct CustomTabView< Content: View >: View {
    var isTop: Bool
    @Binding var selection: Int

    let tabCount: Int
    let content : Content

    init(isTop: Bool, selection: Binding< Int >, tabCount: Int, @ViewBuilder content: () -> Content) {
        self.isTop      = isTop
        self._selection = selection
        self.tabCount   = tabCount
        self.content    = content()
    }

    var body: some View {
        if isTop {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Array(0..<tabCount), id: \.self) { index in
                        Rectangle()
                            .fill(index == selection ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
                TabView(selection: $selection) {
                    content
                }
                .tabViewStyle(.page)
            }
        }
        else {
            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    content
                }
                .tabViewStyle(.page)
                HStack(spacing: 0) {
                    ForEach(Array(0..<tabCount), id: \.self) { index in
                        Rectangle()
                            .fill(index == selection ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
