//
//  dcbattwebhook_swiftApp.swift
//  dcbattwebhook-swift
//
//  Created by Stella Luna on 11/10/22.
//

import SwiftUI
#if os(iOS) || os(watchOS)
import WatchConnectivity
#endif

/// Name of the app
public let prodName = "Battery Webhook"
/// Base version of the app, use `version` if you want the running OS as well
let versionNum = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
let versionBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"

#if DEBUG
public let versionBase = "\(versionNum)(\(versionBuild))"
#else
public let versionBase = "\(versionNum)"
#endif

#if os(macOS)
public var macAutomationsSavedPowerSource = GetMacPowerSource()
public var macAutomationsCurrentBattery = getBatteryLevel()
public let version = "\(versionBase) on macOS"
#elseif os(watchOS)
public let version = "\(versionBase) on watchOS"
#elseif os(visionOS)
public let version = "\(versionBase) on visionOS"
#elseif os(tvOS)
public let version = "\(versionBase) on tvOS"
#elseif os(iOS)
public let version = "\(versionBase)"
#endif

@main
struct dcbattwebhook_swiftApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("showMenuBarExtra") private var shouldDisableMenuItem = true
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @AppStorage("hideMainWindow") private var hideMainWindow = false
    #endif
    
    #if os(iOS) || os(watchOS)
    private lazy var sessionDelegator: SessionDelegator = {
        return SessionDelegator()
    }()

    init() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = sessionDelegator
            session.activate()
        }
    }
    #endif
    
    var body: some Scene {
        /* Currently unused singlewindow for macOS - makes app quit on window close
         #if os(macOS)
         Window("Battery Webhook", id: "mainwindow") {
            ContentView().frame(minWidth: 600, maxWidth: 1000, minHeight: 400, maxHeight: 600)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
                if (!hideMainWindow) {let _ = NSApplication.shared.setActivationPolicy(.regular)}
                else {let _ = NSApplication.shared.setActivationPolicy(.prohibited)}
            }
         }
         #endif
         */
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 600, maxWidth: 1000, minHeight: 400, maxHeight: 600)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                    if (!hideMainWindow) {let _ = NSApplication.shared.setActivationPolicy(.regular)}
                    else {let _ = NSApplication.shared.setActivationPolicy(.prohibited)}
                }
                #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
            CommandGroup(after: .newItem) {
                Button(action: {
                    let isSettingsValid = ValidateSettings()
                    if (isSettingsValid.err == true) {
                        // config error
                    }
                    else {
                        let ResultsVar = sendInfo(isCurrentlyCharging: false, didGetPluggedIn: false, didGetUnplugged: false, didHitFullCharge: false)
                        SaveCurrentDate()
                        if (ResultsVar.err) {
                            // network error
                        }
                        else {
                            // success
                        }

                    }
                }, label: {
                    Text("Send Battery Info Now")
                    Image(systemName: "paperplane")
                }).keyboardShortcut("s", modifiers: [.command, .shift])
                    .disabled(shouldDisableMenuItem)
            }
        }
        #endif
        
        #if os(macOS)
        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MenuBarExtraView()
        } label: {
            Image("MenuBarExtra").renderingMode(.template)
        }
        #endif
    }
}
