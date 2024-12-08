//
//  MapOptional.swift
//  MusicWith
//
//  Created by kimhappy on 12/9/24.
//

extension Sequence {
    func mapOptional< U >(_ transform: (Element) -> U?) -> [U]? {
        var result: [U] = []

        for element in self {
            guard let value = transform(element)
            else {
                return nil
            }

            result.append(value)
        }
        
        return result
    }
}
