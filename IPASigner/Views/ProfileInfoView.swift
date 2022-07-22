//
//  ProfileInfoView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/22.
//

import SwiftUI

struct ProfileInfoView: View {
    
    @State var profile: ALTProvisioningProfile
    
    var body: some View {
   
     
        let infos = ["App ID Name: \(profile.name)",
                     "App ID: \(profile.bundleIdentifier)",
                     "UUID: \(profile.uuid.uuidString)",
                     "Team: \(profile.teamName)",
                     "teamIdentifier ID: \(profile.teamIdentifier)",
                     "Creation Date: \(profile.creationDate)",
                     "Expiration Date: \(profile.expirationDate)"]
        VStack {
            List {
                Section(header: Text("描述文件").bold()) {
                    ForEach(0..<infos.count, id: \.self) { index in
                        let info = infos[index]
                        Text(info)
                    }
                }
               
                Section(header: Text("Certificates(\(profile.certificates.count))").bold()) {
                    ForEach(0..<profile.certificates.count, id: \.self) { index in
                        let cert = profile.certificates[index]
                        Text(cert.name)
                    }
                }
                if profile.deviceIDs.count > 0 {
                    Section(header: Text("DevicesUDIDs(\(profile.deviceIDs.count))").bold()) {
                        ForEach(0..<profile.deviceIDs.count, id: \.self) { index in
                            let udid = profile.deviceIDs[index]
                            Text(udid)
                        }
                    }
                }
             
            }
            .background(Color.white)
            
        }
        .background(Color.white)
    }
}

