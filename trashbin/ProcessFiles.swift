//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation
import Darwin

enum FileCheckResult {
	case doesntExist, isFile, isDirectory
}

enum CheckPreTrashResult: Equatable {
	case noAttentionNeeded
	case ownedBySomeoneElse(by: String)
	case readOnly
}

func processInputFiles() -> [URL] {
	let currentPath = fileManager.currentDirectoryPath
	let currentPathURL = URL(fileURLWithPath: currentPath, isDirectory: true)

	let files = CommandLine.arguments.dropFirst().filter { (argument) -> Bool in
		return argument.first != "-"
	}

	let globs: [[String]] = files.map { (file) -> [String] in
		return glob(pattern: file)
	}

	let flatGlobs: [String] = globs.flatMap { $0 }

	let filesUrlsArray: [URL] = flatGlobs.map { (filePath) -> URL in
		return URL(fileURLWithPath: filePath, relativeTo: currentPathURL)
	}

	return filesUrlsArray
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

func checkPreTrash(_ url: URL) -> CheckPreTrashResult {
	let path = url.path
	let currentUser = NSUserName()

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
