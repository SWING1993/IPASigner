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
    
    let id = UUID()
    //var signedDate = Date().toString(.custom("yyyy-MM-dd HH:mm:ss"))
    var ipaName = ""
    var iconName = ""
    var signedCertificateName = ""
    var name = ""
    var bundleIdentifier = ""
    var version = ""
    var minimumiOSVersion = ""
    var log = ""
    var deleted = false

    required init() {}

}
