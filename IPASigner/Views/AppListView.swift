//
//  AppListView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct AppListView: View {
    
    @State private var appList: [AppBundle] = []
    @State private var selectedApp: AppBundle?
    
    @State private var showingAlert = false
    @State private var alertTitle: String = "提示"
    @State private var alertMessage: String = ""
    
    var body: some View {

        if self.appList.count <= 0 {
            Text("点击右上角「导入」按钮导入IPA或APP")
                .onAppear {
                    getDataSource()
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
                .navigationTitle("应用")
                    .toolbar{
                        ToolbarItem(placement:.automatic){
                            Button(action:{
                                print("导入IPA")
                                doBrowse()
                            }){
                                Text("导入")
                                    .bold()
                                Image(systemName: "tray.and.arrow.down.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
        } else {
            List($appList) { $app in
                AppRow(app: app, icon: Image.init(nsImage: app.icon), name: app.altApplication.name, bundleIdentifier: app.altApplication.bundleIdentifier, version: app.altApplication.version) {
                } removeAppCallBack: {
                    let index = self.appList.firstIndex { a in
                        return app.id == a.id
                    }
                    if let index = index {
                        do {
                            try FileManager.default.removeItem(at: app.altApplication.fileURL)
                            self.appList.remove(at:index)
                        } catch let error {
                            self.alertMessage = "删除\(app.altApplication.name)失败，\(error.localizedDescription)"
                            self.showingAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
            .navigationTitle("应用")
                .toolbar{
                    ToolbarItem(placement:.automatic){
                        Button(action:{
                            print("导入IPA")
                            doBrowse()
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

    
    func doBrowse() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = panel.urls.first {
                    print("选择的File：\(url.absoluteString)")
                    if url.pathExtension.lowercased() == "ipa" {
                        unzipIPA(url)
                    } else if url.pathExtension.lowercased() == "app" {
                        saveData(fileURL: url)
                    } else {
                        self.alertMessage = "请选择ipa或者app文件"
                        self.showingAlert = true
                    }
                }
            }
        }
    }
    
    func unzipIPA(_ fileURL: URL) {
        let uuid = UUID().uuidString
        let workingDirectory = FileManager.default.appsDirectory.appendingPathComponent(uuid)
        let payloadDirectory = workingDirectory.appendingPathComponent("Payload")
        do {
            let appBundleURL = try FileManager.default.unzipAppBundle(at: URL.init(fileURLWithPath: fileURL.path), toDirectory: URL.init(fileURLWithPath: payloadDirectory.path))
            print("Extracting ipa file: \(appBundleURL.path)")
            saveData(fileURL: appBundleURL)
        } catch {
            print("Error extracting ipa file")
            self.alertMessage = "Error extracting ipa file"
            self.showingAlert = true
        }
    }
    
    func saveData(fileURL: URL) {
        if let application = ALTApplication.init(fileURL: fileURL) {
            Client.shared.store?.createTable(withName: "AppsTable")
            Client.shared.store?.put(fileURL.path, withId: UUID().uuidString, intoTable: "AppsTable")
            let appBundle = AppBundle.init(application)
            self.appList.append(appBundle)
        }
    }
    
    func getDataSource() {
        var appBundles: [AppBundle] = []
        if let results: [YTKKeyValueItem] = Client.shared.store?.getAllItems(fromTable: "AppsTable") as? [YTKKeyValueItem] {
            for item in results {
                if let array: [String] = item.itemObject as? [String] {
                    if array.count > 0 {
                        if let filePath: String = array.first {
                            print(filePath)
                            if let application = ALTApplication.init(fileURL: URL.init(fileURLWithPath: filePath)) {
                                let appBundle = AppBundle.init(application)
                                appBundles.append(appBundle)
                            } else {
                                Client.shared.store?.deleteObject(byId: item.itemId, fromTable: "AppsTable")
                            }
                        }
                    }
                }
            }
        }
        self.appList = appBundles
    }
    
}

struct AppListView_Previews: PreviewProvider {
    static var previews: some View {
        AppListView()
    }
}


struct AppBundle: Identifiable {
    let id = UUID()
    var icon: NSImage
    var altApplication: ALTApplication
    init(_ application: ALTApplication) {
        altApplication = application
        self.icon = NSImage.init(named: "ipa")!
        if let iconName = altApplication.iconName {
            if let image = NSImage.init(contentsOfFile: altApplication.fileURL.appendingPathComponent("\(iconName)@2x.png").path) {
                self.icon = image
            }
        }
    }
}
