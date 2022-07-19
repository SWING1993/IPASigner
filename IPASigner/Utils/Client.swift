//
//  Client.swift
//  IPASigner
//
//  Created by SWING on 2022/7/19.
//

import Foundation


class Client: NSObject {
    
    public static let shared = Client()
    
    let store = YTKKeyValueStore.init(dbWithName: "IPASigner/Data.db")
    
    
}
