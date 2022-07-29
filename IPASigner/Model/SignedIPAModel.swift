//
//  SignedIPAModel.swift
//  IPASigner
//
//  Created by SWING on 2022/7/28.
//

import Foundation
import HandyJSON
import Swift

class SignedIPAModel: HandyJSON, Identifiable {
    
    let uuid = UUID()
    
    var id = ""
    var filePath = ""
    var name = ""
    var iconName = ""
    var signedCertificateName = ""
    var signedProfileName = ""
    var signedDate = ""
    var bundleIdentifier = ""
    var version = ""
    var minimumiOSVersion = ""
    var log = ""
    var deleted = false

    required init() {}

}
