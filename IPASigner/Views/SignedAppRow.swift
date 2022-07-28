//
//  SignedAppRow.swift
//  IPASigner
//
//  Created by SWING on 2022/7/28.
//

import SwiftUI

struct SignedAppRow: View {
    
    var ipa: SignedIPAModel
    var icon: Image
    
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
                Text(" Name: \(ipa.name)")
                    .bold()
                Text(" Identifier: \(ipa.bundleIdentifier)")
                Text(" Version: \(ipa.version)")
            }

            Spacer()
            
            Button.init {
                print("tapped button")
                
            } label: {
                Text("导出")
                    .foregroundColor(.blue)
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
            }
    
            Button.init {
                print("tapped button")
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
