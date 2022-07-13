//
//  NavigationRow.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct NavigationRow: View {
    
    var title: String
    var image: Image
    
    var body: some View {
        HStack {
            image
                .resizable()
                .frame(width: 25, height: 25)
                .cornerRadius(12.5)
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
            }

            Spacer()
        }
        .padding(.vertical, 7.5)
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRow.init(title: "N", image: Image(systemName: "square.and.pencil"))
    }
}
