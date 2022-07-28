//
//  AppRow.swift
//  IPASigner
//
//  Created by SWING on 2022/7/19.
//

import SwiftUI
import SwiftUIWindow

struct AppRow: View {
    
    var app: AppBundle
    var icon: Image
    var name: String
    var bundleIdentifier: String
    var version: String
    
    var callBack: (() ->())?
    var removeAppCallBack: (() ->())?
    
    var body: some View {
        HStack {
            icon
                .resizable()
                .frame(width: 55, height: 55)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.init(.sRGB, red: 246/255, green: 246/255, blue: 246/255, opacity: 1), lineWidth: 1)
                )
     
            VStack(alignment: .leading) {
                Text(" \(name)")
                    .bold()
                Text(" 标识符: \(bundleIdentifier)")
                Text(" 版本: \(version)")
            }
            Spacer()
     
            Button.init {
                var signingOptions = SigningOptions(app: app.altApplication)
                signingOptions.appName = app.altApplication.name
                signingOptions.ipaPath = app.altApplication.fileURL.path
                signingOptions.appVersion = app.altApplication.version
                signingOptions.appDisplayName = app.altApplication.name
                signingOptions.appBundleId = app.altApplication.bundleIdentifier
                signingOptions.appMinimumiOSVersion = app.altApplication.minimumiOSVersion.stringValue
                SwiftUIWindow.open { _ in
                    SignView(signingOptions: signingOptions)
                }
                .clickable(true)
                .mouseMovesWindow(true)
            } label: {
                Text("签名")
                    .foregroundColor(.blue)
                Image(systemName: "pencil.and.outline")
                    .foregroundColor(.blue)
            }
//            .buttonStyle(BorderlessButtonStyle())

            Button.init {
                print("tapped button")
                self.removeAppCallBack?()

            } label: {
                Text("删除")
                    .foregroundColor(.red)
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }

        }
        .padding(.vertical, 7.5)
        
    }
}
