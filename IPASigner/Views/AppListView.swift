//
//  AppListView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct AppListView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .navigationTitle("应用")
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

struct AppListView_Previews: PreviewProvider {
    static var previews: some View {
        AppListView()
    }
}
