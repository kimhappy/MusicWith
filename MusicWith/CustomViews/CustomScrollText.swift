//
//  CustomScrollText.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

public struct CustomScrollText: View {
    @State private var _animate = false

    private var _text      : String
    private var _font      : UIFont    = UIFont.preferredFont(forTextStyle: .body)
    private var _leftFade  : CGFloat   = 3.0
    private var _rightFade : CGFloat   = 3.0
    private var _startDelay: Double    = 0.0
    private var _alignment : Alignment = .leading
    private var _isCompact             = false

    public var body: some View {
        let stringWidth  = _text.widthOfString (usingFont: _font)
        let stringHeight = _text.heightOfString(usingFont: _font)

        let animation = Animation
            .linear       (duration: Double(stringWidth) / 30)
            .delay        (_startDelay)
            .repeatForever(autoreverses: false)

        let nullAnimation = Animation
            .linear(duration: 0)

        return ZStack {
            GeometryReader { geo in
                if stringWidth > geo.size.width { // don't use self.animate as conditional here
                    Group {
                        Text(self._text)
                            .lineLimit(1)
                            .font     (.init(_font))
                            .offset   (x: self._animate ? -stringWidth - stringHeight * 2 : 0)
                            .animation(self._animate ? animation : nullAnimation, value: self._animate)
                            .onAppear {
                                DispatchQueue.main.async {
                                    self._animate = geo.size.width < stringWidth
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            .frame    (minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)

                        Text(self._text)
                            .lineLimit(1)
                            .font     (.init(_font))
                            .offset   (x: self._animate ? 0 : stringWidth + stringHeight * 2)
                            .animation(self._animate ? animation : nullAnimation, value: self._animate)
                            .onAppear {
                                DispatchQueue.main.async {
                                    self._animate = geo.size.width < stringWidth
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            .frame    (minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .onValueChanged(of: self._text, perform: { _text in
                        self._animate = geo.size.width < stringWidth
                    })

                    .offset(x: _leftFade)
                    .mask(
                        HStack(spacing:0) {
                            Rectangle()
                                .frame  (width:2)
                                .opacity(0)
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                .frame(width: _leftFade)
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                .frame(width: _rightFade)
                            Rectangle()
                                .frame  (width:2)
                                .opacity(0)
                        })
                    .frame (width: geo.size.width + _leftFade)
                    .offset(x: _leftFade * -1)
                }
                else {
                    Text(self._text)
                        .font(.init(_font))
                        .onValueChanged(of: self._text, perform: { _text in
                            self._animate = geo.size.width < stringWidth
                        })
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: _alignment)
                }
            }
        }
        .frame(height: stringHeight)
        .frame(maxWidth: _isCompact ? stringWidth : nil)
        .onDisappear { self._animate = false }
    }

    public init(text: String, font: UIFont, leftFade: CGFloat, rightFade: CGFloat, startDelay: Double, alignment: Alignment? = nil) {
        self._text       = text
        self._font       = font
        self._leftFade   = leftFade
        self._rightFade  = rightFade
        self._startDelay = startDelay
        self._alignment  = alignment ?? .topLeading
    }

    public init(text: String) {
        self._text = text
    }

    public init(text: String, font: UIFont) {
        self._text = text
        self._font = font
    }

    public init(text: String, alignment: Alignment) {
        self._text      = text
        self._alignment = alignment
    }
}

extension CustomScrollText {
    public func makeCompact(_ compact: Bool = true) -> Self {
        var view        = self
        view._isCompact = compact
        return view
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size           = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size           = self.size(withAttributes: fontAttributes)
        return size.height
    }
}

extension View {
    // A backwards compatible wrapper for iOS 14 `onChange`
    @ViewBuilder func onValueChanged< T: Equatable >(of value: T, perform onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        }
        else {
            self.onReceive(Just(value)) { value in
                onChange(value)
            }
        }
    }
}
