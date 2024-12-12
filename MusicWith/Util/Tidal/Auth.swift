//
//  Auth.swift
//  MusicWith
//
//  Created by kimhappy on 12/3/24.
//

import EventProducer
import Auth
import AuthenticationServices

enum AuthState {
    case idle
    case loggedIn

    public func token() async -> String? {
        switch self {
        case .idle:
            return nil

        case .loggedIn:
            return try? await TidalAuth.shared.getCredentials().token
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

    private init() {
        TidalAuth       .shared.config(config: Auth._AUTH_CONFIG )
        TidalEventSender.shared.config(        Auth._EVENT_CONFIG)

        if TidalAuth.shared.isUserLoggedIn {
            state = .loggedIn
        }
    }

    @Published var state: AuthState = .idle

    @MainActor
    public func login() async -> ()? {
        class _PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
            public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
                ASPresentationAnchor()
            }
        }

        guard let loginUrl = TidalAuth.shared.initializeLogin(
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
              let _ = try? await TidalAuth.shared.finalizeLogin(loginResponseUri: responseUrl)
        else {
            return nil
        }

        self.state = .loggedIn
        return ()
    }

    public func logout() -> ()? {
        guard let _ = try? TidalAuth.shared.logout() else { return nil }
        state = .idle
        return ()
    }
}
