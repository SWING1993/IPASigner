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

    @State var leftIndex = 0

    let leftSource = (0..<10).map { $0%2 == 0 ? "🧜‍♀️\($0)":"🧚‍♀️\($0)" }

    
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
            
            //ellipsis
            
      
            
         
            Button("删除") {
             
            }
            .foregroundColor(.red)
//
//
//            Button("签名") {
//
//            }
//            .foregroundColor(.blue)

            
           
        }
        .padding(.vertical, 7.5)
    }
}
