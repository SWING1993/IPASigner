//
//  ContentView.swift
//  IPASigner
//
//  Created by SWING on 2522/5/18.
//

import SwiftUI
import Cocoa

struct ContentView: View {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var signingOptions: SigningOptions = SigningOptions()
    @State private var controlsDisable = false
    @State private var showingAlert = false
    @State private var alertTitle: String = "提示"
    @State private var alertMessage: String = ""
    @State private var stateString = ""
    
    let fileManager = FileManager.default
    let bundleID = Bundle.main.bundleIdentifier
    let mktempPath = "/usr/bin/mktemp"
    let tarPath = "/usr/bin/tar"
    let unzipPath = "/usr/bin/unzip"
    let zipPath = "/usr/bin/zip"
    let defaultsPath = "/usr/bin/defaults"
    let codesignPath = "/usr/bin/codesign"
    let securityPath = "/usr/bin/security"
    let chmodPath = "/bin/chmod"
    
    @State var lastMakedTempFolder: String?
    
    enum ImportResourceType {
        case Cert
        case Profile
        case IPA
        case Dylib
    }
    
    var body: some View {

        DispatchQueue.main.async {
            if let p12Data = AppDefaults.shared.signingCertificate {
                self.signingOptions.signingCert = ALTCertificate.init(p12Data: p12Data, password: AppDefaults.shared.signingCertificatePassword)
                self.signingOptions.cert = self.signingOptions.signingCert == nil ? "" : self.signingOptions.signingCert!.name
            }
            if let profileData = AppDefaults.shared.signingProvisioningProfile {
                self.signingOptions.signingProfile = ALTProvisioningProfile.init(data: profileData)
                self.signingOptions.profile = self.signingOptions.signingProfile == nil ? "" : self.signingOptions.signingProfile!.name
            }
        }
        
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("IPA File：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "Import IPA File",
                    text: $signingOptions.ipaPath
                )
                .frame(width: 500, height: 30, alignment: .center)
                .allowsHitTesting(false)
                        
                Button {
                    doBrowse(resourceType: .IPA)
                } label: {
                    Text("Browse")
                }
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
                
            }.padding(.top, 20)
            
            HStack {
                Text("Signing Certificate：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "Import Certificate File",
                    text: $signingOptions.cert
                )
                .allowsHitTesting(false)
                .frame(width: 500, height: 30, alignment: .center)
                
                Button {
                    doBrowse(resourceType: .Cert)
                } label: {
                    Text("Browse")
                }
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
            }
            
            HStack {
                Text("Provisioning Profile：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "Import ProvisioningProfile File",
                    text: $signingOptions.profile
                )
                .frame(width: 500, height: 30, alignment: .center)
                .allowsHitTesting(false)
                
                Button {
                    doBrowse(resourceType: .Profile)
                } label: {
                    Text("Browse")
                }
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
            }
            
            HStack {
                Text("Dylib Files：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "Import Dylib Files",
                    text: $signingOptions.dylibs
                )
                .frame(width: 500, height: 30, alignment: .center)
                .allowsHitTesting(false)
                
                Button {
                    doBrowse(resourceType: .Dylib)
                } label: {
                    Text("Browse")
                }
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
                
            }
            
            HStack {
                Text("App Display Name：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app title on the home screen",
                    text: $signingOptions.appDisplayName
                )
                .frame(width: 500, height: 30, alignment: .center)
                .disabled(controlsDisable)
                
            }
            
            HStack {
                Text("App Bundle ID：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app bundle identifier",
                    text: $signingOptions.appBundleId
                )
                .frame(width: 400, height: 30, alignment: .center)
                .disabled(controlsDisable)
                
                
                Toggle(isOn: $signingOptions.deleteWatch) {
                    Text("Delete Watch")
                }
                .disabled(controlsDisable)
                
                
            }
            
            HStack {
                Text("App Version：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app version number",
                    text: $signingOptions.appVersion
                )
                .frame(width: 400, height: 30, alignment: .center)
                .disabled(controlsDisable)

                Toggle(isOn: $signingOptions.deletePluglnsfolder) {
                    Text("Delete Pluglns Folder")
                }
                .disabled(controlsDisable)
            }
            
