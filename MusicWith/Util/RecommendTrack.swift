//
//  RecommendTrack.swift
//  MusicWith
//
//  Created by user on 12/18/24.
//
import Foundation

struct RecommendTrack {
    private static var _list : [String] = []
    
    public static func tracks() async -> [String] {
        if !_list.isEmpty {
            return _list
        }
        
        guard let items = await Query.getMwJson("/hot") as? [[String: Any]] else {
            return [];
        }
        
        var tracks : [String] = []
        
        for item in items {
            guard let num_comments = item["num_comments"] as? Int       else {return []}
            guard let track_id = item["track_id"]         as? String    else {return []}
            tracks.append(track_id)
        }
        
        _list = tracks
        return tracks
    }
}
