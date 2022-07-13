//
//  CertListView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct CertListView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .navigationTitle("证书")
            .toolbar{
                ToolbarItem(placement:.automatic){
                    Button(action:{
                        print("导入IPA")
                        
                    }){
                        Text("导入")
                            .bold()
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundColor(.blue)
                    }
                }
      
            }
    }
}

struct CertListView_Previews: PreviewProvider {
    static var previews: some View {
        CertListView()
    }
}
