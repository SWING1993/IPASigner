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


//    var dylibDirectory: URL {
//        return self.documentDirectory.appendingPathComponent("Dylibs", isDirectory: true)
//    }

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
    
    
    var signedAppsDirectory: URL {
        return self.documentDirectory.appendingPathComponent("IPASigner/SignedApps", isDirectory: true)
    }

    func createDefaultDirectory() {
        let urls = [FileManager.default.appsDirectory,
                    FileManager.default.profilesDirectory,
                    FileManager.default.certificatesDirectory,
                    FileManager.default.signedAppsDirectory,
                    FileManager.default.logDirectory,
                    FileManager.default.tempDirectory]
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
    
    func clearSignedAppData() {
//        if FileManager.default.fileExists(atPath: FileManager.default.unzipIPADirectory.path) {
//            do {
//                print("清理ipa解压文件夹")
//                try FileManager.default.removeItem(at: FileManager.default.unzipIPADirectory)
//            } catch let error {
//                print("清理ipa解压文件夹失败，\(error.localizedDescription)")
//            }
//        }
    }
}

