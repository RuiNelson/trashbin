//
//  getFiles.swift
//  trashbin
//
//  Created by Rui Nelson Carneiro on 21/05/18.
//  Copyright © 2018 Rui Nelson Carneiro. All rights reserved.
//

import Foundation
import Darwin

func processInputFiles() -> [URL] {
    let currentPath = fileManager.currentDirectoryPath
    let currentPathURL = URL(fileURLWithPath: currentPath, isDirectory: true)

    let files = CommandLine.arguments.dropFirst().filter { (argument) -> Bool in
        return argument.first != "-"
    }

    let globs: [[String]] = files.map { (unglobbed) -> [String] in
        return glob(pattern: unglobbed)
    }

    let flatGlobs: [String] = globs.flatMap { $0 }

    let filesUrlsArray: [URL] = flatGlobs.map { (file) -> URL in
        return URL(fileURLWithPath: file, relativeTo: currentPathURL)
    }

    return filesUrlsArray
}

enum FileCheckResult {
    case doesntExist, isFile, isDirectory
}

func checkFile(_ url: URL) -> FileCheckResult {
    if fileManager.fileExists(atPath: url.path) {
        if fileManager.isDirectory(atPath: url.path) {
            return .isDirectory
        } else {
            return .isFile
        }
    } else {
        return .doesntExist
    }
}

enum CheckTrashResult: Equatable {

    case noAttentionNeeded
    case ownedBySomeoneElse(by: String)
    case readOnly

}

func checkTrash(_ url: URL) -> CheckTrashResult {
    let path = url.path

    // check ownership
    if let owner = fileManager.ownerOfItem(atPath: path) {
        if owner != currentUser {
            return .ownedBySomeoneElse(by: owner)
        }
    }

    // check write permission
    if fileManager.permissionOfItem(atPath: path, permission: .ownerWritable) == false {
        return .readOnly
    }

    // no problems found
    return .noAttentionNeeded
}
