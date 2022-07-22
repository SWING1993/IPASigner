//
//  CertRow.swift
//  IPASigner
//
//  Created by SWING on 2022/7/20.
//

import SwiftUI
import SwiftUIWindow

struct CertRow: View {
    
    @State var cert: Cert
    

    var body: some View {
        let expireDate = Date.init(timeIntervalSince1970: TimeInterval(cert.altCertInfo.expireTime))
        let expireDateString = self.dateToString(expireDate)
        
        HStack {
            Image.init("cert")
                .resizable()
                .frame(width: 70, height: 61)

            VStack(alignment: .leading) {
                Text(" \(cert.altCertInfo.name)")
                    .bold()
                Text(" 过期时间：\(expireDateString)")
                if let altProfile = cert.altProfile {
                    HStack {
                        Text(" 描述文件：\(altProfile.name)")
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                
                                SwiftUIWindow.open { _ in
                                    ProfileInfoView(profile: altProfile)
                                        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)

                                }
                                .clickable(true)
                                .mouseMovesWindow(true)
                            }
                    }
                } else {
                    Text(" 未导入描述文件")
                        .foregroundColor(.red)
                }
//                Text(" 序列号: \(cert.altCert.serialNumber)")
//                Text(" 国家或地区: \(cert.altCertInfo.country)")
//                Text(" 组织: \(cert.altCertInfo.organization)")
//                Text(" 组织单位: \(cert.altCertInfo.organizationUnit)")
//                Text(" 用户ID: \(cert.altCertInfo.userID)")
            }
            
            Spacer()
            


            
            if expireDate < Date() {
                // 已过期
                Text(" 证书已过期")
                    .foregroundColor(.red)
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            } else {
                if cert.altCertInfo.revoked {
                    Text(" 证书已撤销")
                        .foregroundColor(.red)
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                } else {
                    Text(" 证书有效")
                        .foregroundColor(.green)
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 7.5)
        

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

