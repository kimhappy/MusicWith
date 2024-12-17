//
//  Query.swift
//  MusicWith
//
//  Created by kimhappy on 12/5/24.
//

import Foundation

class Query {
    private init() {}

    static public let TIDAL_ADDRESS = "openapi.tidal.com/v2"
    static public let MW_ADDRESS    = "34.122.154.52:8000"

    static public func getTidalJson(_ link: String) async -> Any? {
        guard let token = await Auth.shared.state.token(),
              let url   = URL(string: "https://\(TIDAL_ADDRESS)\(link)")
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "accept"       )
        request.setValue("Bearer \(token)"         , forHTTPHeaderField: "Authorization")

        let data = try? await URLSession.shared.data(for: request).0
        return data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
    }

    static public func getMwJson(_ link: String) async -> Any? {
        guard let url = URL(string: "http://\(MW_ADDRESS)\(link)")
        else {
            return nil
        }

        let request = URLRequest(url: url)
        let data    = try? await URLSession.shared.data(for: request).0
        return data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
    }
}
