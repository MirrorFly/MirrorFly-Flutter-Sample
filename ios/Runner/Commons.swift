//
//  Commons.swift
//  Runner
//
//  Created by ManiVendhan on 09/11/22.
//

import Foundation

class Commons{
    
    
    static func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}
