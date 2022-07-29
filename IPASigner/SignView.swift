//
//  SignView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/22.
//

import SwiftUI
import Cocoa

struct SignView: View {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State var signingOptions: SigningOptions
    @State private var controlsDisable = false
    @State private var showingAlert = false
    @State private var alertTitle: String = "提示"
    @State private var alertMessage: String = ""
    @State private var stateString = ""
    @State private var certList: [Cert] = []
    @State private var selectedCertSerialNumber = ""
    
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
    
    enum ImportResourceType {
        case Cert
        case Profile
        case IPA
        case Dylib
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 5) {
            
            HStack {
                Text("App：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)

                TextField(
                    "应用",
                    text: $signingOptions.appName
                )
                .allowsHitTesting(false)
                .disabled(true)
                .background(Color.white)
                .foregroundColor(.black)
                Spacer()
            }
            .padding(.top, 20)
            
            HStack {
                Text("选择证书：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                Picker.init(selection: $selectedCertSerialNumber) {
                    ForEach(certList) { cert in
                        Text(cert.altCert.name).tag(cert.altCert.serialNumber)
                    }
                } label: {
                    
                }.onChange(of: selectedCertSerialNumber) { certSerialNumber in
                        print(certSerialNumber)
                        self.certList.forEach { cert in
                            if cert.altCert.serialNumber == certSerialNumber {
                                signingOptions.signingCert = cert.altCert
                                if let altProfile = cert.altProfile {
                                    signingOptions.profile = altProfile.name
                                    signingOptions.signingProfile = altProfile
                                } else {
                                    signingOptions.profile = ""
                                    signingOptions.signingProfile = nil
                                }
                            }
                        }
                    }
                
                Spacer()
            }
            
            HStack {
                Text("描述文件：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "Import ProvisioningProfile File",
                    text: $signingOptions.profile
                )
                .allowsHitTesting(false)
                .disabled(true)
                .background(Color.white)
                .foregroundColor(.black)
                
                Spacer()
            }
            
            HStack {
                Text("注入插件：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "导入dylib动态库文件",
                    text: $signingOptions.dylibs
                )
                .allowsHitTesting(false)
                .disabled(true)
                .background(Color.white)
                .foregroundColor(.black)
                
                Button {
                    doBrowse(resourceType: .Dylib)
                } label: {
                    Text("选择")
                }
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
                Spacer()
            }
            
            HStack {
                Text("应用名字：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app title on the home screen",
                    text: $signingOptions.appDisplayName
                )
                .disabled(controlsDisable)
                
                Spacer()
            }
            
            HStack {
                Text("应用标识符：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app bundle identifier",
                    text: $signingOptions.appBundleId
                )
                .disabled(controlsDisable)
                
                
                Toggle(isOn: $signingOptions.deleteWatch) {
                    Text("删除手表应用")
                }
                .disabled(controlsDisable)
                
                Spacer()
            }
            
            HStack {
                Text("应用版本号：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app version number",
                    text: $signingOptions.appVersion
                )
                .disabled(controlsDisable)
                
                Toggle(isOn: $signingOptions.deletePluglnsfolder) {
                    Text("删除插件应用")
                }
                .disabled(controlsDisable)

                Spacer()
//                Toggle(isOn: $signingOptions.removeMinimumiOSVersion) {
//                    Text("删除系统版本限制")
//                }
//                .disabled(controlsDisable)
            }
            
            HStack {
                Text("最低iOS版本：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 110, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                    "This changes the app minimum iOS version",
                    text: $signingOptions.appMinimumiOSVersion
                )
                
                Button {
                    startSigning()
                } label: {
                    Text("开始签名")
                }
                .frame(width: 80, height: 30, alignment: .center)
                .disabled(controlsDisable)
                Spacer()
            }
            
//            HStack {
//                Text("签名：")
//                    .font(.body)
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//                    .frame(width: 110, height: 25, alignment: .topTrailing)
//                    .offset(x: 0, y: 5)
//
//                TextEditor(text: $stateString)
//                    .frame(width: 500, height: 40)
//                    .allowsHitTesting(false)
//
//
//
//            }
        }
        .frame(width:650, height: 290, alignment: .topLeading)
        .alert(isPresented: $showingAlert) {
            getAlert()
        }.onAppear {
            self.getCertsList()
        }
        
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle),
                     message: Text(alertMessage),
                     dismissButton: .default(Text("OK")))
    }
    
    func getCertsList() {
        var certificates: [ALTCertificate] = []
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.certificatesDirectory.path)
            for name in array {
                let fileURL: URL = FileManager.default.certificatesDirectory.appendingPathComponent(name)
                if fileURL.isCertificate {
                    if let data: Data = NSData.init(contentsOf: fileURL) as Data? {
                        if let certificate = ALTCertificate.init(p12Data: data, password: "") {
                            certificates.append(certificate)
                        }
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        var profiles: [ALTProvisioningProfile] = []
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.profilesDirectory.path)
            for name in array {
                let fileURL: URL = FileManager.default.profilesDirectory.appendingPathComponent(name)
                if fileURL.isMobileProvision {
                    if let profile = ALTProvisioningProfile.init(url: fileURL) {
                        profiles.append(profile)
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        var certs: [Cert] = []
        for certificate in certificates {
            var item: (certificate: ALTCertificate, certInfo: P12CertificateInfo, profile: ALTProvisioningProfile?)
            item.certificate = certificate
            item.certInfo = ReadP12Subject().readCertInfoWhitAltCert(certificate)
            item.profile = nil
            for profile in profiles {
                for profileCertificate in profile.certificates {
                    if certificate.serialNumber == profileCertificate.serialNumber {
                        if let p = item.profile {
                            if p.expirationDate < profile.expirationDate {
                                item.profile = profile
                            }
                        } else {
                            item.profile = profile
                        }
                    }
                }
            }
            let cert = Cert(item.certificate, altCertInfo: item.certInfo, altProfile: item.profile)
            if item.profile != nil {
                certs.append(cert)
            }
        }
        if self.selectedCertSerialNumber.count <= 0 {
            if let cert = certs.first {
                self.selectedCertSerialNumber = cert.altCert.serialNumber
            }
        }
        self.certList = certs
        
        print(certificates)
        print(profiles)
    }
}

extension SignView {
    
    func doBrowse(resourceType: ImportResourceType) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = panel.urls.first {
                    print("选择的File：\(url.absoluteString)")
                    if url.pathExtension.lowercased() == "dylib" {
                        self.signingOptions.dylibPaths.append(url.path)
                        self.signingOptions.dylibs = self.signingOptions.dylibs + url.lastPathComponent + "|"
                    } else {
                        self.alertMessage = "请选择dylib文件"
                        self.showingAlert = true
                    }
                }
            }
        }
    }

    func startSigning() {
        if let cert = self.signingOptions.signingCert,
           let profile = self.signingOptions.signingProfile {
            if self.signingOptions.app.encrypted() {
                self.alertMessage = "IPA未脱壳！"
                self.showingAlert = true
                return
            }
            let infoPlistURL = self.signingOptions.app.fileURL.appendingPathComponent("Info.plist")
            if let dictionary = NSMutableDictionary.init(contentsOf: infoPlistURL) {
                print(dictionary)
                self.controlsDisable = true
                let outputFileURL = fileManager.signedIPAsDirectory.appendingPathComponent("\(signingOptions.appDisplayName)_\(signingOptions.appVersion)_\(signingOptions.appBundleId)_\(UInt.random(in: 1...100000)))).ipa")
                
                
                if self.signingOptions.appDisplayName != self.signingOptions.app.name {
                    setStatus("修改\(self.signingOptions.app.name)的名字：\(self.signingOptions.appDisplayName)")
                    let _ = setPlistKey(infoPlistURL.path, keyName: "CFBundleDisplayName", value: self.signingOptions.appDisplayName)
                    setAppName(self.signingOptions.appDisplayName, fileURL: self.signingOptions.app.fileURL)
                }
                
                if self.signingOptions.appBundleId != self.signingOptions.app.bundleIdentifier {
                    setStatus("修改\(self.signingOptions.app.name)的AppID：\(self.signingOptions.appBundleId)")
                    let _ = setPlistKey(infoPlistURL.path, keyName: "CFBundleIdentifier", value: self.signingOptions.appBundleId)
                }
                
                if self.signingOptions.appVersion != self.signingOptions.app.version {
                    setStatus("修改\(self.signingOptions.app.name)的版本：\(self.signingOptions.appVersion)")
                    let _ = setPlistKey(infoPlistURL.path, keyName: "CFBundleShortVersionString", value: self.signingOptions.appVersion)
                }
                
                if self.signingOptions.removeMinimumiOSVersion {
                    setStatus("移除\(self.signingOptions.app.name)的最低系统版本限制")
                    let _ = setPlistKey(infoPlistURL.path, keyName: "MinimumOSVersion", value: "1.0")
                }
                
                var removeFilesURLs: [URL] = []
                
                if self.signingOptions.deleteWatch {
                    let watchURL = self.signingOptions.app.fileURL.appendingPathComponent("Watch")
                    removeFilesURLs.append(watchURL)
                    
                    let watchPlaceholderURL = self.signingOptions.app.fileURL.appendingPathComponent("com.apple.WatchPlaceholder")
                    removeFilesURLs.append(watchPlaceholderURL)
                }
                
                if self.signingOptions.deletePluglnsfolder {
                    let plugInsURL = self.signingOptions.app.fileURL.appendingPathComponent("PlugIns")
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
                    if patch_ipa(self.signingOptions.app.fileURL.path, dylibPaths) != 1 {
                        setStatus("插件注入失败")
                        return
                    }
                }
           
                AppSigner().signApp(withAplication: self.signingOptions.app, certificate: cert, provisioningProfile: profile) { log in
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
                                self.saveSignData(savedIPAURL: outputFileURL)
                            } catch let error {
                                print(error.localizedDescription)
                                self.setStatus("签名成功，保存失败，保存于\(ipaURL.path)")
                            }
                        }
                    } else {
                        self.setStatus("签名失败：\(error.debugDescription)")
                    }
                }
            
//                print("Info.plist: \(dictionary)")
//                //MARK: Get output filename
//                let saveDialog = NSSavePanel()
//                saveDialog.allowedFileTypes = ["ipa"]
//                saveDialog.nameFieldStringValue = "\(signingOptions.appDisplayName)_\(signingOptions.appVersion)_\(signingOptions.appBundleId).ipa"
//                if saveDialog.runModal().rawValue == NSApplication.ModalResponse.OK.rawValue  {
//                    if let outputFileURL = saveDialog.url
//                }
            } else {
                self.alertMessage = "无法读取Info.plist"
                self.showingAlert = true
            }
        } else {
            if self.signingOptions.signingCert == nil {
                self.alertMessage = "请导入签名证书"
                self.showingAlert = true
            } else if self.signingOptions.signingProfile == nil {
                self.alertMessage = "请导入描述文件"
                self.showingAlert = true
            }
        }
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
    
    func cleanup(_ tempFolder: String) {
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
        self.signingOptions.appDisplayName = ""
        self.signingOptions.appBundleId = ""
        self.signingOptions.appVersion = ""
        self.signingOptions.appMinimumiOSVersion = ""
    }
    
    func setStatus(_ status: String) {
        stateString = status
        Log.write(status)
    }
    
    func saveSignData(savedIPAURL: URL) {
        let signedIPA = SignedIPAModel()
        signedIPA.id = signedIPA.uuid.uuidString
        signedIPA.name = self.signingOptions.appDisplayName
        signedIPA.bundleIdentifier = self.signingOptions.appBundleId
        signedIPA.version = self.signingOptions.appVersion
        signedIPA.minimumiOSVersion = self.signingOptions.appMinimumiOSVersion
        signedIPA.filePath = savedIPAURL.path
        if let signedCertificateName = self.signingOptions.signingCert?.name {
            signedIPA.signedCertificateName = signedCertificateName
        }
        //signedIPA.log = log
        if let iconName = self.signingOptions.app.iconName {
            if let image = NSImage.init(contentsOfFile: self.signingOptions.app.fileURL.appendingPathComponent("\(iconName)@2x.png").path) {
                let newIconName = signedIPA.name + "_v" + signedIPA.version + "_\(UInt.random(in: 1...100000))" + ".png"
                let newIconURL = fileManager.iconDirectory.appendingPathComponent(newIconName)
                do {
                   try fileManager.copyItem(at: self.signingOptions.app.fileURL.appendingPathComponent("\(iconName)@2x.png"), to: newIconURL)
                    signedIPA.iconName = newIconName
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
       
        if let jsonString = signedIPA.toJSONString() {
            print("保存已签名应用的数据: \(jsonString)")
            Client.shared.store?.createTable(withName: "signedIPAsTable")
            Client.shared.store?.put(jsonString, withId: signedIPA.id, intoTable: "signedIPAsTable")
        } else {
            print("保存已签名应用的数据失败")
        }
    }
    
}

