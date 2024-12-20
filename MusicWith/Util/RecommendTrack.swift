//
//  RecommendTrack.swift
//  MusicWith
//
//  Created by user on 12/18/24.
//

import Foundation

struct RecommendTrack {
    private init() {}

    private static var _list: [(String, Int)] = []

    public static func tracks() async -> [(String, Int)]? {
        if !_list.isEmpty {
            return _list
        }
        
        guard let items  = await Query.getMwJson("/hot") as? [[String: Any]],
              let tracks = items.mapOptional({ (item: [String: Any]) -> (String, Int)? in
                  guard let track_id     = item[ "track_id"     ] as? String,
                        let num_comments = item[ "num_comments" ] as? Int else { return nil }
                  return (track_id, num_comments)
              })
        else {
            return [];
        }
        
        _list = tracks
        return tracks
    }
}
