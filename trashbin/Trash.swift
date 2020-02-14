//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

private enum CheckPreExecuteResult: Equatable {
	case noAttentionNeeded
	case ownedBySomeoneElse(by: String)
	case readOnly
}

private enum FileCheckResult {
	case doesntExist, isFile, isDirectory
}

private func checkPreExecution(_ url: URL) -> CheckPreExecuteResult {
	let path = url.path

	// check ownership
	if let owner = Constants.fileManager.ownerOfItem(atPath: path) {
		if owner != Constants.userName {
			return .ownedBySomeoneElse(by: owner)
		}
	}

	// check write permission
	if let ownerWritable = try? Constants.fileManager
		.itemPermissions(atPath: path)
		.contains(FileManager.PosixPermission.ownerWritable) {
		if !ownerWritable {
			return .readOnly
		}
	}

	// no problems found
	return .noAttentionNeeded
}

func execute(_ urls: [URL]) -> Int64? {
	func checkItem(_ url: URL) -> FileCheckResult {
		if Constants.fileManager.fileExists(atPath: url.path) {
			if Constants.fileManager.isDirectory(atPath: url.path) {
				return .isDirectory
			} else {
				return .isFile
			}
		} else {
			return .doesntExist
		}
	}

	var total: Int64 = 0

	for url in urls {
		switch checkItem(url) {
		case .doesntExist:
			if !options.force {
				printError("\(url.path): No such file or directory")
			}
		case .isFile:
			total += execute(url)
		case .isDirectory:
			if options.directories {
				if options.recursive {
					total += execute(url)
				} else {
					if let isEmpty = Constants.fileManager.isDirectoryEmpty(atPath: url.path) {
						if isEmpty {
							total += execute(url)
						} else {
							printError("\(url.path): Directory not empty")
						}
					}
				}
			} else {
				printError("\(url.path): is a directory")
			}
		}
	}

	return options.showSize ? total : nil
}

private func canExecute(_ url: URL) -> Bool {
	if options.force {
		return true
	} else {
		let check = checkPreExecution(url)

		switch check {
		case .noAttentionNeeded:
			if options.interactive {
				return promptYesOrNo(question: "\(options.actionPresent.capitalized) \(url.path)?",
									 questionType: .promptDeletion)
			} else {
				return true
			}
		case .ownedBySomeoneElse(by: let owner):
			return promptYesOrNo(question: "\(url.path) is owned by \(owner), \(options.actionPresent) anyway?",
								 questionType: .differentOwner)
		case .readOnly:
			return promptYesOrNo(question: "\(url.path) is read-only, \(options.actionPresent) anyway?",
								 questionType: .readOnly)
		}
	}
}

func execute(_ url: URL) -> Int64 {
	let confirmed = canExecute(url)

	if confirmed {
		do {
			var size: Int64 = 0

			if options.showSize {
				size = Constants.fileManager.sizeOfItem(atPath: url.path)
			}

			if options.verbose {
				fileInfoPrint(path: url.path,
							  size: size,
							  emoji: options.unlink ? "🔗" : "🗑 ")
			}

			if options.unlink {
				try Constants.fileManager.removeItem(at: url)
				return size
			} else {
				try Constants.fileManager.trashItem(at: url, resultingItemURL: nil)
				return size
			}

		} catch {
			printError(error.localizedDescription)
			return 0
		}
	} else {
		print("\(url.path) not \(options.actionPast)")
		return 0
	}
}
