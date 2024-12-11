//
//  Auth.swift
//  MusicWith
//
//  Created by kimhappy on 12/3/24.
//

import EventProducer
import Auth
import AuthenticationServices

struct TidalAuthInfo {
    var auth       : TidalAuth
    var eventSender: TidalEventSender
}

enum AuthState {
    case idle
    case loggedIn(TidalAuthInfo)

    public func auth() -> TidalAuth? {
        switch self {
        case .idle:
            return nil

        case .loggedIn(let info):
            return info.auth
        }
    }

    public func eventSender() -> TidalEventSender? {
        switch self {
        case .idle:
            return nil

        case .loggedIn(let info):
            return info.eventSender
        }
    }

    public func token() async -> String? {
        switch self {
        case .idle:
            return nil

        case .loggedIn(let info):
            return try? await info.auth.getCredentials().token
        }
    }
}

class Auth: ObservableObject {
    static private let _CLIENT_ID                        = "tzfjQ4wkhk1IALRq"
    static private let _CLIENT_UNIQUE_KEY                = UUID().uuidString
    static private let _CREDENTIALS_KEY                  = Bundle.main.bundleIdentifier!
    static private let _SCOPES           : Set< String > = ["playlists.read", "entitlements.read", "collection.read", "user.read", "recommendations.read", "playback"]
    static private let _CUSTOM_SCHEME                    = Bundle.main.bundleIdentifier!
    static private let _REDIRECT_URI                     = Bundle.main.bundleIdentifier! + "://login"
    static private let _AUTH_CONFIG                      = AuthConfig(
        clientId       : _CLIENT_ID        ,
        clientUniqueKey: _CLIENT_UNIQUE_KEY,
        credentialsKey : _CREDENTIALS_KEY  ,
        scopes         : _SCOPES
    )
    static private let _EVENT_CONFIG = EventConfig(
        credentialsProvider     : TidalAuth.shared,
        maxDiskUsageBytes       : 1_000_000       ,
        blockedConsentCategories: []
    )
    static private let _LOGIN_CONFIG = LoginConfig(customParams: [QueryParameter(key: "appMode", value: "iOS")])

    static public var shared = Auth()
    private init() {}

    @Published var state: AuthState = .idle

    @MainActor
    public func login() async -> ()? {
        class _PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
            public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
                ASPresentationAnchor()
            }
        }

        let auth        = TidalAuth       .shared
        let eventSender = TidalEventSender.shared

        auth       .config(config: Auth._AUTH_CONFIG )
        eventSender.config(        Auth._EVENT_CONFIG)

        guard let loginUrl = auth.initializeLogin(
            redirectUri: Auth._REDIRECT_URI,
            loginConfig: Auth._LOGIN_CONFIG),
              let responseUrl: String = await withCheckedContinuation({ continuation in
            let webAuthSession = ASWebAuthenticationSession(
                url              : loginUrl           ,
                callbackURLScheme: Auth._CUSTOM_SCHEME,
                completionHandler: { [weak self] callbackURL, error in
                    if self != nil,
                       let responseUrl = callbackURL?.absoluteString {
                        continuation.resume(returning: responseUrl)
                    }
                    else {
                        continuation.resume(returning: nil)
                    }
                })
            let contextProvider                              = _PresentationContextProvider()
            webAuthSession.presentationContextProvider       = contextProvider
            webAuthSession.prefersEphemeralWebBrowserSession = false
            webAuthSession.start()
        }),
              let _ = try? await auth.finalizeLogin(loginResponseUri: responseUrl)
        else {
            return nil
        }

        let authInfo = TidalAuthInfo(auth: auth, eventSender: eventSender)
        self.state   = .loggedIn(authInfo)
        return ()
    }

    public func logout() {
        state = .idle
    }
}