            HStack {
                Text("Minimum Version：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app minimum iOS version",
                    text: $signingOptions.appMinimumiOSVersion
                )
                .allowsHitTesting(false)
                .frame(width: 400, height: 30, alignment: .center)
                
                Toggle(isOn: $signingOptions.removeMinimumiOSVersion) {
                    Text("Remove Minimum Version")
                }
                .disabled(controlsDisable)
                
                
            }
            
            HStack {
                Text("Signing State：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextEditor(text: $stateString)
                    .frame(width: 500, height: 40)
                    .allowsHitTesting(false)
                
                Button {
                    startSigning()
                } label: {
                    Text("Start")
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
                
            }
        }
        .frame(width:750, height: 400, alignment: .top)
        .alert(isPresented: $showingAlert) {
            getAlert()
        }
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle),
                     message: Text(alertMessage),
                     dismissButton: .default(Text("OK")))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    
    func doBrowse(resourceType: ImportResourceType) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = panel.urls.first {
                    print("选择的File：\(url.absoluteString)")
                    switch resourceType {
                    case .Cert:
                        if url.pathExtension.lowercased() == "p12" {
                            if let data: Data = NSData.init(contentsOf: url) as Data? {
                                let alert = NSAlert()
                                alert.messageText = "请输入证书密码"
                                alert.addButton(withTitle: "确定")
                                alert.addButton(withTitle: "取消")
                                let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
                                inputTextField.placeholderString = "证书密码"
                                alert.accessoryView = inputTextField
                                if let firstWindow = NSApplication.shared.windows.first {
                                    alert.beginSheetModal(for: firstWindow) { returnCode in
                                        if returnCode == .init(rawValue: 1000) {
                                            if let inputCert = ALTCertificate.init(p12Data: data, password: inputTextField.stringValue) {
                                                AppDefaults.shared.reset()
                                                self.signingOptions.signingProfile = nil
                                                self.signingOptions.signingCert = inputCert
                                                self.signingOptions.cert = inputCert.name
                                                self.signingOptions.profile = ""
                                                AppDefaults.shared.signingCertificate = data
                                                AppDefaults.shared.signingCertificatePassword = inputTextField.stringValue
                                                AppDefaults.shared.signingCertificateName = inputCert.name
                                                AppDefaults.shared.signingCertificateSerialNumber = inputCert.serialNumber
                                            } else {
                                                self.alertMessage = "证书无效或密码错误"
                                                self.showingAlert = true
                                            }
                                        }
                                    }
                                }
                            } else {
                                self.alertMessage = "证书无效"
                                self.showingAlert = true
                            }
                        } else {
                            self.alertMessage = "请选择p12"
                            self.showingAlert = true
                        }
                        
                    case .Profile:
                        if url.pathExtension.lowercased() == "mobileprovision" {
                            if let cert = self.signingOptions.signingCert {
                                if let inputProfile = ALTProvisioningProfile.init(url: url) {
                                    var matched = false
                                    for profileCertificate in inputProfile.certificates {
                                        if cert.serialNumber == profileCertificate.serialNumber {
                                            matched = true
                                        }
                                    }
                                    if matched {
                                        self.signingOptions.signingProfile = inputProfile
                                        AppDefaults.shared.signingProvisioningProfile = inputProfile.data
                                        self.signingOptions.profile = inputProfile.name
                                    } else {
                                        self.alertMessage = "所导入的mobileprovision和p12证书不匹配"
                                        self.showingAlert = true
                                    }
                                } else {
                                    self.alertMessage = "所导入的mobileprovision无效"
                                    self.showingAlert = true
                                }
                            } else {
                                self.alertMessage = "请先导入p12证书再导入mobileprovision"
                                self.showingAlert = true
                            }
                            
                        } else {
                            self.alertMessage = "请选择mobileprovision"
                            self.showingAlert = true
                        }
                    case .IPA:
                        if url.pathExtension.lowercased() == "ipa" {
                            self.signingOptions.ipaPath = url.path
                            self.unzipIPA(url)
                        } else if url.pathExtension.lowercased() == "app" {
                            self.signingOptions.ipaPath = url.path
                            self.importAppBundle(url)
                        } else {
                            self.alertMessage = "请选择ipa或者app文件"
                            self.showingAlert = true
                        }
                       
                    case .Dylib:
                        if url.pathExtension.lowercased() == "dylib" {
                            self.signingOptions.dylibPaths.append(url.path)
                            self.signingOptions.dylibs = self.signingOptions.dylibs + url.lastPathComponent + "|"
                        } else if url.pathExtension.lowercased() == "deb" {
                            self.unzipDeb(url)
                        } else {
                            self.alertMessage = "请选择dylib文件"
                            self.showingAlert = true
                        }
                    }                
                }
            }
        }
    }
    
    func unzipIPA(_ fileURL: URL) {
        if lastMakedTempFolder == nil {
            //MARK: Create working temp folder
            var tempFolder: String! = nil
            if let tmpFolder = makeTempFolder() {
                tempFolder = tmpFolder
            } else {
                return
            }
            lastMakedTempFolder = tempFolder
        }
    
        let workingDirectory = lastMakedTempFolder!.stringByAppendingPathComponent("out")
        let payloadDirectory = workingDirectory.stringByAppendingPathComponent("Payload/")
        
        do {
            let appBundleURL = try fileManager.unzipAppBundle(at: URL.init(fileURLWithPath: fileURL.path), toDirectory: URL.init(fileURLWithPath: payloadDirectory))
            setStatus("Extracting ipa file: \(appBundleURL.path)")
            importAppBundle(appBundleURL)
        } catch {
            setStatus("Error extracting ipa file")
            cleanup(lastMakedTempFolder!); return
        }
    }
    
    func unzipDeb(_ fileURL: URL) {
        if lastMakedTempFolder == nil {
            //MARK: Create working temp folder
            var tempFolder: String! = nil
            if let tmpFolder = makeTempFolder() {
                tempFolder = tmpFolder
            } else {
                return
            }
            lastMakedTempFolder = tempFolder
        }
        
        let toURL = URL.init(fileURLWithPath: lastMakedTempFolder!).appendingPathComponent(fileURL.lastPathComponent)
        print("toURL:\(toURL.path)")
        do {
            if fileManager.fileExists(atPath: toURL.path) {
                try fileManager.removeItem(at: toURL)
            }
            try fileManager.copyItem(at: fileURL, to: toURL)
            if let result = deb_test(lastMakedTempFolder!, toURL.path) {
                if let dylibPathString = NSString.init(utf8String: result) {
                    self.signingOptions.dylibPaths = dylibPathString.components(separatedBy: ",")
                    var dylibNames = ""
                    for dylibPath in self.signingOptions.dylibPaths {
                        let dylibName = URL(fileURLWithPath: dylibPath).lastPathComponent
                        dylibNames = dylibNames + " " + dylibName
                    }
                    self.signingOptions.dylibs = dylibNames
                }
            }
        } catch let error {
            setStatus(error.localizedDescription)
        }
    }
    
    func importAppBundle(_ fileURL: URL) {
        if let application = ALTApplication.init(fileURL: fileURL) {
            if application.encrypted() {
                setStatus("IPA未脱壳！")
            } else {
                self.signingOptions.app = application
                self.signingOptions.appVersion = application.version
                self.signingOptions.appDisplayName = application.name
                self.signingOptions.appBundleId = application.bundleIdentifier
                self.signingOptions.appMinimumiOSVersion = application.minimumiOSVersion.stringValue
                fileManager.setFilePosixPermissions(application.fileURL)
            }
        } else {
            setStatus("Invalid File！")
        }
    }
    
    func startSigning() {
        if let app = self.signingOptions.app,
           let cert = self.signingOptions.signingCert,
           let profile = self.signingOptions.signingProfile {
            if app.encrypted() {
                self.alertMessage = "IPA未脱壳！"
                self.showingAlert = true
                if let tempFolder = self.lastMakedTempFolder {
                    cleanup(tempFolder)
                    self.lastMakedTempFolder = nil
                }
                return
            }
            let infoPlistURL = app.fileURL.appendingPathComponent("Info.plist")
            if let dictionary = NSMutableDictionary.init(contentsOf: infoPlistURL) {
                print("Info.plist: \(dictionary)")
                //MARK: Get output filename
                let saveDialog = NSSavePanel()
                saveDialog.allowedFileTypes = ["ipa"]
                saveDialog.nameFieldStringValue = "\(signingOptions.appDisplayName)_\(signingOptions.appVersion)_\(signingOptions.appBundleId).ipa"
                if saveDialog.runModal().rawValue == NSApplication.ModalResponse.OK.rawValue  {
                    if let outputFileURL = saveDialog.url {
                        
                        self.controlsDisable = true
                        
                        if self.signingOptions.appDisplayName != app.name {
                            setStatus("修改\(app.name)的名字：\(self.signingOptions.appDisplayName)")
                            let _ = setPlistKey(infoPlistURL.path, keyName: "CFBundleDisplayName", value: self.signingOptions.appDisplayName)
                            setAppName(self.signingOptions.appDisplayName, fileURL: app.fileURL)
                        }
                        
                        if self.signingOptions.appBundleId != app.bundleIdentifier {
                            setStatus("修改\(app.name)的AppID：\(self.signingOptions.appBundleId)")
                            let _ = setPlistKey(infoPlistURL.path, keyName: "CFBundleIdentifier", value: self.signingOptions.appBundleId)
                        }
                        
                        if self.signingOptions.appVersion != app.version {
                            setStatus("修改\(app.name)的版本：\(self.signingOptions.appVersion)")
                            let _ = setPlistKey(infoPlistURL.path, keyName: "CFBundleShortVersionString", value: self.signingOptions.appVersion)
                        }
                        
                        if self.signingOptions.removeMinimumiOSVersion {
                            setStatus("移除\(app.name)的最低系统版本限制")
                            let _ = setPlistKey(infoPlistURL.path, keyName: "MinimumOSVersion", value: "1.0")
                        }
                        
                        var removeFilesURLs: [URL] = []
                        
                        if self.signingOptions.deleteWatch {
                            let watchURL = app.fileURL.appendingPathComponent("Watch")
                            removeFilesURLs.append(watchURL)
                            
                            let watchPlaceholderURL = app.fileURL.appendingPathComponent("com.apple.WatchPlaceholder")
                            removeFilesURLs.append(watchPlaceholderURL)
                        }
                        
                        if self.signingOptions.deletePluglnsfolder {
                            let plugInsURL = app.fileURL.appendingPathComponent("PlugIns")
                            removeFilesURLs.append(plugInsURL)
                        }
                        
                        for removeURL in removeFilesURLs {
                            if fileManager.fileExists(atPath: removeURL.path) {
                                do {
                                    try fileManager.removeItem(at: removeURL)
                                    setStatus("删除：\(removeURL.path)")
                                } catch let error {
                                    setStatus("删除失败：\(removeURL.path)\(error.localizedDescription)")
                                }
                            }
                        }
                        
                        // 注入插件
                        if self.signingOptions.dylibPaths.count > 0 {
                            let dylibPaths = NSMutableArray.init(capacity: self.signingOptions.dylibPaths.count)
                            for dylibPath in self.signingOptions.dylibPaths {
                                fileManager.setFilePosixPermissions(URL.init(fileURLWithPath: dylibPath))
                                dylibPaths.add(dylibPath)
                            }
                            if patch_ipa(app.fileURL.path, dylibPaths) != 1 {
                                setStatus("插件注入失败")
                                return
                            }
                        }
                   
                        AppSigner().signApp(withAplication: app, certificate: cert, provisioningProfile: profile) { log in
                            self.setStatus(log)
                        } completionHandler: { success, error, ipaURL in
                            self.controlsDisable = false
                            if success {
                                if let ipaURL = ipaURL {
                                    
                                    if fileManager.fileExists(atPath: outputFileURL.path) {
                                        do {
                                            try fileManager.removeItem(at: outputFileURL)
                                            setStatus("删除：\(outputFileURL.path)")
                                        } catch let error {
                                            setStatus("删除失败：\(outputFileURL.path)\(error.localizedDescription)")
                                        }
                                    }
                                    
                                    do {
                                        try fileManager.moveItem(at: ipaURL, to: outputFileURL)
                                        self.setStatus("签名成功，保存在\(outputFileURL.path)")
                                    } catch let error {
                                        print(error.localizedDescription)
                                        self.setStatus("签名成功，保存失败，保存于\(ipaURL.path)")
                                    }
                                }
                            } else {
                                self.setStatus("签名失败：\(error.debugDescription)")
                            }
                            if let tempFolder = self.lastMakedTempFolder {
                                cleanup(tempFolder)
                                self.lastMakedTempFolder = nil
                            }
                        }
                    }
                }
            } else {
                self.alertMessage = "无法读取Info.plist"
                self.showingAlert = true
            }
        } else {
            if self.signingOptions.app == nil {
                self.alertMessage = "请导入IPA"
                self.showingAlert = true
            } else if self.signingOptions.signingCert == nil {
                self.alertMessage = "请导入签名证书"
                self.showingAlert = true
            } else if self.signingOptions.signingProfile == nil {
                self.alertMessage = "请导入描述文件"
                self.showingAlert = true
            }
            
        }
    }
    
    
    func makeTempFolder() -> String? {
        let tempTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d", "-t", bundleID!])
        if tempTask.status != 0 {
            return nil
        }
        return tempTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func unzip(_ inputFile: String, outputPath: String) -> AppSignerTaskOutput {
        return Process().execute(unzipPath, workingDirectory: nil, arguments: ["-q", inputFile, "-d", outputPath])
    }
    
    func zip(_ inputPath: String, outputFile: String) -> AppSignerTaskOutput {
        return Process().execute(zipPath, workingDirectory: inputPath, arguments: ["-qry", outputFile, "."])
    }
    
    
    func getPlistKey(_ plist: String, keyName: String)->String? {
        let currTask = Process().execute(defaultsPath, workingDirectory: nil, arguments: ["read", plist, keyName])
        if currTask.status == 0 {
            return String(currTask.output.dropLast())
        } else {
            return nil
        }
    }
    
    func setPlistKey(_ plist: String, keyName: String, value: String)->AppSignerTaskOutput {
        return Process().execute(defaultsPath, workingDirectory: nil, arguments: ["write", plist, keyName, value])
    }
    
    func setAppName(_ appName: String, fileURL: URL) {
        do {
            let dirArray = try fileManager.contentsOfDirectory(atPath: fileURL.path)
            for subFilePath in dirArray {
                if subFilePath.hasSuffix(".lproj") {
                    let subFileURL: URL = fileURL.appendingPathComponent(subFilePath)
                    let infoPlistStringsURL = subFileURL.appendingPathComponent("InfoPlist.strings")
                    if fileManager.fileExists(atPath: infoPlistStringsURL.path) {
                        if let dictionary = NSMutableDictionary.init(contentsOf: infoPlistStringsURL) {
                            dictionary.setObject(appName, forKey: "CFBundleDisplayName" as NSCopying)
                            dictionary.write(toFile: infoPlistStringsURL.path, atomically: true)
                            print("修改AppName:\(infoPlistStringsURL.path)")
                        }
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func cleanup(_ tempFolder: String){
        do {
            Log.write("Deleting: \(tempFolder)")
            try fileManager.removeItem(atPath: tempFolder)
        } catch let error as NSError {
            setStatus("Unable to delete temp folder")
            Log.write(error.localizedDescription)
        }
        
        self.signingOptions.ipaPath = ""
        self.signingOptions.dylibs = ""
        self.signingOptions.dylibPaths = []
        self.signingOptions.app = nil
        self.signingOptions.appDisplayName = ""
        self.signingOptions.appBundleId = ""
        self.signingOptions.appVersion = ""
        self.signingOptions.appMinimumiOSVersion = ""
    }
    
    func setStatus(_ status: String){
        stateString = status
        Log.write(status)
    }
    
}
