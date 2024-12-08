//
//  User.swift
//  MusicWith
//
//  Created by kimhappy on 12/5/24.
//

import Foundation

struct User {
    private static var _storage: [String: User] = [:]

    public var name : String
    public var image: String

    public static func myUserId() async -> String? {
        guard let url  = URL(string: "https://openapi.tidal.com/v2/users/me"),
              let json = await Query.getTidalJson(url),
              let data = json[ "data" ] as? [String: Any]
        else {
            return nil
        }

        return data[ "id" ] as? String
    }

    private static func _load< T >(_ id: String, _ get: (Self?) -> T?) async -> T? {
        if let ret = get(_storage[ id ]) {
            return ret
        }

        guard let url   = URL(string: "http://http://127.0.0.1:8000/user/\(id)"),
              let json  = await Query.getMwJson(url),
              let name  = json[ "name"  ] as? String,
              let image = json[ "image" ] as? String
        else {
            return nil
        }

        // TODO: Self(name: name, image: image)
        _storage[ id ] = Self(name: "USER \(id)", image: "https://placehold.co/80")
        return get(_storage[ id ])
    }

    public static func name(_ id: String) async -> String? {
        return await _load(id) {
            $0?.name
        }
    }

    public static func image(_ id: String) async -> String? {
        return await _load(id) {
            $0?.image
        }
    }
}
