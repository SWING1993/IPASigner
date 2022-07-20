//
//  CertListView.swift
//  IPASigner
//
//  Created by SWING on 2022/7/13.
//

import SwiftUI

struct CertListView: View {
    
    @State private var certList: [Cert] = []
    
    @State private var showingAlert = false
    @State private var alertTitle: String = "提示"
    @State private var alertMessage: String = ""
    
    var body: some View {
        
        if self.certList.count <= 0 {
            Text("点击右上角「导入」按钮导入p12证书或mobileprovision描述文件")
                .navigationTitle("证书")
                .toolbar{
                    ToolbarItem(placement:.automatic){
                        Button(action:{
                            print("导入p12或mobileprovision")
                            doBrowse()
                            
                        }) {
                            Text("导入")
                                .bold()
                            Image(systemName: "tray.and.arrow.down.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
                .onAppear {
                    getCertsList()
                }
        } else {
            List($certList) { $cert in
                CertRow(cert: cert)
            }
            .navigationTitle("证书")
            .toolbar{
                ToolbarItem(placement:.automatic){
                    Button(action:{
                        print("导入p12或mobileprovision")
                        doBrowse()
                        
                    }) {
                        Text("导入")
                            .bold()
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        
        
        
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
            certs.append(cert)
        }
        self.certList = certs
        print(certificates)
        print(profiles)
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
                                            let fileName = "\(inputCert.name).p12"
                                            let savePath = FileManager.default.certificatesDirectory.appendingPathComponent(fileName).path
                                            FileManager.default.createFile(atPath: savePath, contents: inputCert.p12Data())
                                            self.getCertsList()
                                        } else {
                                            self.alertMessage = "证书密码错误"
                                            self.showingAlert = true
                                        }
                                    }
                                }
                            }
                        } else {
                            self.alertMessage = "请选择p12或mobileprovision文件"
                            self.showingAlert = true
                        }
                    }  else if url.pathExtension.lowercased() == "mobileprovision" {
                        if let inputProfile = ALTProvisioningProfile.init(url: url) {
                            let fileName = "\(inputProfile.uuid).mobileprovision"
                            let savePath = FileManager.default.profilesDirectory.appendingPathComponent(fileName).path
                            FileManager.default.createFile(atPath: savePath, contents: inputProfile.data, attributes: nil)
                            self.getCertsList()
                        } else {
                            self.alertMessage = "所选择的mobileprovision无效"
                            self.showingAlert = true
                        }
                    } else {
                        self.alertMessage = "请选择p12或mobileprovision文件"
                        self.showingAlert = true
                    }
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


struct Cert: Identifiable {
    let id = UUID()
    var altCert: ALTCertificate
    var altCertInfo: P12CertificateInfo
    var altProfile: ALTProvisioningProfile?
    init(_ altCert: ALTCertificate, altCertInfo: P12CertificateInfo, altProfile: ALTProvisioningProfile?) {
        self.altCert = altCert
        self.altCertInfo = altCertInfo
        self.altProfile = altProfile
    }
}
