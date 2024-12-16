//
//  User.swift
//  MusicWith
//
//  Created by kimhappy on 12/5/24.
//

import Foundation

struct User {
    private static var _storage: [String: User] = [:]

    public var name: String

    private static func _load< T >(_ id: String, _ get: (Self?) -> T?) async -> T? {
        if let ret = get(_storage[ id ]) {
            return ret
        }

        guard let json       = await Query.getTidalJson("/users/\(id)") as? [String: Any],
              let data       = json      [ "data"       ]               as? [String: Any],
              let attributes = data      [ "attributes" ]               as? [String: Any],
              let name       = attributes[ "firstName"  ]               as?  String ??
                               attributes[ "lastName"   ]               as?  String ??
                               attributes[ "username"   ]               as?  String
        else {
            return nil
        }

        _storage[ id ] = Self(name: name)
        return get(_storage[ id ])
    }

    public static func user(_ id: String) async -> User? {
        return await _load(id) {
            $0
        }
    }

    public static func name(_ id: String) async -> String? {
        return await _load(id) {
            $0?.name
        }
    }
}
