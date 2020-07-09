//
//  AppDelegate.swift
//  SMC
//
//  Created by Erik Berglund on 2018-10-01.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AppProtocol {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    // MARK: -
    // MARK: IBOutlets

    @IBOutlet weak var statusMenu: NSMenu!
    //    @IBOutlet weak var window: NSWindow!
    
    weak var buttonRunCommand: NSButton!

    // MARK: -
    // MARK: Variables

    private var currentHelperConnection: NSXPCConnection?

    @objc dynamic private var currentHelperAuthData: NSData?
    private let currentHelperAuthDataKeyPath: String

    @objc dynamic private var helperIsInstalled = false
    private let helperIsInstalledKeyPath: String

    // MARK: -
    // MARK: Computed Variables

    var inputPath: String?
    
    var numStats: String = "5"
    var updateStat: Bool = false
    var newStat: String = "5"
    
    let fanOffset=1
    let tempOffset=3

    // MARK: -
    // MARK: NSApplicationDelegate Methods

    override init() {
        self.currentHelperAuthDataKeyPath = NSStringFromSelector(#selector(getter: self.currentHelperAuthData))
        self.helperIsInstalledKeyPath = NSStringFromSelector(#selector(getter: self.helperIsInstalled))
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // Update the current authorization database right
        // This will prmpt the user for authentication if something needs updating.
        installHelper()
        statusItem.button!.image = NSImage(named: "default")
        statusItem.button?.target = self
//        statusItem.menu = self.statusMenu
        statusItem.button?.action = #selector(smcMenu)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        do {
            try HelperAuthorization.authorizationRightsUpdateDatabase()
        } catch {
//            self.textViewOutput.appendText("Failed to update the authorization database rights with error: \(error)")
        }

        // Check if the current embedded helper tool is installed on the machine.
        
    }
    
    func updateStats() -> NSMenu {
        var menu = statusMenu!
        
        menu = updateTemps(menu: menu)
        menu = updateFans(menu: menu)
        return menu
    }
    
    func resetMenu() {
        // temp
        for _ in 1...3 {
            statusMenu.removeItem(at: fanOffset)
        }
    
        let num = Int(numStats)
        for _ in 1...num! {
            statusMenu.removeItem(at: tempOffset)
        }
        if updateStat {
            numStats = newStat
        }
        updateStat = false
        
    }
    
    func updateTemps(menu: NSMenu) -> NSMenu {
        if let command = Bundle.main.path(forResource: "list-temps", ofType: nil, inDirectory: "Scripts") {
            let (stdout, _, _) = shell(cmd: command, args: numStats, command)
            for row in stdout {
                let menuRow = NSMenuItem(title: "   " + row, action: nil, keyEquivalent: "")
                menu.insertItem(menuRow, at: tempOffset)
            }
        }
        return menu
    }
    
    func updateFans(menu: NSMenu) -> NSMenu {
        if let command = Bundle.main.path(forResource: "list-fans", ofType: nil, inDirectory: "Scripts") {
            let (stdout, _, _) = shell(cmd: command, args: command)
            for row in stdout {
                let menuRow = NSMenuItem(title: "   " + row, action: nil, keyEquivalent: "")
                menu.insertItem(menuRow, at: fanOffset)
            }
        }
        return menu
    }
    
    func shell(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }

    
    @objc func smcMenu() {
        let event = NSApp.currentEvent!
        
        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem.menu = updateStats()
            statusItem.popUpMenu(self.statusMenu)
            statusItem.menu = nil
            resetMenu()
        } else {
            setSMCAndIcon()
        }
    }
    
    func setSMCAndIcon() {
        if isActive() { //Active Custom
            self.inputPath = "0"
            buttonRunCommand(self)
            setDisabledIcon()
            return
        }
            
        if isDisabled() {
            self.inputPath = "R"
            buttonRunCommand(self)
            setDefaultIcon()
            return
        }
        if isDefault() {
            self.inputPath = "8000"
            buttonRunCommand(self)
            setActiveIcon()
        }
    }

    @IBAction func directOff(_ sender: Any) {
        self.inputPath = "0"
        buttonRunCommand(self)
        setDisabledIcon()
    }
    
    @IBAction func directAuto(_ sender: Any) {
        self.inputPath = "R"
        buttonRunCommand(self)
        setDefaultIcon()
    }
    
    @IBAction func direct1000(_ sender: Any) {
        self.inputPath = "1000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct2000(_ sender: Any) {
        self.inputPath = "2000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct3000(_ sender: Any) {
        self.inputPath = "3000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct4000(_ sender: Any) {
        self.inputPath = "4000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct5000(_ sender: Any) {
        self.inputPath = "5000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct6000(_ sender: Any) {
        self.inputPath = "6000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct7000(_ sender: Any) {
        self.inputPath = "7000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func direct8000(_ sender: Any) {
        self.inputPath = "8000"
        buttonRunCommand(self)
        setActiveIcon()
    }
    
    @IBAction func statsLimit1(_ sender: Any) {
        self.updateStat = true
        newStat = "1"
    }
    
    @IBAction func statsLimit2(_ sender: Any) {
        self.updateStat = true
        newStat = "2"
    }
    
    @IBAction func statsLimit3(_ sender: Any) {
        self.updateStat = true
        newStat = "3"
    }
    
    @IBAction func statsLimit4(_ sender: Any) {
        self.updateStat = true
        newStat = "4"
    }
    
    @IBAction func statsLimit5(_ sender: Any) {
        self.updateStat = true
        newStat = "5"
    }
    
    @IBAction func statsLimit6(_ sender: Any) {
        self.updateStat = true
        newStat = "6"
    }
    
    @IBAction func statsLimit7(_ sender: Any) {
        self.updateStat = true
        newStat = "7"
    }
    
    @IBAction func statsLimit8(_ sender: Any) {
        self.updateStat = true
        newStat = "8"
    }
    
    @IBAction func statsLimit9(_ sender: Any) {
        self.updateStat = true
        newStat = "9"
    }
    
    @IBAction func statsLimit10(_ sender: Any) {
        self.updateStat = true
        newStat="10"
    }
    
    func isActive() -> Bool {
        return statusItem.button?.image == NSImage(named: "active")
//        return statusItem.button?.title == "🤬"
    }
    
    func isDefault() -> Bool {
        return statusItem.button?.image == NSImage(named: "default")
//        return statusItem.button?.title == "💀"
    }
    
    func isDisabled() -> Bool {
        return statusItem.button?.image == NSImage(named: "disabled")
//        return statusItem.button?.title == "🥶"
    }
    
    func setDefaultIcon() {
        return statusItem.button!.image = NSImage(named: "default")
//        statusItem.button?.title = "💀"
    }
    
    func setActiveIcon() {
        return statusItem.button!.image = NSImage(named: "active")
//        statusItem.button?.title = "🤬"
    }
    
    func setDisabledIcon() {
        return statusItem.button!.image = NSImage(named: "disabled")
//        statusItem.button?.title = "🥶"
    }
    
   
    @IBAction func directQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    

    
    func installHelper() {
        if let cmd1 = Bundle.main.path(forResource: "list-temps", ofType: nil, inDirectory: "Scripts"),
        let cmd2 = Bundle.main.path(forResource: "list-fans", ofType: nil, inDirectory: "Scripts"),
        let cmd3 = Bundle.main.path(forResource: "smc", ofType: nil, inDirectory: "Scripts"),
        let cmd4 = Bundle.main.path(forResource: "smc-set", ofType: nil, inDirectory: "Scripts"),
        let cmd5 = Bundle.main.path(forResource: "byte-array", ofType: nil, inDirectory: "Scripts") {
            let (_, _, _) = shell(cmd: "/bin/chmod", args: "+x", cmd1, cmd2, cmd3, cmd4, cmd5)
        }
        
        
        let (stdout, _, _) = shell(cmd: "/bin/ls", args: "/Library/PrivilegedHelperTools")
        if !stdout.contains("com.masnax.SwiftPrivilegedHelper") {
            do {
                try self.helperInstall()
            } catch {
    
            }
        }
    }


    func buttonRunCommand(_ sender: Any) {
        guard
            let inputValue = self.inputPath,
            let helper = self.helper(nil),
            let smc_set = Bundle.main.path(forResource: "smc-set", ofType: nil, inDirectory: "Scripts"),
            let smc = Bundle.main.path(forResource: "smc", ofType: nil, inDirectory: "Scripts") else {return}
        helper.runCommandLs(withPath: [smc_set, smc], withVal: inputValue) { (exitCode) in}
    }

    // MARK: -
    // MARK: AppProtocol Methods

    func log(stdOut: String) {
        guard !stdOut.isEmpty else { return }
        OperationQueue.main.addOperation {
//            self.textViewOutput.appendText(stdOut)
        }
    }

    func log(stdErr: String) {
        guard !stdErr.isEmpty else { return }
        OperationQueue.main.addOperation {
//            self.textViewOutput.appendText(stdErr)
        }
    }

    // MARK: -
    // MARK: Helper Connection Methods

    func helperConnection() -> NSXPCConnection? {
        guard self.currentHelperConnection == nil else {
            return self.currentHelperConnection
        }

        let connection = NSXPCConnection(machServiceName: HelperConstants.machServiceName, options: .privileged)
        connection.exportedInterface = NSXPCInterface(with: AppProtocol.self)
        connection.exportedObject = self
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.invalidationHandler = {
            self.currentHelperConnection?.invalidationHandler = nil
            OperationQueue.main.addOperation {
                self.currentHelperConnection = nil
            }
        }

        self.currentHelperConnection = connection
        self.currentHelperConnection?.resume()

        return self.currentHelperConnection
    }

    func helper(_ completion: ((Bool) -> Void)?) -> HelperProtocol? {

        // Get the current helper connection and return the remote object (Helper.swift) as a proxy object to call functions on.

        guard let helper = self.helperConnection()?.remoteObjectProxyWithErrorHandler({ error in
//            self.textViewOutput.appendText("Helper connection was closed with error: \(error)")
            if let onCompletion = completion { onCompletion(false) }
        }) as? HelperProtocol else { return nil }
        return helper
    }

    func helperStatus(completion: @escaping (_ installed: Bool) -> Void) {

        // Comppare the CFBundleShortVersionString from the Info.plist in the helper inside our application bundle with the one on disk.

        
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/" + HelperConstants.machServiceName)
        guard
            let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL) as? [String: Any],
            let helperVersion = helperBundleInfo["CFBundleShortVersionString"] as? String,
            let helper = self.helper(completion) else {
                completion(false)
                return
        }
//        print(helperBundleInfo, helperVersion)

        
        let compute = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        print(helperVersion == compute)
        
        helper.getVersion { installedHelperVersion in
            completion(installedHelperVersion == helperVersion)
        }
    }

    func helperInstall() throws -> Bool {

        // Install and activate the helper inside our application bundle to disk.

        var cfError: Unmanaged<CFError>?
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value:UnsafeMutableRawPointer(bitPattern: 0), flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)

        guard
            let authRef = try HelperAuthorization.authorizationRef(&authRights, nil, [.interactionAllowed, .extendRights, .preAuthorize]),
            SMJobBless(kSMDomainSystemLaunchd, HelperConstants.machServiceName as CFString, authRef, &cfError) else {
                if let error = cfError?.takeRetainedValue() { throw error }
                return false
        }

        self.currentHelperConnection?.invalidate()
        self.currentHelperConnection = nil
        return true
    }
}

