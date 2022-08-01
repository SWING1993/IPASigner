//
//  SignedAppListView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct SignedAppListView: View {
    
    @State private var signedIPAList: [SignedIPAModel] = []
    @State private var selectedIPA: SignedIPAModel?
    
    @State private var showingAlert = false
    @State private var alertTitle: String = "提示"
    @State private var alertMessage: String = ""
    
    var body: some View {
        if self.signedIPAList.count <= 0 {
            Text("暂无数据")
                .onAppear {
                    getDataSource()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
                .navigationTitle("已签名")
                
        } else {
            List($signedIPAList) { $ipa in
                SignedAppRow(ipa: ipa) {
                    Client.shared.store?.deleteObject(byId: ipa.id, fromTable: "signedIPAsTable")
                    let index = self.signedIPAList.firstIndex { i in
                        return ipa.id == i.id
                    }
                    if let index = index {
                        do {
                            try FileManager.default.removeItem(at: URL(fileURLWithPath: ipa.filePath))
                            self.signedIPAList.remove(at:index)
                        } catch let error {
                            print(error)
                            //self.alertMessage = "删除\(ipa.name)失败，\(error.localizedDescription)"
                            //self.showingAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
            .navigationTitle("已签名")
        }
    }
    
    func getDataSource() {
        var ipaList: [SignedIPAModel] = []
        if let results: [YTKKeyValueItem] = Client.shared.store?.getAllItems(fromTable: "signedIPAsTable") as? [YTKKeyValueItem] {
            for item in results {
                if let array: [String] = item.itemObject as? [String] {
                    print(array)
                    if array.count > 0 {
                        if let json: String = array.first {
                            print(json)
                            if let signedIPA = SignedIPAModel.deserialize(from: json) {
                                ipaList.append(signedIPA)
                            } else {
                                Client.shared.store?.deleteObject(byId: item.itemId, fromTable: "signedIPAsTable")
                            }
                        }
                    }
                }
            }
        }
        self.signedIPAList = ipaList
    }
}

struct SignedAppListView_Previews: PreviewProvider {
    static var previews: some View {
        SignedAppListView()
    }
}
