//
//  FileManager+SharedDirectories.swift
//  AltStore
//
//  Created by Riley Testut on 5/14/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

import Foundation

public extension FileManager {
    
    var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var cacheDirectory: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    var iconDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/Icon", isDirectory: true)
    }
    
    var logDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/Log", isDirectory: true)
    }
    
    var tempDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/Temp", isDirectory: true)
    }
    
    var appsDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/Apps", isDirectory: true)
    }
    
    var profilesDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/Profiles", isDirectory: true)
    }
    
    
    var certificatesDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/Certificates", isDirectory: true)
    }
    
    var signedIPAsDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/SignedIPAs", isDirectory: true)
    }

    func createDefaultDirectory() {
        let urls = [FileManager.default.appsDirectory,
                    FileManager.default.profilesDirectory,
                    FileManager.default.certificatesDirectory,
                    FileManager.default.signedIPAsDirectory,
                    FileManager.default.logDirectory,
                    FileManager.default.tempDirectory,
                    FileManager.default.iconDirectory]
        for url in urls {
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }

}

