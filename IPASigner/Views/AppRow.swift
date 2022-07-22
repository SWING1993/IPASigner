//
//  AppRow.swift
//  IPASigner
//
//  Created by SWING on 2022/7/19.
//

import SwiftUI

struct AppRow: View {
    
    var icon: Image
    var name: String
    var bundleIdentifier: String
    var version: String
    
    var callBack: (() ->())?
    
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
                Text(" Name: \(name)")
                    .bold()
                Text(" Identifier: \(bundleIdentifier)")
                Text(" Version: \(version)")
            }

            Spacer()
            
  
            Button.init {
                print("tapped button")
                self.callBack?()

            } label: {
                Text("导出")
                    .foregroundColor(.blue)
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
            }
//            .buttonStyle(BorderlessButtonStyle())
            
            Button.init {
                print("tapped button")
                self.callBack?()

            } label: {
                Text("签名")
                    .foregroundColor(.blue)
                Image(systemName: "pencil.and.outline")
                    .foregroundColor(.blue)
            }
//            .buttonStyle(BorderlessButtonStyle())

            Button.init {
                print("tapped button")
                self.callBack?()

            } label: {
                Text("删除")
                    .foregroundColor(.red)
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
//            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 7.5)
    }
}