import SwiftUI

struct ControlCoreView: View {
    @Environment(\.colorScheme) private var _colorSchema

    @StateObject private var _tps           = TrackPlayer.shared
    @State       private var _trackName     = ""
    @State       private var _trackArtist   = ""
    @State       private var _trackImageUrl = ""
    @State       private var _isDragging    = false
    @State       private var _sliderValue   = 0.0

    public var body: some View {
        if let info = _tps.info() {
            let iconName = if case .playing = _tps.state { "pause" } else { "play" }

            HStack {
                AsyncImage(url: URL(string: _trackImageUrl)) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    CustomScrollText(text: _trackName, font: UIFont.preferredFont(forTextStyle: .headline))
                        .frame(width : 100)
                        .font(.headline)
                    CustomScrollText(text: _trackArtist, font: UIFont.preferredFont(forTextStyle: .headline))
                        .frame(width : 100)
                        .font(.subheadline)
                }
                VStack(alignment: .center) {
                    HStack {
                        Button(action : {
                            _tps.prev()
                        }) {
                            Image(systemName: "backward.fill")
                                .frame(width: 50, height: 50)
                                .foregroundStyle(_colorSchema == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 5)
                        Button(action: { _tps.toggle() }) {
                            Image(systemName: iconName)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(_colorSchema == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 5)
                        Button(action : {
                            _tps.next()
                        }) {
                            Image(systemName: "forward.fill")
                                .frame(width: 50, height: 50)
                                .foregroundStyle(_colorSchema == .dark ? .white : .black)
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.top, 80)

                    Slider(
                        value: Binding(
                            get: {
                                _isDragging ? _sliderValue : info.now
                            },
                            set: { newValue in
                                _sliderValue = newValue

                                if !_isDragging {
                                    _tps.seek(newValue)
                                }
                            }
                        ),
                        in: 0...info.duration,
                        onEditingChanged: { isEditing in
                            _isDragging = isEditing

                            if !isEditing {
                                _tps.seek(_sliderValue)
                            }
                        }
                    )
                    .tint(.black)

                    HStack {
                        Text(timeFormat(lround(_isDragging ? _sliderValue : info.now)))
                            .font(.caption)
                        Spacer()
                        Text(timeFormat(lround(info.duration)))
                            .font(.caption)
                    }
                    .padding(.bottom, 50)
                }
            }
            .task(id: info.trackId) {
                _trackName     = await Track.name    (info.trackId) ?? ""
                _trackArtist   = await Track.artist  (info.trackId) ?? ""
                _trackImageUrl = await Track.imageUrl(info.trackId) ?? ""
            }
            .padding()
        }
        else {
            EmptyView()
        }
    }
}
