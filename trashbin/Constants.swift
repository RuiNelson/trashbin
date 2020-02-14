//
//  Constants.swift
//  trashbin
//
//  Created by Rui Nelson Carneiro on 06/02/2020.
//  Copyright © 2020 Rui Nelson Magalhães Carneiro. All rights reserved.
//

import Foundation

struct Constants {
    enum ExitCodes: Int32 {
        case normal = 0
        case badSyntax = 64
        case mutualExclusiveOptions = 30
        case overwriteWithoutUnlink = 31
        case noSuchFileOrDirectory = 1

        func exit() {
            if self == .badSyntax {
                print("Usage: \(Constants.programName) [-f | -i] [-dPRrsuv] [-el] file ...")
                print("       send files to macOS trash (or unlink)")
            }

            Darwin.exit(rawValue)
        }
    }

    static var programName: String {
        let programPath = CommandLine.arguments.first!
        let pathUrl = URL(fileURLWithPath: programPath)
        return pathUrl.lastPathComponent
    }

    static let fileManager = FileManager.default

    static var byteCountFormatter: ByteCountFormatter {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [ByteCountFormatter.Units.useAll]
        bcf.countStyle = ByteCountFormatter.CountStyle.file
        return bcf
    }

    static var userName = NSUserName()
    static var userIsRoot = NSUserName() == "root"
}
