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
   
     
        let infos = [("Name", profile.name),
                     ("App ID", profile.bundleIdentifier),
                     ("UUID",profile.uuid.uuidString),
                     ("Team",profile.teamName),
                     ("teamIdentifier ID", profile.teamIdentifier),
                     ("Creation Date",self.dateToString(profile.creationDate)),
                     ("Expiration Date",self.dateToString(profile.expirationDate))]
        VStack {
            List {
                Section(header: Text("描述文件")
                    .font(Font.title2)
                    .foregroundColor(.black)) {
                    ForEach(0..<infos.count, id: \.self) { index in
                        HStack {
                            let info = infos[index]
                            Text("\(info.0): ").bold()
                            Text(info.1)
                        }
                        
                    }
                }
               
                Section(header: Text("Certificates(\(profile.certificates.count))")
                    .font(Font.title2)
                    .foregroundColor(.black)) {
                    ForEach(0..<profile.certificates.count, id: \.self) { index in
                        let cert = profile.certificates[index]
                        Text(cert.name)
                    }
                }
                if profile.deviceIDs.count > 0 {
                    Section(header: Text("DevicesUDIDs(\(profile.deviceIDs.count))")
                        .font(Font.title2)
                        .foregroundColor(.black)
                    ) {
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
    
    // 日期 -> 字符串
    func dateToString(_ date:Date, dateFormat:String = "yyyy年MM月dd日 HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
}

