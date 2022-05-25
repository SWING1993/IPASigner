//
//  SigningOptions.swift
//  IPASigner
//
//  Created by SWING on 2022/5/20.
//

import Foundation

struct SigningOptions {
    
    var ipaPath: String = ""
    var cert: String = ""
    var profile: String = ""
    var appBundleId: String = ""
    var appDisplayName: String = ""
    var appVersion: String = ""
    var appMinimumiOSVersion: String = ""
    var deletePluglnsfolder = false
    var deleteWatch = true
    var removeMinimumiOSVersion = false

    var app: ALTApplication?
    var signingCert: ALTCertificate?
    var signingProfile: ALTProvisioningProfile?
    
}