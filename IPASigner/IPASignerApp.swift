//
//  IPASignerApp.swift
//  IPASigner
//
//  Created by SWING on 2022/5/18.
//

import SwiftUI

@main
struct IPASignerApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            AppNavigationView()
                .frame(minWidth: 900, minHeight: 600)
//            ContentView()
        }
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
