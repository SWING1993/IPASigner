//
//  IPASignerApp.swift
//  IPASigner
//
//  Created by SWING on 2022/5/18.
//

import SwiftUI

@main
struct IPASignerApp: App {
    
    let signingOptions = SigningOptions()
    
    var body: some Scene {
        
        WindowGroup("MainWindow") {
            AppNavigationView()
                .environmentObject(signingOptions)
                .frame(minWidth: 900, minHeight: 600)
                .onAppear {
                    FileManager.default.createDefaultDirectory()
                }
        }
        
        WindowGroup("SignWindow") {
            SignView().environmentObject(signingOptions)
        }.handlesExternalEvents(matching: Set(arrayLiteral: "SignWindow"))
    }
    
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

enum OpenWindows: String, CaseIterable {
    case MainWindow = "MainWindow"
    case SignWindow = "SignWindow"
    //As many views as you need.

    func open(){
        if let url = URL(string: "myapp://(self.SignWindow)") { //replace myapp with your app's name
            NSWorkspace.shared.open(url)
        }
    }
}
