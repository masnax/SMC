//
//  Helper.swift
//  SwiftPrivilegedHelper
//
//  Created by Erik Berglund on 2018-10-01.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {

    // MARK: -
    // MARK: Private Constant Variables

    private let listener: NSXPCListener

    // MARK: -
    // MARK: Private Variables

    private var connections = [NSXPCConnection]()
    private var shouldQuitCheckInterval = 1.0

    // MARK: -
    // MARK: Initialization

    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.machServiceName)
        super.init()
        self.listener.delegate = self
    }

    public func run() {
        self.listener.resume()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: self.shouldQuitCheckInterval))
    }

    // MARK: -
    // MARK: NSXPCListenerDelegate Methods

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        // Verify that the calling application is signed using the same code signing certificate as the helper
        guard self.isValid(connection: connection) else {
            return false
        }
        // Set the protocol that the helper conforms to.
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = self

        self.connections.append(connection)
        connection.resume()

        return true
    }

    func runCommandLs(withPath path: String, withVal val: String, completion: @escaping (NSNumber) -> Void) {
        // For security reasons, all commands should be hardcoded in the helper
        let command:String = "/usr/bin/sudo" // !!!!
        var arguments:[String]
        if val != "R" {
            var flt:Float = Float(val)!
            let data = Data(buffer: UnsafeBufferPointer(start: &flt, count: 1))
            let fanSpeed = data.map { String(format: "%02x", $0) }.joined()
            arguments = [path, "-k", "F0Md", "-w", "01"]
            self.runTask(command: command, arguments: arguments, completion: completion)
            usleep(100000) // 100ms sleep to let the C program complete
            arguments = [path, "-k", "F0Tg", "-w", fanSpeed]
            self.runTask(command: command, arguments: arguments, completion: completion)
        } else {
            arguments = [path, "-k", "F0Md", "-w", "00"]
        }
        self.runTask(command: command, arguments: arguments, completion: completion)
    }

    func runCommandLs(withPath path: String, authData: NSData?, completion: @escaping (NSNumber) -> Void) {

        // Check the passed authorization, if the user need to authenticate to use this command the user might be prompted depending on the settings and/or cached authentication.

        guard self.verifyAuthorization(authData, forCommand: #selector(HelperProtocol.runCommandLs(withPath:authData:completion:))) else {
            completion(kAuthorizationFailedExitCode)
            return
        }

        self.runCommandLs(withPath: "", withVal: path, completion: completion)
    }

    // MARK: -
    // MARK: Private Helper Methods

    private func isValid(connection: NSXPCConnection) -> Bool {
        do {
            return try CodesignCheck.codeSigningMatches(pid: connection.processIdentifier)
        } catch {
            NSLog("Code signing check failed with error: \(error)")
            return false
        }
    }

    private func verifyAuthorization(_ authData: NSData?, forCommand command: Selector) -> Bool {
        do {
            try HelperAuthorization.verifyAuthorization(authData, forCommand: command)
        } catch {
            return false
        }
        return true
    }

    private func connection() -> NSXPCConnection? {
        return self.connections.last
    }

    private func runTask(command: String, arguments: Array<String>, completion:@escaping ((NSNumber) -> Void)) -> Void {
        let task = Process()
        let stdOut = Pipe()

        let stdOutHandler =  { (file: FileHandle!) -> Void in
            let data = file.availableData
        }
        stdOut.fileHandleForReading.readabilityHandler = stdOutHandler

        let stdErr:Pipe = Pipe()
        let stdErrHandler =  { (file: FileHandle!) -> Void in
            let data = file.availableData
        }
        stdErr.fileHandleForReading.readabilityHandler = stdErrHandler

        task.launchPath = command
        task.arguments = arguments
        task.standardOutput = stdOut
        task.standardError = stdErr

        task.terminationHandler = { task in
            completion(NSNumber(value: task.terminationStatus))
        }
        task.launch()
    }
}
