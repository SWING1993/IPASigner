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

    var body: some View {
        HStack {
            icon
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(name)
                    .bold()
                Text(bundleIdentifier)
                Text(version)
            }

            Spacer()
        }
        .padding(.vertical, 7.5)
    }
}

//struct AppRow_Previews: PreviewProvider {
//    static var previews: some View {
//        AppRow.init(icon: <#T##Image#>, name: <#T##String#>, bundleIdentifier: <#T##String#>, version: <#T##String#>)
//    }
//}
