//
//  AppNavigationView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct AppNavigationView: View {
    
    @State var selection: Int?
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AppListView(), tag: 0, selection: self.$selection) {
                    NavigationRow.init(title: "应用", image: Image(systemName: "shippingbox.circle.fill"))
                }
      
                NavigationLink(destination: SignedAppListView(), tag: 1, selection: self.$selection) {
                    NavigationRow.init(title: "已签名", image: Image(systemName: "pencil.circle.fill"))
                }
                
                NavigationLink(destination: CertListView(), tag: 2, selection: self.$selection) {
                    NavigationRow.init(title: "证书", image: Image(systemName: "bookmark.circle.fill"))
                }
                
                NavigationLink(destination: SettingsView(), tag: 3, selection: self.$selection) {
                    NavigationRow.init(title: "设置", image: Image(systemName: "gear.circle.fill"))
                }
                
                /*
                NavigationLink {
                    AppListView()
                } label: {
                    NavigationRow.init(title: "应用", image: Image(systemName: "shippingbox.circle.fill"))
                    // a.square.fill
                }
                .tag(0)
                
                NavigationLink {
                    SignedAppListView()
                } label: {
                    NavigationRow.init(title: "已签名", image: Image(systemName: "pencil.circle.fill"))
                }
                .tag(1)
                
                NavigationLink {
                    CertListView()
                } label: {
                    NavigationRow.init(title: "证书", image: Image(systemName: "bookmark.circle.fill"))
                }
                .tag(2)
                
                NavigationLink {
                    SettingsView()
                } label: {
                    NavigationRow.init(title: "设置", image: Image(systemName: "gear.circle.fill"))
                }
                .tag(3)
                 */
            }
            .frame(minWidth: 150, maxWidth: 250)
            .toolbar {
                Spacer()
            }
        }.onAppear {
            self.selection = 0
        }
    }
}

struct AppNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AppNavigationView()
    }
}
